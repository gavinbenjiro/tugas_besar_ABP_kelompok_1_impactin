package services

import (
	"backend/internal/app/dtos/response"
	"backend/internal/app/models"
	"backend/internal/app/repositories"
)

type NotificationHistoryService struct {
	NotificationRepo *repositories.NotificationRepository
	UserRepo         *repositories.UserRepository
}

func NewNotificationHistoryService(
	notificationRepo *repositories.NotificationRepository,
	userRepo *repositories.UserRepository,
) *NotificationHistoryService {

	return &NotificationHistoryService{
		NotificationRepo: notificationRepo,
		UserRepo:         userRepo,
	}
}

func (s *NotificationHistoryService) GetNotifications(
	userID uint,
) ([]response.NotificationResponseDto, error) {

	notifications, err :=
		s.NotificationRepo.GetByUserID(userID)

	if err != nil {
		return nil, err
	}

	var result []response.NotificationResponseDto

	for _, n := range notifications {

		result = append(
			result,
			response.NotificationResponseDto{
				ID:        n.ID,
				Title:     n.Title,
				Message:   n.Message,
				CreatedAt: n.CreatedAt,
			},
		)
	}

	return result, nil
}

func (s *NotificationHistoryService) CreateNotification(
	userID uint,
	title string,
	message string,
) error {

	return s.NotificationRepo.Create(
		&models.Notification{
			UserID:  userID,
			Title:   title,
			Message: message,
		},
	)
}

func (s *NotificationHistoryService) GetBellStatus(
	userID uint,
) (bool, error) {

	return s.UserRepo.
		HasUnreadNotification(userID)
}

func (s *NotificationHistoryService) MarkBellRead(
	userID uint,
) error {

	return s.UserRepo.
		UpdateHasUnreadNotification(
			userID,
			false,
		)
}
