package config

import (
	"context"
	"log"

	firebase "firebase.google.com/go/v4"
	"google.golang.org/api/option"
)

var FirebaseApp *firebase.App

func InitFirebase() {

	opt := option.WithCredentialsFile(
		"../credentials/firebase-service-account.json",
	)

	conf := &firebase.Config{
		ProjectID: "impactin-d0c36",
	}

	app, err := firebase.NewApp(
		context.Background(),
		conf,
		opt,
	)
	if err != nil {
		log.Fatal("failed to initialize firebase:", err)
	}

	FirebaseApp = app

	log.Println("Firebase initialized")
}
