package request

type EventRequestDto struct {
	Title           string `json:"title" validate:"required"`
	Category        string `json:"category" validate:"required"`
	Location        string `json:"location" validate:"required"`
	SpecificAddress string `json:"specific_address" validate:"required"`
	AddressLink     string `json:"address_link" validate:"required,url"`

	StartDate string `json:"start_date" validate:"required"`
	EndDate   string `json:"end_date" validate:"required"`
	StartTime string `json:"start_time" validate:"required"` // HH:mm
	EndTime   string `json:"end_time" validate:"required"`

	MaxParticipant int `json:"max_participant" validate:"required,gt=0"`

	CoverImage  string  `json:"cover_image" validate:"required,url"`
	Description string  `json:"description" validate:"required"`
	Terms       *string `json:"terms"`

	MinAge int `json:"min_age"`
	MaxAge int `json:"max_age"`

	GroupLink string   `json:"group_link" validate:"required,url"`
	Latitude  *float64 `json:"latitude"`
	Longitude *float64 `json:"longitude"`
}
