package models

import "time"

type Event struct {
	ID              uint   `gorm:"primaryKey"`
	UserID          uint   `gorm:"not null"` // creator (host)
	Title           string `gorm:"not null"`
	Category        string `gorm:"not null"`
	Location        string `gorm:"not null"`
	SpecificAddress string `gorm:"not null"`
	AddressLink     string `gorm:"not null"`

	StartDate time.Time `gorm:"not null"`
	EndDate   time.Time `gorm:"not null"`

	StartTime string `gorm:"not null"` // "HH:mm"
	EndTime   string `gorm:"not null"`

	MaxParticipant     int `gorm:"not null"`
	CurrentParticipant int `gorm:"default:0"`

	CoverImage  string  `gorm:"not null"`
	Description string  `gorm:"type:text;not null"`
	Terms       *string `gorm:"type:text"`

	MinAge int `gorm:"default:0"`
	MaxAge int `gorm:"default:0"`

	GroupLink string `gorm:"not null"`

	Status    string   `gorm:"default:'pending'"` // pending, approved, declined
	SubStatus *string  `gorm:"default:null"`      // opened, closed, cancelled, completed
	Latitude  *float64 `gorm:"default:null"`
	Longitude *float64 `gorm:"default:null"`
}
