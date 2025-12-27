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

		usersCollection, err := app.FindCollectionByNameOrId("users")
		if err != nil {
			return err
		}

		musclesCollection.Fields.Add(&core.RelationField{
			Name:          "user",
			CascadeDelete: true,
			CollectionId:  usersCollection.Id,
			MaxSelect:     1,
			Required:      false,
		})

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
			Name:      "thumbnails",
			Required:  false,
			MaxSelect: 12,
			MaxSize:   5 * 1024 * 1024,
			MimeTypes: []string{"image/jpg", "image/jpeg", "image/png", "image/gif", "image/heic"},
		})

		musclesCollection.Fields.Add(&core.AutodateField{
			Name:     "updated",
			OnCreate: true,
			OnUpdate: true,
		})

		musclesCollection.ListRule = types.Pointer("@request.auth.id != '' && @request.query.user = user")
		musclesCollection.ViewRule = types.Pointer("@request.auth.id != '' && (@request.auth.id = user || @request.query.user = user)")
		musclesCollection.CreateRule = types.Pointer("@request.auth.id != '' && @request.body.user = @request.auth.id")
		musclesCollection.UpdateRule = types.Pointer(`@request.auth.id != '' && user = @request.auth.id && (@request.body.user:isset = false || @request.body.user = @request.auth.id)`)
		musclesCollection.DeleteRule = types.Pointer("@request.auth.id != '' && user = @request.auth.id")

		_ = app.Save(musclesCollection)
		musclesCollection.ListRule = types.Pointer("")
		musclesCollection.ViewRule = types.Pointer("")

		err = app.Save(musclesCollection)
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

		return nil
	})
}
