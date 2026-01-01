package migrations

import (
	"github.com/pocketbase/pocketbase/core"
	m "github.com/pocketbase/pocketbase/migrations"
	"github.com/pocketbase/pocketbase/tools/types"
)

func init() {
	m.Register(func(app core.App) error {

		workoutsCollection, err := app.FindCollectionByNameOrId("workouts")
		if err != nil {
			return err
		}

		exercisesCollection, err := app.FindCollectionByNameOrId("exercises")
		if err != nil {
			return err
		}

		collection := core.NewBaseCollection("workout_exercises")

		collection.Fields.Add(&core.RelationField{
			Name:          "workout",
			MaxSelect:     1,
			CollectionId:  workoutsCollection.Id,
			Required:      true,
			CascadeDelete: true,
		})

		collection.Fields.Add(&core.RelationField{
			Name:          "exercise",
			MaxSelect:     1,
			CollectionId:  exercisesCollection.Id,
			Required:      true,
			CascadeDelete: true,
		})

		collection.Fields.Add(&core.NumberField{
			Name:    "sets",
			Min:     types.Pointer(1.0),
			Max:     types.Pointer(100.0),
			OnlyInt: true,
		})

		collection.Fields.Add(&core.NumberField{
			Name:    "reps",
			Min:     types.Pointer(1.0),
			Max:     types.Pointer(100.0),
			OnlyInt: true,
		})

		collection.ListRule = types.Pointer("@request.auth.id != '' && (workout.user = @request.auth.id || workout.is_public = true)")
		collection.ViewRule = types.Pointer("@request.auth.id != '' && (workout.user = @request.auth.id || workout.is_public = true)")
		collection.CreateRule = types.Pointer(`@request.auth.id != '' && workout.user = @request.auth.id`)
		collection.UpdateRule = types.Pointer(`@request.auth.id != '' && workout.user = @request.auth.id`)
		collection.DeleteRule = types.Pointer(`@request.auth.id != '' && workout.user = @request.auth.id`)

		err = app.Save(collection)
		if err != nil {
			return err
		}

		return nil
	}, func(app core.App) error {

		collection, err := app.FindCollectionByNameOrId("workout_exercises")
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
