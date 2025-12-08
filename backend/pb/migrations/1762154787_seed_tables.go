package migrations

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"math"
	"net/http"
	"os"
	"path"
	"time"

	"github.com/pocketbase/pocketbase/core"
	m "github.com/pocketbase/pocketbase/migrations"
	"github.com/pocketbase/pocketbase/tools/filesystem"
	// "github.com/pocketbase/pocketbase/tools/filesystem"
)

func FloorTo(x float64, decimals int) float64 {
	factor := math.Pow(10, float64(decimals))
	return math.Floor(x*factor) / factor
}

func init() {
	m.Register(func(app core.App) error {

		// Create admin user first
		adminUserId, err := CreateAdminUser(app)
		if err != nil {
			return fmt.Errorf("failed to create admin user (major error): %w", err)
		}

		// SeedMusclesTable is critical: if it fails, exercises can't be linked.
		// This is a "major error".
		muscleIds, err := SeedMusclesTable(app, adminUserId)
		if err != nil {
			return fmt.Errorf("failed to seed muscles (major error): %w", err)
		}

		// SeedExercisesTable is also critical, but errors inside (like one
		// record failing) will be handled individually.
		// An error returned here is a "major error" (eg. file not found).
		err = SeedExercisesTable(app, muscleIds, adminUserId)
		if err != nil {
			return fmt.Errorf("failed to seed exercises (major error): %w", err)
		}

		return nil
	}, func(app core.App) error {

		// These are "major errors" - if we can't find the collections,
		// we can't truncate them.
		usersCollection, err := app.FindCollectionByNameOrId("users")
		if err != nil {
			return err
		}

		musclesCollection, err := app.FindCollectionByNameOrId("muscles")
		if err != nil {
			return err
		}

		exercisesCollection, err := app.FindCollectionByNameOrId("exercises")
		if err != nil {
			return err
		}

		exerciseMusclesCollection, err := app.FindCollectionByNameOrId("exercise_muscles")
		if err != nil {
			return err
		}

		// Truncating is less risky, but we'll print errors if they happen.
		if err := app.TruncateCollection(musclesCollection); err != nil {
			fmt.Printf("Warning: Failed to truncate collection 'muscles': %v\n", err)
		}
		if err := app.TruncateCollection(exerciseMusclesCollection); err != nil {
			fmt.Printf("Warning: Failed to truncate collection 'exercise_muscles': %v\n", err)
		}
		if err := app.TruncateCollection(exercisesCollection); err != nil {
			fmt.Printf("Warning: Failed to truncate collection 'exercises': %v\n", err)
		}
		if err := app.TruncateCollection(usersCollection); err != nil {
			fmt.Printf("Warning: Failed to truncate collection 'users': %v\n", err)
		}

		return nil
	})
}

func CreateAdminUser(app core.App) (string, error) {
	usersCollection, err := app.FindCollectionByNameOrId("users")
	if err != nil {
		return "", err
	}

	record := core.NewRecord(usersCollection)
	record.Set("email", "tracks@tracks.com")
	record.Set("password", "password123")
	record.Set("passwordConfirm", "password123")
	record.SetVerified(true)

	err = app.Save(record)
	if err != nil {
		return "", fmt.Errorf("failed to create admin user: %w", err)
	}

	fmt.Printf("Created admin user: tracks@tracks.com\n")
	return record.Id, nil
}

func SeedExercisesTable(app core.App, muscleIds map[int]string, adminUserId string) error {

	// --- Major Errors ---
	// If we can't find collections or read/parse the seed file, we must stop.
	exercisesCollection, err := app.FindCollectionByNameOrId("exercises")
	if err != nil {
		return err
	}

	exerciseMusclesCollection, err := app.FindCollectionByNameOrId("exercise_muscles")
	if err != nil {
		return err
	}

	type MuscleSeed struct {
		Id         int `json:"id"`
		Activation int `json:"activation"`
	}

	type ExerciseSeed struct {
		ID             int          `json:"id"` // Assuming exercises.json also has an ID for better logging
		Name           string       `json:"name"`
		Description    string       `json:"description"`
		CaloriesBurned float64      `json:"caloriesBurned"`
		Muscles        []MuscleSeed `json:"muscles"`
	}

	jsonFile, err := os.ReadFile("seeds/exercises.json")
	if err != nil {
		return err
	}

	var data = []ExerciseSeed{}
	err = json.Unmarshal(jsonFile, &data)
	if err != nil {
		return err
	}

	// --- Minor Errors (handled in loop) ---
	for _, m := range data {
		record := core.NewRecord(exercisesCollection)
		record.Set("name", m.Name)
		record.Set("description", m.Description)
		record.Set("calories_burned", FloorTo(m.CaloriesBurned, 2))
		record.Set("user", adminUserId)
		record.Set("is_public", true)

		err = app.Save(record)
		if err != nil {
			// Per request: print error for collection and record, then continue
			fmt.Printf("MINOR ERROR: Failed saving record for collection 'exercises' (Name: %s): %v\n", m.Name, err)
			continue // Skip to the next exercise
		}

		// Make the many to many relationship
		for _, muscle := range m.Muscles {
			musclePocketbaseId, ok := muscleIds[muscle.Id]
			if !ok {
				// This muscle ID from exercises.json wasn't in the successfully-seeded muscles map
				fmt.Printf("MINOR ERROR: Skipping relation for exercise '%s'. Muscle with Seed ID %d not found in saved muscles map.\n", m.Name, muscle.Id)
				continue
			}

			pivot := core.NewRecord(exerciseMusclesCollection)
			pivot.Set("exercise", record.Id)
			pivot.Set("muscle", musclePocketbaseId)
			pivot.Set("activation", muscle.Activation)

			err = app.Save(pivot)
			if err != nil {
				// Per request: print error for collection and record, then continue
				fmt.Printf("MINOR ERROR: Failed saving relation for collection 'exercise_muscles' (Exercise: %s, Muscle Seed ID: %d): %v\n", m.Name, muscle.Id, err)
				continue // Skip to the next muscle relation
			}
		}

	}

	return nil
}

