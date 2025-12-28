package migrations

import (
	"github.com/pocketbase/pocketbase/core"
	m "github.com/pocketbase/pocketbase/migrations"
	"github.com/pocketbase/pocketbase/tools/types"
)

func init() {
	m.Register(func(app core.App) error {
		collection, err := app.FindCollectionByNameOrId("users")
		if err != nil {
			return err
		}

		collection.Fields.Add(&core.TextField{
			Name:                "username",
			Required:            true,
			Min:                 3,
			Max:                 32,
			Pattern:             string("^[a-zA-Z0-9_]+$"),
			AutogeneratePattern: string("[a-z0-9]{8}"),
		})

		// phone
		collection.Fields.Add(&core.TextField{
			Name:     "phone",
			Required: false,
			Max:      15,
			Hidden:   true,
		})

		// bio
		collection.Fields.Add(&core.TextField{
			Name:     "bio",
			Required: false,
			Max:      150,
		})

		// followers
		collection.Fields.Add(&core.NumberField{
			Name:    "followers",
			Min:     types.Pointer(0.0),
			OnlyInt: true,
		})

		// followings
		collection.Fields.Add(&core.NumberField{
			Name:    "followings",
			Min:     types.Pointer(0.0),
			OnlyInt: true,
		})

		// total_copies
		collection.Fields.Add(&core.NumberField{
			Name:    "total_views",
			Min:     types.Pointer(0.0),
			OnlyInt: true,
		})

		return app.Save(collection)

	}, func(app core.App) error {
		collection, err := app.FindCollectionByNameOrId("users")
		if err != nil {
			return err
		}

		collection.Fields.RemoveByName("username")
		collection.Fields.RemoveByName("phone")
		collection.Fields.RemoveByName("bio")
		collection.Fields.RemoveByName("followers")
		collection.Fields.RemoveByName("followings")
		collection.Fields.RemoveByName("total_copies")

		return app.Save(collection)
	})
}
