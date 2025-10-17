package main

import (
	"bytes"
	"context"
	"encoding/json"
	"io"
	"log"
	"net/http"
	"net/url"
	"os"
	"strings"

	"github.com/joho/godotenv"
	"github.com/pocketbase/pocketbase"
	"github.com/pocketbase/pocketbase/apis"
	"github.com/pocketbase/pocketbase/core"
	"github.com/pocketbase/pocketbase/tools/subscriptions"
	"golang.org/x/sync/errgroup"
	"google.golang.org/genai"
)

func StringPtr(s string) *string {
	return &s
}

func notify(app core.App, subscription string, data any) error {
	rawData, err := json.Marshal(data)
	if err != nil {
		return err
	}

	message := subscriptions.Message{
		Name: subscription,
		Data: rawData,
	}

	group := new(errgroup.Group)

	chunks := app.SubscriptionsBroker().ChunkedClients(300)

	for _, chunk := range chunks {
		group.Go(func() error {
			for _, client := range chunk {

				if !client.HasSubscription(subscription) {
					continue
				}

				client.Send(message)
			}

			return nil
		})
	}

	return group.Wait()
}

func main() {
	app := pocketbase.New()

	err := godotenv.Load()
	if err != nil {
		log.Println("Error loading .env file")
	}

	app.OnServe().BindFunc(func(se *core.ServeEvent) error {
		// serves static files from the provided public dir (if exists)
		se.Router.GET("/{path...}", apis.Static(os.DirFS("./pb_public"), false))

		return se.Next()
	})

	app.OnRecordAfterCreateSuccess("claims").BindFunc(func(e *core.RecordEvent) error {
		claimRecord := e.Record

		go ProcessClaim(app, claimRecord)

		return nil
	})

	if err := app.Start(); err != nil {
		log.Println(err)
	}
}

func ProcessClaim(app core.App, claim *core.Record) {

	var err error

	processStage := []string{"Context", "Search", "Final"}
	channelId := "process-" + claim.Id
	currentStage := 0

	defer func() {
		if err != nil {
			// If an error was set anywhere in the function, notify and log it here.
			log.Printf("ERROR in ProcessClaim for record %s: %v", claim.Id, err)
			log.Printf("Current Stage: %d", currentStage)
			notify(app, channelId, map[string]any{
				"status":  false,
				"message": err.Error(),
				"stage":   processStage[currentStage],
			})
		}
	}()

	claimEvidenceCollection, err := app.FindCollectionByNameOrId("claim_evidence")
	if err != nil {
		return
	}

	// claimEvidenceSourcesCollection, err := app.FindCollectionByNameOrId("claim_evidence_sources")
	// if err != nil {
	// 	return
	// }

	fsys, err := app.NewFilesystem()
	if err != nil {
		return
	}
	defer fsys.Close()

	inputImage := claim.BaseFilesPath() + "/" + claim.GetString("source_image")
	image, err := fsys.GetReader(inputImage)
	if err != nil {
		return
	}
	defer image.Close()

	// Read the image content once into memory
	imageBuffer := new(bytes.Buffer)
	_, err = io.Copy(imageBuffer, image)
	if err != nil {
		return
	}
	imageBytes := imageBuffer.Bytes()

	// ==== Start Pipeline ====
	// === Stage - Context ===

	log.Println("BREAKPOINT 1")
	jsonContextProfile, err := GenerateImageContextProfile(app, imageBytes)
	if err != nil {
		return
	}

	log.Println("BREAKPOINT 2")
	claim.Set("json_context_profile", jsonContextProfile)

	log.Println("BREAKPOINT 3")
	claimTitle, err := GetTitleFromContext(app, jsonContextProfile)
	if err != nil {
		return
	}

	log.Println("BREAKPOINT 4")
	claim.Set("title", claimTitle)

	// Save the claim with title and context
	err = app.Save(claim)
	if err != nil {
		log.Println(err)
		return
	}

	log.Println("BREAKPOINT 5")
	notify(app, channelId, map[string]any{
		"status":  true,
		"message": "Context analysis complete",
		"stage":   processStage[currentStage],
	})

	// === Stage - Search ===
	currentStage = 1

	log.Println("BREAKPOINT 6")
	searchTerm, err := GetSearchTerm(app, jsonContextProfile)
	if err != nil {
		return
	}

	log.Println("BREAKPOINT 7")
	claim.Set("search_term", searchTerm)

	// Save the claim with search term
	err = app.Save(claim)
	if err != nil {
		log.Println(err)
		return
	}

	log.Println("BREAKPOINT 8")
	notify(app, channelId, map[string]any{
		"status":  true,
		"message": "Evidence search complete",
		"stage":   processStage[currentStage],
	})

	// === Stage - Final ===
	currentStage = 2

	log.Println("BREAKPOINT 9")
	verdict, err := QuickCheck(app, imageBytes)
	if err != nil {
		return
	}

	log.Printf("QuickCheck returned - Verdict: %s, Description: %s", verdict.Verdict, verdict.Description)

	log.Println("BREAKPOINT 10")
	claimEvidence := core.NewRecord(claimEvidenceCollection)
	claimEvidence.Set("claim", claim.Id)
	claimEvidence.Set("verdict", verdict.Verdict)
	claimEvidence.Set("description", verdict.Description)
	err = app.Save(claimEvidence)
	if err != nil {
		log.Println(err)
		return
	}

	log.Println("BREAKPOINT 11")
	// Also save verdict to the claim record for easier access
	claim.Set("verdict", verdict.Verdict)
	claim.Set("checked", true)

	log.Printf("Saving claim with verdict: %s", verdict.Verdict)
	log.Printf("Claim ID: %s", claim.Id)

	err = app.Save(claim)
	if err != nil {
		log.Println(err)
		return
	}

	log.Println("Claim saved successfully")
	log.Printf("Verification - claim.verdict: %s", claim.GetString("verdict"))

	log.Println("BREAKPOINT 12")
	notify(app, channelId, map[string]any{
		"status":  true,
		"message": "Final analysis complete",
		"stage":   processStage[currentStage],
	})

	// === End Pipeline ===

	log.Printf("Successfully processed claim for record %s", claim.Id)
}

