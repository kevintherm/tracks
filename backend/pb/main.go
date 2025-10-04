package main

import (
	"bytes"
	"context"
	"encoding/json"
	"io"
	"log"
	"os"

	"github.com/joho/godotenv"
	"github.com/pocketbase/pocketbase"
	"github.com/pocketbase/pocketbase/apis"
	"github.com/pocketbase/pocketbase/core"
	"github.com/pocketbase/pocketbase/tools/subscriptions"
	"golang.org/x/sync/errgroup"
	"google.golang.org/genai"
)

const PromptExtractOrCheckImage = `
Describe the image loosely with maximum of 12 words, then

extract all strings from the given image. **Only return strings that form complete topics or sentences**. Exclude arbitrary words, single characters, or fragmented phrases.

**IF NO TEXT IS EXTRACTED,** analyze the image and report whether it shows signs of being **artificially generated or digitally altered**.

For the reason, keep it simple and straight to the point. Use natural, casual language and avoid sounding too formal. Do not use hyphens or em dashes. Just mention the key signs that the image is AI-generated or altered. For example:
The image looks too clean to be real and has no artifacts.
The lighting looks unnatural, like it was digitally made.
You can see clear signs of editing, like swapped text or major labels.

IF the image is widely known for something then state that. FOR EXAMPLE:
This is a meme containing nicholas cage saying outrageous stuff.
`

type ExtractedImageInfo struct {
	ImageDescription  string
	SignOfAiGenerated bool
	SignOfEdited      bool
	Reason            string
	TextFromImages    []string
}

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
		log.Fatal("Error loading .env file")
	}

	app.OnServe().BindFunc(func(se *core.ServeEvent) error {
		// serves static files from the provided public dir (if exists)
		se.Router.GET("/{path...}", apis.Static(os.DirFS("./pb_public"), false))

		return se.Next()
	})

	app.OnRecordAfterCreateSuccess("claims").BindFunc(func(e *core.RecordEvent) error {
		record := e.Record

		errs := app.ExpandRecord(record, []string{"users"}, nil)
		if len(errs) > 0 {
			log.Fatal("failed to expand: ", errs)
		}

		// Run in background, send notify on success/fail
		go func(rec *core.Record) {
			extracted := ExtractString(app, *rec)

			rec.Set("image_description", extracted.ImageDescription)
			rec.Set("extracted_text", extracted.TextFromImages)
			rec.Set("has_sign_of_altered", extracted.SignOfEdited)
			rec.Set("has_sign_of_ai_generated", extracted.SignOfAiGenerated)
			rec.Set("reason", extracted.Reason)

			channelId := "process-" + rec.Id

			log.Println(channelId)

			err = app.Save(rec)
			if err != nil {
				err = notify(app, channelId, map[string]any{
					"message": "Failed to process image.",
					"status":  false,
				})
				if err != nil {
					return
				}
			}

			err = notify(app, channelId, map[string]any{
				"message": "Process success.",
				"status":  true,
			})
			if err != nil {
				return
			}
		}(record)

		// TO-DO: Implement RAG Evidence Retrieval
		// Action: For each extracted claim, formulate a targeted search query using a News or Search API.
		// Output: Retrieve and collect a diverse set of article snippets, URLs, publication dates, and domains.
		// Database: Insert records into the EvidenceSources table (relation), linking each source (tuple/row) to the current Claim (tuple/row).
		// *Note for future: use actual search engine api, its pricey as hell
		// GetSourceEvidence(extracted)

		// // TO-DO: Implement Source Credibility & Bias Check
		// 	Action: For every unique domain found, check the SourceMetadata table (relation). If metadata is missing, use an LLM or external service to assess its bias and reliability.
		// 	Database: Update/Insert records into the SourceMetadata table (relation) for new domains.

		// // TO-DO: Implement Synthesis and Conflict Resolution
		// 	Action: Feed the claims, evidence snippets, and source credibility scores into a dedicated Synthesis LLM session.
		// 	Output: Generate a neutral summary that highlights consensus and clearly notes conflicting or unreliable information.

		// // TO-DO: Implement Final Verdict Mapping
		// 	Action: Feed the synthesized summary and the original claim into a final, highly constrained LLM session.
		// 	Output: Map the result to one of your four categories (True, Likely True, Likely False, False) and generate a numerical confidence score.

		// // TO-DO: Update Database and Return Results
		// 	Action: Update the initial Claims table (relation) record with the final verdict, confidence score, and summary.
		// 	Output: Return the final verdict and summary to the user, with an option to display the source list for elaboration.

		return e.Next()
	})

	if err := app.Start(); err != nil {
		log.Fatal(err)
	}
}

