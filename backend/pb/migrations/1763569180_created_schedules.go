package migrations

import (
	"github.com/pocketbase/pocketbase/core"
	m "github.com/pocketbase/pocketbase/migrations"
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
		})

		collection.Fields.Add(&core.BoolField{
			Name: "duration_alert",
		})

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