type ClaimVerdict struct {
	Verdict     string `json:"verdict"`
	Description string `json:"description"`
}

func QuickCheck(app core.App, imageBytes []byte) (*ClaimVerdict, error) {
	apikey := os.Getenv("GEMINI_API_KEY")

	ctx := context.Background()

	client, err := genai.NewClient(ctx, &genai.ClientConfig{APIKey: apikey})
	if err != nil {
		log.Println(err)
		return nil, err
	}

	Prompt := `
		Find out what is happening on the image, then determine if the image is containing truth or misinformation.
		If you did not know after finding out, then choose 'idk' verdict and give an appropriate description about your finding.
		The verdict that you can choose are: [true, false, likely-true, likely-false, idk]
	`

	// Validate that we have image data
	if len(imageBytes) == 0 {
		log.Println("Error: image buffer is empty")
		return nil, err
	}

	parts := []*genai.Part{
		genai.NewPartFromBytes(imageBytes, "image/jpeg"),
		genai.NewPartFromText(Prompt),
	}

	contents := []*genai.Content{
		genai.NewContentFromParts(parts, genai.RoleUser),
	}

	genConfig := &genai.GenerateContentConfig{
		ResponseMIMEType: "application/json",
		ResponseSchema: &genai.Schema{
			Type: genai.TypeObject,
			Properties: map[string]*genai.Schema{
				"verdict":     {Type: genai.TypeString},
				"description": {Type: genai.TypeString},
			},
			Required:         []string{"verdict", "description"},
			PropertyOrdering: []string{"verdict", "description"},
		},
		ThinkingConfig: &genai.ThinkingConfig{
			ThinkingBudget: func(i int32) *int32 { return &i }(0),
		},
	}

	response, err := client.Models.GenerateContent(
		ctx,
		"gemini-2.5-flash",
		contents,
		genConfig,
	)

	if err != nil {
		log.Println(err)
		return nil, err
	}

	responseText := response.Text()
	log.Printf("QuickCheck API Response: %s", responseText)

	// Clean up the response text - remove markdown code blocks if present
	responseText = strings.TrimSpace(responseText)
	responseText = strings.TrimPrefix(responseText, "```json")
	responseText = strings.TrimPrefix(responseText, "```")
	responseText = strings.TrimSuffix(responseText, "```")
	responseText = strings.TrimSpace(responseText)

	var result ClaimVerdict
	if err := json.Unmarshal([]byte(responseText), &result); err != nil {
		log.Printf("Failed to unmarshal JSON: %v", err)
		log.Printf("Raw response text: %s", responseText)
		return nil, err
	}

	return &result, nil
}

