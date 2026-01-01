package migrations

import (
	"github.com/pocketbase/pocketbase/core"
	m "github.com/pocketbase/pocketbase/migrations"
	"github.com/pocketbase/pocketbase/tools/types"
)

func init() {
	m.Register(func(app core.App) error {
		collection := core.NewBaseCollection("posts")

		usersCollection, err := app.FindCollectionByNameOrId("users")
		if err != nil {
			return err
		}

		collection.Fields.Add(&core.RelationField{
			Name:         "user",
			MaxSelect:    1,
			Required:     true,
			CollectionId: usersCollection.Id,
		})

		collection.Fields.Add(&core.TextField{
			Name:     "title",
			Required: true,
		})

		collection.Fields.Add(&core.TextField{
			Name:     "slug",
			Pattern:  "^[a-z0-9]+(?:-[a-z0-9]+)*$",
			Required: true,
		})

		collection.Fields.Add(&core.EditorField{
			Name:     "content",
			Required: true,
		})

		collection.Fields.Add(&core.FileField{
			Name:      "files",
			MaxSelect: 15,
			MaxSize:   5242880, // 5MB
			MimeTypes: []string{"image/jpg", "image/jpeg", "image/png", "image/gif", "video/mp4"},
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

		collection.ListRule = types.Pointer("@request.auth.id != ''")
		collection.ViewRule = types.Pointer("@request.auth.id != ''")
		collection.CreateRule = types.Pointer("@request.auth.id != '' && @request.body.user = @request.auth.id")
		collection.UpdateRule = types.Pointer("@request.auth.id != '' && user = @request.auth.id")
		collection.DeleteRule = types.Pointer("@request.auth.id != '' && user = @request.auth.id")

		return app.Save(collection)
	}, func(app core.App) error {
		collection, err := app.FindCollectionByNameOrId("posts")
		if err != nil {
			return err
		}

		return app.Delete(collection)
	})
}
