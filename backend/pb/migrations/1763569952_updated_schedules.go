package migrations

import (
	"encoding/json"

	"github.com/pocketbase/pocketbase/core"
	m "github.com/pocketbase/pocketbase/migrations"
)

func init() {
	m.Register(func(app core.App) error {
		collection, err := app.FindCollectionByNameOrId("pbc_1427126806")
		if err != nil {
			return err
		}

		// update collection data
		if err := json.Unmarshal([]byte(`{
			"createRule": "@request.auth.id = \"\" ||\nworkout.user = null ||\nworkout.user.id = @request.auth.id",
			"deleteRule": "@request.auth.id = \"\" ||\nworkout.user = null ||\nworkout.user.id = @request.auth.id",
			"listRule": "@request.auth.id = \"\" ||\nworkout.user = null ||\nworkout.user.id = @request.auth.id",
			"updateRule": "@request.auth.id = \"\" ||\nworkout.user = null ||\nworkout.user.id = @request.auth.id",
			"viewRule": "@request.auth.id = \"\" ||\nworkout.user = null ||\nworkout.user.id = @request.auth.id"
		}`), &collection); err != nil {
			return err
		}

		return app.Save(collection)
	}, func(app core.App) error {
		collection, err := app.FindCollectionByNameOrId("pbc_1427126806")
		if err != nil {
			return err
		}

		// update collection data
		if err := json.Unmarshal([]byte(`{
			"createRule": null,
			"deleteRule": null,
			"listRule": null,
			"updateRule": null,
			"viewRule": null
		}`), &collection); err != nil {
			return err
		}

		return app.Save(collection)
	})
}