func GenerateClaimVerdict(app core.App, contextProfile string, evidenceSources []map[string]any) (string, error) {
	apikey := os.Getenv("GEMINI_API_KEY")

	ctx := context.Background()

	client, err := genai.NewClient(ctx, &genai.ClientConfig{APIKey: apikey})
	if err != nil {
		log.Println(err)
		return "", err
	}

	Prompt := `
		Determine if the content is contains truth or misinformation. 
		I have given you the context profile of the image that I want to fact check, and the sources that I have collected.
		Feel free to add your own conclusion to determine the final verdict.
		If you cannot determine the verdict from the sources given, please choose the 'idk' verdict freely.
		The verdict that you can choose are: [true, false, likely-true, likely-false, idk]
	`

	parts := []*genai.Part{
		genai.NewPartFromText(Prompt),
	}

	contents := []*genai.Content{
		genai.NewContentFromParts(parts, genai.RoleUser),
	}

	genConfig := &genai.GenerateContentConfig{
		ResponseSchema: &genai.Schema{
			Type: genai.TypeString,
		},
		ThinkingConfig: &genai.ThinkingConfig{
			ThinkingBudget: func(i int32) *int32 { return &i }(0),
		},
	}

	result, err := client.Models.GenerateContent(
		ctx,
		"gemini-2.5-flash",
		contents,
		genConfig,
	)

	if err != nil {
		log.Println(err)
		return "", err
	}

	return result.Text(), nil
}

func SearchEvidence(app core.App, searchTerm string) ([]map[string]any, error) {

	searchUrl := "http://127.0.0.1:7000/mega/search?engines=duckduckgo&limit=10&language=EN&text=" + strings.ReplaceAll(searchTerm, `"`, "")

	req, err := http.NewRequest("GET", searchUrl, nil)
	if err != nil {
		log.Println("Error creating request:", err)
		return nil, err
	}

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		log.Println("Error making request:", err)
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		log.Println("Non-OK HTTP status:", resp.Status)
		return nil, err
	}

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		log.Println("Error reading response body:", err)
		return nil, err
	}

	var searchResults []map[string]any
	err = json.Unmarshal(body, &searchResults)
	if err != nil {
		log.Println("Error unmarshalling response body:", err)
		return nil, err
	}

	evidenceList := []map[string]any{}

	for _, item := range searchResults {
		if item["ad"] == true {
			continue
		}

		reqUrl := "http://127.0.0.1:7000/site?url=" + item["url"].(string)

		req, err := http.NewRequest("GET", reqUrl, nil)
		if err != nil {
			log.Println("Error creating request:", err)
			continue
		}

		resp, err := http.DefaultClient.Do(req)
		if err != nil {
			log.Println("Error making request:", err)
			continue
		}
		defer resp.Body.Close()

		if resp.StatusCode != http.StatusOK {
			log.Println("Non-OK HTTP status:", resp.Status)
			continue
		}

		body, err := io.ReadAll(resp.Body)
		if err != nil {
			log.Println("Error reading response body:", err)
			continue
		}

		var siteInfo map[string]any
		err = json.Unmarshal(body, &siteInfo)
		if err != nil {
			log.Println("Error unmarshalling response body:", err)
			continue
		}

		parsedURL, err := url.Parse(item["url"].(string))
		if err != nil {
			log.Println("Error:", err)
			continue
		}

		domain := parsedURL.Hostname()

		source := map[string]any{
			"domain":           domain,
			"full_url":         siteInfo["url"].(string),
			"source_author":    siteInfo["author"].(string),
			"source_title":     siteInfo["title"].(string),
			"source_published": siteInfo["published"].(string),
		}

		evidenceList = append(evidenceList, source)
	}

	return evidenceList, nil
}

