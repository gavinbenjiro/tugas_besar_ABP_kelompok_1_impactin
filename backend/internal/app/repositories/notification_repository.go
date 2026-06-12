package repositories

import (
	"backend/internal/app/models"

	"gorm.io/gorm"
)

type NotificationRepository struct {
	DB *gorm.DB
}

func NewNotificationRepository(
	db *gorm.DB,
) *NotificationRepository {
	return &NotificationRepository{
		DB: db,
	}
}

func (r *NotificationRepository) Create(
	notification *models.Notification,
) error {
	return r.DB.Create(notification).Error
}

func (r *NotificationRepository) GetByUserID(
	userID uint,
) ([]models.Notification, error) {

	var notifications []models.Notification

	err := r.DB.
		Where("user_id = ?", userID).
		Order("created_at DESC").
		Find(&notifications).
		Error

	return notifications, err
}

func (r *UserRepository) HasUnreadNotification(
	userID uint,
) (bool, error) {

	var user models.User

	err := r.DB.
		Select("has_unread_notification").
		First(&user, userID).
		Error

	return user.HasUnreadNotification, err
}

func (r *UserRepository) UpdateHasUnreadNotification(
	userID uint,
	value bool,
) error {

	return r.DB.
		Model(&models.User{}).
		Where("id = ?", userID).
		Update(
			"has_unread_notification",
			value,
		).Error
}
