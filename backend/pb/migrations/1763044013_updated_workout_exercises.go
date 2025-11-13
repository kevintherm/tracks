package migrations

import (
	"github.com/pocketbase/pocketbase/core"
	m "github.com/pocketbase/pocketbase/migrations"
)

func init() {
	m.Register(func(app core.App) error {
		collection, err := app.FindCollectionByNameOrId("workout_exercises")
		if err != nil {
			return err
		}

		exerciseCollection, err := app.FindCollectionByNameOrId("exercises")
		if err != nil {
			return err
		}

		collection.Fields.RemoveByName("exercises")
		collection.Fields.Add(&core.RelationField{
			Name:         "exercise",
			MaxSelect:    1,
			Required:     true,
			CollectionId: exerciseCollection.Id,
		})

		return nil
	}, func(app core.App) error {
		collection, err := app.FindCollectionByNameOrId("workout_exercises")
		if err != nil {
			return err
		}

		exerciseCollection, err := app.FindCollectionByNameOrId("exercises")
		if err != nil {
			return err
		}

		collection.Fields.RemoveByName("exercise")
		collection.Fields.Add(&core.RelationField{
			Name:         "exercises",
			MaxSelect:    10,
			Required:     true,
			CollectionId: exerciseCollection.Id,
		})

		return nil
	})
}
