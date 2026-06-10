package response

import "time"

type YourCreatedEventDetailResponseDto struct {
	EventID            uint           `json:"event_id"`
	Title              string         `json:"title"`
	Location           string         `json:"location"`
	StartDate          time.Time      `json:"start_date"`
	CurrentParticipant int            `json:"current_participant"`
	MaxParticipant     int            `json:"max_participant"`
	Status             string         `json:"status"`
	SubStatus          string         `json:"sub_status"`
	CanOpen            bool           `json:"can_open"`
	CanClose           bool           `json:"can_close"`
	Applicants         []EventUserDto `json:"applicants"`
	Participants       []EventUserDto `json:"participants"`
	CoverImage         string         `json:"cover_image"`
}

type EventUserDto struct {
	UserID uint   `json:"user_id"`
	Name   string `json:"name"`
}
