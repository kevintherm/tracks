package migrations

import (
	"github.com/pocketbase/pocketbase/core"
	m "github.com/pocketbase/pocketbase/migrations"
)

func init() {
	m.Register(func(app core.App) error {
		collection, err := app.FindCollectionByNameOrId("pbc_3122355729")
		if err != nil {
			return err
		}

		// remove field
		collection.Fields.RemoveById("file3277268710")

		// remove field
		collection.Fields.RemoveById("bool1811784642")

		return app.Save(collection)
	}, func(app core.App) error {
		collection, err := app.FindCollectionByNameOrId("pbc_3122355729")
		if err != nil {
			return err
		}

		// add field
		if err := collection.Fields.AddMarshaledJSONAt(5, []byte(`{
			"hidden": false,
			"id": "file3277268710",
			"maxSelect": 1,
			"maxSize": 20971520,
			"mimeTypes": [
				"image/jpg",
				"image/jpeg",
				"image/png",
				"image/gif",
				"image/heic"
			],
			"name": "thumbnail",
			"presentable": false,
			"protected": false,
			"required": false,
			"system": false,
			"thumbs": null,
			"type": "file"
		}`)); err != nil {
			return err
		}

		// add field
		if err := collection.Fields.AddMarshaledJSONAt(6, []byte(`{
			"hidden": false,
			"id": "bool1811784642",
			"name": "is_public",
			"presentable": false,
			"required": false,
			"system": false,
			"type": "bool"
		}`)); err != nil {
			return err
		}

		return app.Save(collection)
	})
}
