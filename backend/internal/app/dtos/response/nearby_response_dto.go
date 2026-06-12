package response

type NearbyEventResponseDto struct {
	EventID    uint    `json:"event_id"`
	Title      string  `json:"title"`
	Category   string  `json:"category"`
	CoverImage string  `json:"cover_image"`
	StartDate  string  `json:"start_date"`
	Location   string  `json:"location"`
	DistanceKM float64 `json:"distance_km"`
}