func GetSearchTerm(app core.App, contextProfile string) (string, error) {
	apikey := os.Getenv("GEMINI_API_KEY")

	ctx := context.Background()

	client, err := genai.NewClient(ctx, &genai.ClientConfig{APIKey: apikey})
	if err != nil {
		log.Println(err)
		return "", err
	}

	Prompt := `
	From this given context of an image, I want to determine wether the image is telling the truth or misinformation. 
	Give me a google search term so that I can search and fact check it myself.
	Make the search term efficient at what it's doing.
	If the image contains a direct claim, identify the main claim as clearly and objectively as possible.
	If the image does not contain a direct claim, determine whether it's trying to imply something, make a joke, be satirical, mock, or refer to a controversial topic. Assume what the image is suggesting.
	Based on that claim or implied message, give me a Google search term that is efficient for fact-checking — short, clear, and specific.
	Do not give me your opinion or fact-check the claim yourself — I want to search and verify it myself.
	If the message is vague or unclear, still give me your best guess at a neutral, helpful search term.
	ONLY OUTPUT THE SEARCH TERM AND NOTHING ELSE!
	`

	parts := []*genai.Part{
		genai.NewPartFromText(Prompt),
		genai.NewPartFromText(contextProfile),
	}

	contents := []*genai.Content{
		genai.NewContentFromParts(parts, genai.RoleUser),
	}

	genConfig := &genai.GenerateContentConfig{
		ResponseSchema: &genai.Schema{
			Type: genai.TypeString,
		},
		ThinkingConfig: &genai.ThinkingConfig{
			ThinkingBudget: func(i int32) *int32 { return &i }(0),
		},
	}

	result, err := client.Models.GenerateContent(
		ctx,
		"gemini-2.5-flash",
		contents,
		genConfig,
	)

	if err != nil {
		log.Println(err)
		return "", err
	}

	return result.Text(), nil
}

func GetTitleFromContext(app core.App, contextProfile string) (string, error) {
	apikey := os.Getenv("GEMINI_API_KEY")

	ctx := context.Background()

	client, err := genai.NewClient(ctx, &genai.ClientConfig{APIKey: apikey})
	if err != nil {
		log.Println(err)
		return "", err
	}

	parts := []*genai.Part{
		genai.NewPartFromText("From the given context of an image, determine the title for it. Max 4 words."),
		genai.NewPartFromText(contextProfile),
	}

	contents := []*genai.Content{
		genai.NewContentFromParts(parts, genai.RoleUser),
	}

	genConfig := &genai.GenerateContentConfig{
		ResponseSchema: &genai.Schema{
			Type: genai.TypeString,
		},
		ThinkingConfig: &genai.ThinkingConfig{
			ThinkingBudget: func(i int32) *int32 { return &i }(0),
		},
	}

	result, err := client.Models.GenerateContent(
		ctx,
		"gemini-2.5-flash",
		contents,
		genConfig,
	)

	if err != nil {
		log.Println(err)
		return "", err
	}

	return result.Text(), nil
}

func GenerateImageContextProfile(app core.App, imageBytes []byte) (string, error) {

	apikey := os.Getenv("GEMINI_API_KEY")

	ctx := context.Background()

	client, err := genai.NewClient(ctx, &genai.ClientConfig{APIKey: apikey})
	if err != nil {
		log.Println(err)
		return "", err
	}

	// Validate that we have image data
	if len(imageBytes) == 0 {
		log.Println("Error: image buffer is empty")
		return "", err
	}

	parts := []*genai.Part{
		genai.NewPartFromBytes(imageBytes, "image/jpeg"),
		genai.NewPartFromText("Generate an ultra detailed 1:1 JSON context profile for this image complete with it's assumming description."),
	}

	contents := []*genai.Content{
		genai.NewContentFromParts(parts, genai.RoleUser),
	}

	genConfig := &genai.GenerateContentConfig{
		ResponseMIMEType: "application/json",
		ThinkingConfig: &genai.ThinkingConfig{
			ThinkingBudget: func(i int32) *int32 { return &i }(0),
		},
	}

	result, err := client.Models.GenerateContent(
		ctx,
		"gemini-2.5-flash",
		contents,
		genConfig,
	)

	if err != nil {
		log.Println(err)
		return "", err
	}

	return result.Text(), nil
}
