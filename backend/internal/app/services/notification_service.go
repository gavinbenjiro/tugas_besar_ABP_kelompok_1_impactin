package services

import (
	"context"
	"log"

	"backend/internal/config"

	"firebase.google.com/go/v4/messaging"
)

type NotificationService struct {
	client *messaging.Client
}

func NewNotificationService() (*NotificationService, error) {

	client, err := config.FirebaseApp.Messaging(
		context.Background(),
	)
	if err != nil {
		return nil, err
	}

	return &NotificationService{
		client: client,
	}, nil
}

func (s *NotificationService) SendToToken(
	token string,
	title string,
	body string,
) error {

	log.Println("================================")
	log.Println("Sending FCM Notification")
	log.Println("TOKEN:", token)
	log.Println("TITLE:", title)
	log.Println("BODY:", body)
	log.Println("================================")

	msg := &messaging.Message{
		Token: token,
		Notification: &messaging.Notification{
			Title: title,
			Body:  body,
		},
	}

	response, err := s.client.Send(
		context.Background(),
		msg,
	)

	if err != nil {
		log.Println("FCM SEND FAILED:", err)
		return err
	}

	log.Println("FCM SENT SUCCESSFULLY")
	log.Println("MESSAGE ID:", response)

	return nil
}
