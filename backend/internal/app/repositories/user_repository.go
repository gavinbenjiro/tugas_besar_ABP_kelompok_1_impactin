package repositories

import (
	"backend/internal/app/models"

	"gorm.io/gorm"
)

type UserRepository struct {
	DB *gorm.DB
}

func NewUserRepository(db *gorm.DB) *UserRepository {
	return &UserRepository{DB: db}
}

func (r *UserRepository) Create(user *models.User) error {
	return r.DB.Create(user).Error
}

func (r *UserRepository) IsEmailExists(email string) bool {
	var count int64
	r.DB.Model(&models.User{}).Where("email = ?", email).Count(&count)
	return count > 0
}

func (r *UserRepository) IsUsernameExists(username string) bool {
	var count int64
	r.DB.Model(&models.User{}).Where("username = ?", username).Count(&count)
	return count > 0
}

func (r *UserRepository) IsUsernameExistsExceptUser(username string, userID uint) bool {
	var count int64
	r.DB.Model(&models.User{}).
		Where("username = ? AND id != ?", username, userID).
		Count(&count)

	return count > 0
}

func (r *UserRepository) FindByUsername(username string) (*models.User, error) {
	var user models.User
	result := r.DB.Where("username = ?", username).First(&user)
	if result.Error != nil {
		return nil, result.Error
	}
	return &user, nil
}

func (r *UserRepository) UpdateUsername(userID uint, username string) error {
	return r.DB.Model(&models.User{}).Where("id = ?", userID).Update("username", username).Error
}

func (r *UserRepository) GetByID(userID uint) (*models.User, error) {
	var user models.User
	err := r.DB.First(&user, userID).Error
	return &user, err
}

func (r *UserRepository) UpdatePassword(userID uint, hashed string) error {
	return r.DB.Model(&models.User{}).
		Where("id = ?", userID).
		Update("password", hashed).Error
}

func (r *UserRepository) SaveFCMToken(
	userID uint,
	token string,
) error {

	if err := r.DB.
		Where("token = ?", token).
		Delete(&models.UserFcmToken{}).Error; err != nil {
		return err
	}

	record := models.UserFcmToken{
		UserID: userID,
		Token:  token,
	}

	return r.DB.Create(&record).Error
}

func (r *UserRepository) RemoveFCMToken(
	token string,
) error {
	return r.DB.
		Where("token = ?", token).
		Delete(&models.UserFcmToken{}).Error
}

func (r *UserRepository) GetFCMTokensByUserID(
	userID uint,
) ([]string, error) {

	var records []models.UserFcmToken

	if err := r.DB.
		Where("user_id = ?", userID).
		Find(&records).Error; err != nil {
		return nil, err
	}

	var tokens []string

	for _, record := range records {
		tokens = append(tokens, record.Token)
	}

	return tokens, nil
}
