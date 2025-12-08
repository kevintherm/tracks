package migrations

import (
	"github.com/pocketbase/pocketbase/core"
	m "github.com/pocketbase/pocketbase/migrations"
	"github.com/pocketbase/pocketbase/tools/types"
)

func init() {
	m.Register(func(app core.App) error {
		workoutCollection, err := app.FindCollectionByNameOrId("workouts")
		if err != nil {
			return err
		}

		collection := core.NewBaseCollection("schedules")

		collection.Fields.Add(&core.RelationField{
			Name:         "workout",
			MaxSelect:    1,
			Required:     true,
			CollectionId: workoutCollection.Id,
		})

		collection.Fields.Add(&core.SelectField{
			Name:      "recurrence_type",
			Values:    []string{"once", "daily", "monthly"},
			MaxSelect: 1,
			Required:  true,
		})

		collection.Fields.Add(&core.JSONField{
			Name: "selected_dates",
		})

		collection.Fields.Add(&core.JSONField{
			Name: "daily_weekday",
		})

		collection.Fields.Add(&core.DateField{
			Name:     "start_time",
			Required: true,
		})

		min := float64(0)
		collection.Fields.Add(&core.NumberField{
			Name:     "planned_duration",
			Min:      &min,
			Required: true,
			OnlyInt:  true,
		})

		collection.Fields.Add(&core.BoolField{
			Name: "duration_alert",
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

		collection.ListRule = types.Pointer("@request.auth.id = \"\" || workout.user = null || workout.user.id = @request.auth.id")
		collection.ViewRule = types.Pointer("@request.auth.id = \"\" || workout.user = null || workout.user.id = @request.auth.id")
		collection.CreateRule = types.Pointer("@request.auth.id = \"\" || workout.user = null || workout.user.id = @request.auth.id")
		collection.UpdateRule = types.Pointer("@request.auth.id = \"\" || workout.user = null || workout.user.id = @request.auth.id")
		collection.DeleteRule = types.Pointer("@request.auth.id = \"\" || workout.user = null || workout.user.id = @request.auth.id")

		err = app.Save(collection)
		if err != nil {
			return err
		}

		return nil
	}, func(app core.App) error {

		collection, err := app.FindCollectionByNameOrId("schedules")
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
