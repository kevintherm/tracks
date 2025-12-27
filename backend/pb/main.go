package main

import (
	"log"
	"os"
	"strings"

	"github.com/joho/godotenv"
	"github.com/pocketbase/pocketbase"
	"github.com/pocketbase/pocketbase/apis"
	"github.com/pocketbase/pocketbase/core"
	"github.com/pocketbase/pocketbase/plugins/migratecmd"

	_ "backend/migrations"
)

func main() {

	app := pocketbase.New()

	err := godotenv.Load()
	if err != nil {
		log.Println("Error loading .env file")
	}

	app.OnServe().BindFunc(func(se *core.ServeEvent) error {
		// serves static files from the provided public dir (if exists)
		se.Router.GET("/{path...}", apis.Static(os.DirFS("./pb_public"), false))

		return se.Next()
	})

	// app.OnRecordEnrich("users").BindFunc(func(e *core.RecordEnrichEvent) error {

	// 	e.Record.Hide("emailVisibility")

	// 	if e.Record.GetBool("emailVisibility") == true {
	// 		e.Record.Hide("email")
	// 	}

	// 	return e.Next()
	// })

	app.OnRecordViewRequest("exercises", "workouts").BindFunc(func(e *core.RecordRequestEvent) error {

		if e.Auth != nil && e.Auth.Id != e.Record.GetString("user") && !e.Auth.IsSuperuser() {
			count := e.Record.GetInt("views")
			e.Record.Set("views", count+1)
			err := app.Save(e.Record)
			if err != nil {
				return err
			}
		}

		return e.Next()
	})

	isGoRun := strings.HasPrefix(os.Args[0], os.TempDir())

	migratecmd.MustRegister(app, app.RootCmd, migratecmd.Config{
		// enable auto creation of migration files when making collection changes in the Dashboard
		// (the isGoRun check is to enable it only during development)
		Automigrate: isGoRun,
	})

	if err := app.Start(); err != nil {
		log.Println(err)
	}
}
