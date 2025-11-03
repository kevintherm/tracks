package migrations

import (
	"github.com/pocketbase/pocketbase/core"
	m "github.com/pocketbase/pocketbase/migrations"
	"github.com/pocketbase/pocketbase/tools/types"
)

func init() {
	m.Register(func(app core.App) error {
		collection := core.NewBaseCollection("exercises")

		usersCollection, err := app.FindCollectionByNameOrId("users")
		if err != nil {
			return err
		}

		collection.Fields.Add(&core.RelationField{
			Name:          "user",
			CascadeDelete: true,
			CollectionId:  usersCollection.Id,
			MaxSelect:     1,
		})

		collection.Fields.Add(&core.TextField{
			Name:     "name",
			Required: true,
			Max:      255,
		})

		collection.Fields.Add(&core.TextField{
			Name:     "description",
			Required: true,
			Max:      500,
		})

		collection.Fields.Add(&core.NumberField{
			Name:     "calories_burned",
			Required: true,
			Min:      types.Pointer(0.0),
		})

		collection.Fields.Add(&core.FileField{
			Name:      "thumbnail",
			Required:  false,
			MaxSelect: 1,
			MimeTypes: []string{"image/jpg", "image/jpeg", "image/png", "image/gif", "image/heic"},
		})

		collection.Fields.Add(&core.FileField{
			Name:      "guide_gifs",
			Required:  false,
			MaxSelect: 10,
			MimeTypes: []string{"image/gif"},
		})

		collection.Fields.Add(&core.URLField{
			Name:     "guide_video",
			Required: false,
		})

		collection.Fields.Add(&core.AutodateField{
			Name:     "created",
			OnCreate: true,
		})
		collection.Fields.Add(&core.AutodateField{
			Name:     "updated",
			OnCreate: true,
			OnUpdate: true,
		})

		collection.ListRule = types.Pointer("@request.auth.id != '' && user = @request.auth.id")
		collection.ViewRule = types.Pointer("@request.auth.id != '' && user = @request.auth.id")
		collection.CreateRule = types.Pointer("@request.auth.id != '' && @request.body.user = @request.auth.id")
		collection.UpdateRule = types.Pointer(`
			@request.auth.id != '' &&
			user = @request.auth.id &&
			(@request.body.user:isset = false || @request.body.user = @request.auth.id)
		`)
		collection.DeleteRule = types.Pointer("@request.auth.id != '' && user = @request.auth.id")

		err = app.Save(collection)
		if err != nil {
			return err
		}

		return nil
	}, func(app core.App) error {
		collection, err := app.FindCollectionByNameOrId("exercises")
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
