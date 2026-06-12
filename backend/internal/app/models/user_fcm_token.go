package models

import "time"

type UserFcmToken struct {
	ID        uint   `gorm:"primaryKey"`
	UserID    uint   `gorm:"not null;index"`
	Token     string `gorm:"size:512;unique;not null"`
	CreatedAt time.Time
	UpdatedAt time.Time

	User User `gorm:"foreignKey:UserID"`
}
