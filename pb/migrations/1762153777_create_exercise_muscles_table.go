package migrations

import (
	"github.com/pocketbase/pocketbase/core"
	m "github.com/pocketbase/pocketbase/migrations"
	"github.com/pocketbase/pocketbase/tools/types"
)

func init() {
	m.Register(func(app core.App) error {
		collection := core.NewBaseCollection("exercise_muscles")

		exercisesCollection, err := app.FindCollectionByNameOrId("exercises")
		if err != nil {
			return err
		}

		musclesCollection, err := app.FindCollectionByNameOrId("muscles")
		if err != nil {
			return err
		}

		collection.Fields.Add(&core.RelationField{
			Name:          "exercise",
			Required:      true,
			CascadeDelete: true,
			CollectionId:  exercisesCollection.Id,
			MaxSelect:     1,
		})

		collection.Fields.Add(&core.RelationField{
			Name:          "muscle",
			Required:      true,
			CascadeDelete: true,
			CollectionId:  musclesCollection.Id,
			MaxSelect:     1,
		})

		collection.Fields.Add(&core.NumberField{
			Name:     "activation",
			Required: true,
			Min:      types.Pointer(0.0),
			Max:      types.Pointer(100.0),
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

		// Rules: Users can only manage exercise_muscles for their own exercises
		collection.ListRule = types.Pointer("@request.auth.id != '' && (exercise.user = @request.auth.id || exercise.is_public = true)")
		collection.ViewRule = types.Pointer("@request.auth.id != '' && (exercise.user = @request.auth.id || exercise.is_public = true)")
		collection.CreateRule = types.Pointer("@request.auth.id != '' && exercise.user = @request.auth.id")
		collection.UpdateRule = types.Pointer("@request.auth.id != '' && exercise.user = @request.auth.id")
		collection.DeleteRule = types.Pointer("@request.auth.id != '' && exercise.user = @request.auth.id")

		err = app.Save(collection)
		if err != nil {
			return err
		}

		return nil
	}, func(app core.App) error {
		collection, err := app.FindCollectionByNameOrId("exercise_muscles")
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
