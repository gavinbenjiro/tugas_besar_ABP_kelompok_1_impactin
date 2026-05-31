package response

import "time"

type EventRecommendationItemDto struct {
	EventID    uint      `json:"event_id"`
	Title      string    `json:"title"`
	Category   string    `json:"category"`
	CoverImage string    `json:"cover_image"`
	StartDate  string 	 `json:"start_date"`
	Location   string    `json:"location"`
	HostName   string    `json:"host_name"`
}

type EventRecommendationResponseDto struct {
	Events []EventRecommendationItemDto `json:"events"`
}

type RecommendationCandidate struct {
	EventID    uint
	Title      string
	Category   string
	CoverImage string
	StartDate  time.Time
	Location   string
	HostName   string
	Score      int
}