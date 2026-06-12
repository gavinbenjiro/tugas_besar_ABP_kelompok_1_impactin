package models

import "time"

type Notification struct {
	ID     uint `gorm:"primaryKey"`
	UserID uint `gorm:"not null;index"`

	Title   string `gorm:"size:255;not null"`
	Message string `gorm:"type:text;not null"`

	CreatedAt time.Time
	UpdatedAt time.Time

	User User `gorm:"foreignKey:UserID"`
}
