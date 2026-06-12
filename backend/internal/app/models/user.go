package models

type User struct {
	ID                    uint   `gorm:"primaryKey;autoIncrement"`
	Email                 string `gorm:"type:varchar(255);not null;unique"`
	Username              string `gorm:"type:varchar(100);not null;unique"`
	Password              string `gorm:"type:varchar(255);not null"`
	HasUnreadNotification bool   `gorm:"default:false"`
}