func SeedMusclesTable(app core.App, adminUserId string) (map[int]string, error) {

	// --- FIX: Increased timeout for all downloads ---
	ctx, cancel := context.WithTimeout(context.Background(), 120*time.Second) // 2 minutes
	defer cancel()

	// --- FIX: Define temp directory for downloads ---
	const tempDir = "./temp_downloads"
	if err := os.MkdirAll(tempDir, 0755); err != nil {
		return nil, fmt.Errorf("failed to create temp dir: %w", err)
	}
	// --- FIX: Defer cleanup of temp directory ---
	defer os.RemoveAll(tempDir)

	// --- Major Errors ---
	collection, err := app.FindCollectionByNameOrId("muscles")
	if err != nil {
		return nil, err
	}

	type MuscleSeed struct {
		ID          int    `json:"id"`
		Name        string `json:"name"`
		Description string `json:"description"`
		Thumbnail   string `json:"thumbnail"`
	}

	jsonFile, err := os.ReadFile("seeds/muscles.json")
	if err != nil {
		return nil, err
	}

	var muscles = []MuscleSeed{}
	err = json.Unmarshal(jsonFile, &muscles)
	if err != nil {
		return nil, err
	}

	// --- FIX: Phase 1: Download all files first (outside DB transaction) ---
	// Map muscle JSON ID to its local downloaded file path
	localFilePaths := make(map[int]string)

	fmt.Println("--- Starting Phase 1: Downloading muscle thumbnails ---")
	for _, m := range muscles {
		if m.Thumbnail == "" {
			continue // Skip if no thumbnail URL
		}

		filename := path.Base(m.Thumbnail)
		localPath := path.Join(tempDir, filename)

		err := DownloadFileToDisk(ctx, m.Thumbnail, localPath)
		if err != nil {
			// This is now a minor error, we just log it and continue
			fmt.Printf("MINOR ERROR: Failed to download thumbnail for muscle '%s' (Seed ID: %d): %v\n", m.Name, m.ID, err)
		} else {
			// Only map if download was successful
			localFilePaths[m.ID] = localPath
			fmt.Printf("Successfully downloaded thumbnail for '%s'\n", m.Name)
		}
	}
	fmt.Println("--- Finished Phase 1: Downloads complete ---")

	// --- FIX: Phase 2: Save records to database (fast, inside DB transaction) ---
	fmt.Println("--- Starting Phase 2: Seeding database ---")
	// Map int id to pocket base id
	pocketbaseIds := make(map[int]string)

	for _, m := range muscles {
		record := core.NewRecord(collection)
		record.Set("name", m.Name)
		record.Set("description", m.Description)
		record.Set("user", adminUserId)
		record.Set("is_public", true)

		// Check if we successfully downloaded a file for this muscle
		if localPath, ok := localFilePaths[m.ID]; ok {
			// Read the downloaded file from disk
			imageBytes, err := os.ReadFile(localPath)
			if err != nil {
				fmt.Printf("MINOR ERROR: Failed to read local file for muscle '%s' (Seed ID: %d): %v\n", m.Name, m.ID, err)
			} else {
				// Create the filesystem object from the bytes
				f, err := filesystem.NewFileFromBytes(imageBytes, path.Base(localPath))
				if err != nil {
					fmt.Printf("MINOR ERROR: Failed to create file system object for muscle '%s' (Seed ID: %d): %v\n", m.Name, m.ID, err)
				} else {
					record.Set("thumbnail", f)
				}
			}
		}
		// --- End thumbnail handling ---

		err = app.Save(record)
		if err != nil {
			// Per request: print error for collection and record, then continue
			fmt.Printf("MINOR ERROR: Failed saving record for collection 'muscles' (Name: %s, Seed ID: %d): %v\n", m.Name, m.ID, err)
			continue // Skip to the next muscle
		}

		// Only add to map if save was successful
		pocketbaseIds[m.ID] = record.Id
	}
	fmt.Println("--- Finished Phase 2: Seeding complete ---")

	return pocketbaseIds, nil
}

// --- FIX: New function to download to disk instead of memory ---
// Download a file to a specific destination path
func DownloadFileToDisk(ctx context.Context, url string, destPath string) error {

	// This delay is polite to the server you're downloading from.
	time.Sleep(1 * time.Second)

	req, err := http.NewRequestWithContext(ctx, "GET", url, nil)
	if err != nil {
		return err
	}

	req.Header.Set("User-Agent", "Tracks/0.1 (kevindarmawan023@gmail.com) GoHttpClient/1.0")

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body) // Read body for more context
		return fmt.Errorf("failed to download: status %s\nmessage: %s",
			resp.Status,
			string(body))
	}

	// Create the destination file
	out, err := os.Create(destPath)
	if err != nil {
		return err
	}
	defer out.Close()

	// Copy the response body to the file
	if _, err = io.Copy(out, resp.Body); err != nil {
		return err
	}

	return nil
}
