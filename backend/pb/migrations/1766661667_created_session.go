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

		exercisesCollection, err := app.FindCollectionByNameOrId("exercises")
		if err != nil {
			return err
		}

		// Create sessions collection
		sessionsCollection := core.NewBaseCollection("sessions")

		sessionsCollection.Fields.Add(&core.RelationField{
			Name:         "workout",
			MaxSelect:    1,
			Required:     true,
			CollectionId: workoutCollection.Id,
		})

		sessionsCollection.Fields.Add(&core.DateField{
			Name:     "start",
			Required: true,
		})

		sessionsCollection.Fields.Add(&core.DateField{
			Name: "end",
		})

		sessionsCollection.Fields.Add(&core.AutodateField{
			Name:     "created",
			OnCreate: true,
		})
		sessionsCollection.Fields.Add(&core.AutodateField{
			Name:     "updated",
			OnCreate: true,
			OnUpdate: true,
		})

		sessionsCollection.ListRule = types.Pointer("workout.user.id = @request.auth.id")
		sessionsCollection.ViewRule = types.Pointer("workout.user.id = @request.auth.id")
		sessionsCollection.CreateRule = types.Pointer("workout.user.id = @request.auth.id")
		sessionsCollection.UpdateRule = types.Pointer("workout.user.id = @request.auth.id")
		sessionsCollection.DeleteRule = types.Pointer("workout.user.id = @request.auth.id")

		err = app.Save(sessionsCollection)
		if err != nil {
			return err
		}

		// Create session_exercises collection
		sessionExercisesCollection := core.NewBaseCollection("session_exercises")

		sessionExercisesCollection.Fields.Add(&core.RelationField{
			Name:         "session",
			MaxSelect:    1,
			Required:     true,
			CollectionId: sessionsCollection.Id,
		})

		sessionExercisesCollection.Fields.Add(&core.RelationField{
			Name:         "exercise",
			MaxSelect:    1,
			Required:     true,
			CollectionId: exercisesCollection.Id,
		})

		sessionExercisesCollection.Fields.Add(&core.TextField{
			Name:     "exercise_name",
			Required: true,
		})

		minOrder := float64(0)
		sessionExercisesCollection.Fields.Add(&core.NumberField{
			Name:     "order",
			Min:      &minOrder,
			Required: true,
			OnlyInt:  true,
		})

		sessionExercisesCollection.Fields.Add(&core.AutodateField{
			Name:     "created",
			OnCreate: true,
		})
		sessionExercisesCollection.Fields.Add(&core.AutodateField{
			Name:     "updated",
			OnCreate: true,
			OnUpdate: true,
		})

		sessionExercisesCollection.ListRule = types.Pointer("session.workout.user.id = @request.auth.id")
		sessionExercisesCollection.ViewRule = types.Pointer("session.workout.user.id = @request.auth.id")
		sessionExercisesCollection.CreateRule = types.Pointer("session.workout.user.id = @request.auth.id")
		sessionExercisesCollection.UpdateRule = types.Pointer("session.workout.user.id = @request.auth.id")
		sessionExercisesCollection.DeleteRule = types.Pointer("session.workout.user.id = @request.auth.id")

		err = app.Save(sessionExercisesCollection)
		if err != nil {
			return err
		}

		// Create session_sets collection
		sessionSetsCollection := core.NewBaseCollection("session_sets")

		sessionSetsCollection.Fields.Add(&core.RelationField{
			Name:         "session_exercise",
			MaxSelect:    1,
			Required:     true,
			CollectionId: sessionExercisesCollection.Id,
		})

		minZero := float64(0)
		sessionSetsCollection.Fields.Add(&core.NumberField{
			Name:     "weight",
			Min:      &minZero,
			Required: true,
		})

		sessionSetsCollection.Fields.Add(&core.NumberField{
			Name:     "reps",
			Min:      &minZero,
			Required: true,
			OnlyInt:  true,
		})

		sessionSetsCollection.Fields.Add(&core.NumberField{
			Name:    "fail_on_rep",
			Min:     &minZero,
			OnlyInt: true,
		})

		sessionSetsCollection.Fields.Add(&core.NumberField{
			Name:     "effort_rate",
			Min:      &minZero,
			Required: true,
			OnlyInt:  true,
		})

		sessionSetsCollection.Fields.Add(&core.NumberField{
			Name:    "rest_duration",
			Min:     &minZero,
			OnlyInt: true,
		})

		sessionSetsCollection.Fields.Add(&core.NumberField{
			Name:     "duration",
			Min:      &minZero,
			Required: true,
			OnlyInt:  true,
		})

		sessionSetsCollection.Fields.Add(&core.TextField{
			Name: "note",
		})

		sessionSetsCollection.Fields.Add(&core.AutodateField{
			Name:     "created",
			OnCreate: true,
		})
		sessionSetsCollection.Fields.Add(&core.AutodateField{
			Name:     "updated",
			OnCreate: true,
			OnUpdate: true,
		})

		sessionSetsCollection.ListRule = types.Pointer("session_exercise.session.workout.user.id = @request.auth.id")
		sessionSetsCollection.ViewRule = types.Pointer("session_exercise.session.workout.user.id = @request.auth.id")
		sessionSetsCollection.CreateRule = types.Pointer("session_exercise.session.workout.user.id = @request.auth.id")
		sessionSetsCollection.UpdateRule = types.Pointer("session_exercise.session.workout.user.id = @request.auth.id")
		sessionSetsCollection.DeleteRule = types.Pointer("session_exercise.session.workout.user.id = @request.auth.id")

		err = app.Save(sessionSetsCollection)
		if err != nil {
			return err
		}

		return nil
	}, func(app core.App) error {
		// Delete in reverse order due to relations
		sessionSetsCollection, err := app.FindCollectionByNameOrId("session_sets")
		if err != nil {
			return err
		}
		err = app.Delete(sessionSetsCollection)
		if err != nil {
			return err
		}

		sessionExercisesCollection, err := app.FindCollectionByNameOrId("session_exercises")
		if err != nil {
			return err
		}
		err = app.Delete(sessionExercisesCollection)
		if err != nil {
			return err
		}

		sessionsCollection, err := app.FindCollectionByNameOrId("sessions")
		if err != nil {
			return err
		}
		err = app.Delete(sessionsCollection)
		if err != nil {
			return err
		}

		return nil
	})
}
