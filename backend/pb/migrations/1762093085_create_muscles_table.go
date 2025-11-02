package migrations

import (
	"encoding/json"
	"os"

	"github.com/pocketbase/pocketbase/core"
	m "github.com/pocketbase/pocketbase/migrations"
	"github.com/pocketbase/pocketbase/tools/types"
)

type MuscleGroupSeed struct {
	ID   int    `json:"id"`
	Name string `json:"name"`
}

type MuscleSeed struct {
	ID           int    `json:"id"`
	MuscleGroups []int  `json:"muscle_groups"`
	Name         string `json:"name"`
	Description  string `json:"description"`
}

type SeedData struct {
	MuscleGroups []MuscleGroupSeed `json:"muscle_groups"`
	Muscles      []MuscleSeed      `json:"muscles"`
}

func init() {
	m.Register(func(app core.App) error {
		// Create muscle_groups collection first
		muscleGroupCollection := core.NewBaseCollection("muscle_groups")

		muscleGroupCollection.Fields.Add(&core.TextField{
			Name:     "name",
			Required: true,
			Max:      255,
		})

		muscleGroupCollection.Fields.Add(&core.TextField{
			Name:     "description",
			Required: false,
			Max:      512,
		})

		muscleGroupCollection.Fields.Add(&core.FileField{
			Name:      "thumbnail",
			Required:  false,
			MaxSelect: 1,
			MimeTypes: []string{"image/jpg", "image/jpeg", "image/png", "image/gif", "image/heic"},
		})

		muscleGroupCollection.Fields.Add(&core.AutodateField{
			Name:     "created",
			OnCreate: true,
		})
		muscleGroupCollection.Fields.Add(&core.AutodateField{
			Name:     "updated",
			OnCreate: true,
			OnUpdate: true,
		})

		muscleGroupCollection.ListRule = types.Pointer("")
		muscleGroupCollection.ViewRule = types.Pointer("")

		err := app.Save(muscleGroupCollection)
		if err != nil {
			return err
		}

		// Create muscles collection
		musclesCollection := core.NewBaseCollection("muscles")

		musclesCollection.Fields.Add(&core.TextField{
			Name:     "name",
			Required: true,
			Max:      255,
		})

		musclesCollection.Fields.Add(&core.TextField{
			Name:     "description",
			Required: false,
			Max:      1024,
		})

		musclesCollection.Fields.Add(&core.RelationField{
			Name:         "muscle_groups",
			CollectionId: muscleGroupCollection.Id,
			MaxSelect:    10,
		})

		musclesCollection.Fields.Add(&core.FileField{
			Name:      "thumbnail",
			Required:  false,
			MaxSelect: 1,
			MimeTypes: []string{"image/jpg", "image/jpeg", "image/png", "image/gif", "image/heic"},
		})

		musclesCollection.Fields.Add(&core.AutodateField{
			Name:     "created",
			OnCreate: true,
		})
		musclesCollection.Fields.Add(&core.AutodateField{
			Name:     "updated",
			OnCreate: true,
			OnUpdate: true,
		})

		musclesCollection.ListRule = types.Pointer("")
		musclesCollection.ViewRule = types.Pointer("")

		err = app.Save(musclesCollection)
		if err != nil {
			return err
		}

		// Seed the tables

		// Read the JSON file
		jsonFile, err := os.ReadFile("seeds/muscles.json")
		if err != nil {
			return err
		}

		var seedData SeedData
		err = json.Unmarshal(jsonFile, &seedData)
		if err != nil {
			return err
		}

		// Seed muscle groups
		muscleGroupIDMap := make(map[int]string)
		for _, mg := range seedData.MuscleGroups {
			record := core.NewRecord(muscleGroupCollection)
			record.Set("name", mg.Name)
			record.Set("description", "")

			err = app.Save(record)
			if err != nil {
				return err
			}

			muscleGroupIDMap[mg.ID] = record.Id
		}

		// Seed muscles
		for _, m := range seedData.Muscles {
			record := core.NewRecord(musclesCollection)
			record.Set("name", m.Name)
			record.Set("description", m.Description)

			// Map muscle group IDs to PocketBase IDs
			var muscleGroupIDs []string
			for _, mgID := range m.MuscleGroups {
				if pbID, exists := muscleGroupIDMap[mgID]; exists {
					muscleGroupIDs = append(muscleGroupIDs, pbID)
				}
			}
			record.Set("muscle_groups", muscleGroupIDs)

			err = app.Save(record)
			if err != nil {
				return err
			}
		}

		return nil
	}, func(app core.App) error {
		collection, err := app.FindCollectionByNameOrId("muscles")
		if err != nil {
			return err
		}

		err = app.Delete(collection)
		if err != nil {
			return err
		}

		collection, err = app.FindCollectionByNameOrId("muscle_groups")
		if err != nil {
			return err
		}

		err = app.Delete(collection)
		if err != nil {
			return err
		}

		return nil
	})
}
