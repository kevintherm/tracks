package migrations

import (
	"github.com/pocketbase/pocketbase/core"
	m "github.com/pocketbase/pocketbase/migrations"
	"github.com/pocketbase/pocketbase/tools/types"
)

func init() {
	m.Register(func(app core.App) error {

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

		musclesCollection.Fields.Add(&core.FileField{
			Name:      "thumbnail",
			Required:  false,
			MaxSelect: 1,
			MaxSize:   20 * 1024 * 1024,
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

		err := app.Save(musclesCollection)
		if err != nil {
			return err
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
