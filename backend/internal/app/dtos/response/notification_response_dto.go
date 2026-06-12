package response

import "time"

type NotificationResponseDto struct {
	ID        uint      `json:"id"`
	Title     string    `json:"title"`
	Message   string    `json:"message"`
	CreatedAt time.Time `json:"created_at"`
}