type SourceMetadata struct {
	title   string
	author  *string
	domain  string
	snippet string
	country string
}

func GetSourceEvidence(extracted ExtractedImageInfo) {
	// 5 items per topic

	// list := []SourceMetadata{}

	// for _, topic := range extracted.TextFromImages {

	// 	req, err := http.NewRequest("GET", "http://127.0.0.1:7070/bing/", nil)
	// 	if err != nil {
	// 		log.Println("Error creating request:", err)
	// 		continue
	// 	}
	// 	req.Header.Set("Authorization", "Bearer "+os.Getenv("NEWS_API_KEY"))

	// 	resp, err := http.DefaultClient.Do(req)
	// 	if err != nil {
	// 		log.Println("Error making request:", err)
	// 		continue
	// 	}
	// 	defer resp.Body.Close()

	// 	if resp.StatusCode != http.StatusOK {
	// 		log.Println("Non-OK HTTP status:", resp.Status)
	// 		continue
	// 	}

	// 	body, err := io.ReadAll(resp.Body)
	// 	if err != nil {
	// 		log.Println("Error reading response body:", err)
	// 		continue
	// 	}

	// 	// You can unmarshal and process the response here as needed

	// 	sourceMetaData := SourceMetadata{
	// 		title:   "hello",
	// 		author:  StringPtr("John Doe"),
	// 		domain:  "domain.net",
	// 		snippet: "Lorem ipsum dolor sit amet.",
	// 		country: "NE",
	// 	}

	// 	list = append(list, sourceMetaData)
	// }
}

// TO-DO: Implement Multimodal Claim Extraction
// Action: Use a Multimodal LLM (like Gemini) or an OCR pipeline followed by NLP to scan the screenshot for text.
// Output: Extract all explicit, verifiable claims (statements of fact) into a structured list.
// Database: Insert initial record into the Claims table (relation) with the raw input and time stamp.
func ExtractString(app core.App, record core.Record) ExtractedImageInfo {

	apikey := os.Getenv("GEMINI_API_KEY")

	ctx := context.Background()

	client, err := genai.NewClient(ctx, &genai.ClientConfig{APIKey: apikey})
	if err != nil {
		log.Fatal(err)
	}

	fsys, err := app.NewFilesystem()
	if err != nil {
		log.Fatal(err)
	}
	defer fsys.Close()

	inputImage := record.BaseFilesPath() + "/" + record.GetString("input_image")
	r, err := fsys.GetReader(inputImage)
	if err != nil {
		log.Fatal(err)
	}
	defer r.Close()

	content := new(bytes.Buffer)
	_, err = io.Copy(content, r)
	if err != nil {
		log.Fatal(err)
	}

	parts := []*genai.Part{
		genai.NewPartFromBytes(content.Bytes(), "image/jpeg"),
		genai.NewPartFromText(PromptExtractOrCheckImage),
	}

	contents := []*genai.Content{
		genai.NewContentFromParts(parts, genai.RoleUser),
	}

	genConfig := &genai.GenerateContentConfig{
		ResponseMIMEType: "application/json",
		ResponseSchema: &genai.Schema{
			Type: genai.TypeObject,
			Properties: map[string]*genai.Schema{
				"ImageDescription":  {Type: genai.TypeString},
				"signOfAiGenerated": {Type: genai.TypeBoolean},
				"signOfEdited":      {Type: genai.TypeBoolean},
				"Reason":            {Type: genai.TypeString},
				"textFromImages": {
					Type:  genai.TypeArray,
					Items: &genai.Schema{Type: genai.TypeString},
				},
			},
			PropertyOrdering: []string{"signOfAiGenerated", "signOfEdited", "textFromImages"},
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
		log.Fatal(err)

	}

	var extractedImageInfo ExtractedImageInfo
	if err := json.Unmarshal([]byte(result.Text()), &extractedImageInfo); err != nil {
		log.Fatal(err)
	}

	return extractedImageInfo
}
