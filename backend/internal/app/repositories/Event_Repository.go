package repositories

import (
	"backend/internal/app/dtos/response"
	"backend/internal/app/models"
	"errors"
	"strconv"
	"strings"
	"time"

	"gorm.io/gorm"
)

type EventRepository interface {
	Create(event *models.Event) error
	GetEventByID(eventID uint) (*models.Event, error)
	GetAllEvents(category, search string, ageRanges []string) ([]response.EventListResponseDto, error)
	GetYourCreatedEvents(userID uint, status string) ([]response.YourEventResponseDto, error)
	GetEventDetailByID(eventID uint) (*response.EventDetailResponseDto, uint, *string, error)
	GetCarouselEvents() (map[string]*response.EventCarouselItemDto, error)
	GetRecommendationCandidates(userID uint) ([]response.RecommendationCandidate, error)
	GetFallbackRecommendation() ([]response.EventRecommendationItemDto, error)
	GetUserCategoryHistory(userID uint) (map[string]int, error)
	GetEventForJoin(eventID uint) (*response.EventJoinCheckDto, error)
	AdminGetAllEvents(status, search string) ([]response.AdminEventsResponseDto, int64, error)
	AdminGetEventDetail(eventID uint) (*response.EventResponseDto, error)
	UpdateApprovalStatus(event *models.Event) error
	UpdateSubStatus(eventID uint, subStatus string) error
	IncrementParticipant(tx *gorm.DB, eventID uint) error
	DecrementParticipant(eventID uint) error
	WithTx(fn func(tx *gorm.DB) error) error
	GetEventByIDAndHost(eventID, userID uint) (*models.Event, error)
	GetApplicantsByEventID(eventID uint) ([]response.EventUserDto, error)
	GetParticipantsByEventID(eventID uint) ([]response.EventUserDto, error)
	GetJoinedEvents(userID uint, status string) ([]response.YourEventResponseDto, error)
	GetCompletedEventsByParticipant(userID uint) ([]response.ProfileCompletedEventDto, error)
	GetApprovedEvents() ([]models.Event, error)
	GetNearbyEvents(userID uint) ([]models.Event, error)
}

type eventRepository struct {
	db *gorm.DB
}

func NewEventRepository(db *gorm.DB) EventRepository {
	return &eventRepository{db}
}

func (r *eventRepository) Create(event *models.Event) error {
	return r.db.Create(event).Error
}

func (r *eventRepository) GetEventByID(eventID uint) (*models.Event, error) {
	var event models.Event
	err := r.db.First(&event, eventID).Error
	return &event, err
}

func (r *eventRepository) GetAllEvents(category, search string, ageRanges []string) ([]response.EventListResponseDto, error) {
	var events []response.EventListResponseDto

	query := r.db.Table("events").
		Select(`
			events.id AS event_id,
			events.title,
			events.category,
			events.cover_image,
			events.start_date,
			events.location,
			profiles.name AS host_name
		`).
		Joins("JOIN profiles ON profiles.user_id = events.user_id").
		Where("events.status = ?", "approved").
		Where("events.sub_status IN ?", []string{"opened", "closed"})

	if category != "" {
		query = query.Where("LOWER(events.category) = LOWER(?)", category)
	}

	if search != "" {
		keyword := "%" + strings.ToLower(search) + "%"
		query = query.Where(`
		(
			LOWER(events.title) LIKE ? OR
			LOWER(events.category) LIKE ? OR
			LOWER(events.location) LIKE ? OR
			LOWER(profiles.name) LIKE ?
		)
		`, keyword, keyword, keyword, keyword)
	}

	if len(ageRanges) > 0 {
		ageQuery := r.db.Where("events.min_age = 0 AND events.max_age = 0")

		for _, r := range ageRanges {
			switch r {
			case "<16":
				ageQuery = ageQuery.Or(`events.min_age < ?`, 16)
			case "16-20":
				ageQuery = ageQuery.Or(`(events.max_age >= ? OR events.max_age >= ?) AND (events.min_age <= ? OR events.min_age <= ?) OR (events.min_age <= ? AND events.max_age = 0)`, 16, 20, 16, 20, 16)
			case "21-30":
				ageQuery = ageQuery.Or(`(events.max_age >= ? OR events.max_age >= ?) AND (events.min_age <= ? OR events.min_age <= ?) OR (events.min_age <= ? AND events.max_age = 0)`, 21, 30, 21, 30, 21)
			case "31-45":
				ageQuery = ageQuery.Or(`(events.max_age >= ? OR events.max_age >= ?) AND (events.min_age <= ? OR events.min_age <= ?) OR (events.min_age <= ? AND events.max_age = 0)`, 31, 45, 31, 45, 31)
			case ">45":
				ageQuery = ageQuery.Or(`events.max_age > ? OR events.max_age = 0`, 45)
			}
		}
		query = query.Where(ageQuery)
	}

	err := query.Order("events.id ASC").Scan(&events).Error

	return events, err
}

func (r *eventRepository) GetYourCreatedEvents(userID uint, status string) ([]response.YourEventResponseDto, error) {
	var events []response.YourEventResponseDto

	query := r.db.Table("events").
		Select(`
			events.id AS event_id,
			events.title,
			events.start_date,
			events.location,
			events.status,
			events.sub_status,
			profiles.name AS host_name
		`).
		Joins("JOIN profiles ON profiles.user_id = events.user_id").
		Where("events.user_id = ?", userID)

	switch status {
	case "pending":
		query = query.Where("events.status = ?", "pending")

	case "approved":
		query = query.
			Where("events.status = ?", "approved").
			Where("events.sub_status IS NULL OR events.sub_status != ? AND events.sub_status != ?", "cancelled", "completed")

	case "declined":
		query = query.Where("events.status = ?", "declined")

	case "cancelled":
		query = query.
			Where("events.status = ?", "approved").
			Where("events.sub_status = ?", "cancelled")

	case "completed":
		query = query.
			Where("events.status = ?", "approved").
			Where("events.sub_status = ?", "completed")
	}

	err := query.
		Order("events.start_date DESC").
		Scan(&events).Error

	return events, err
}

func (r *eventRepository) GetEventDetailByID(eventID uint) (*response.EventDetailResponseDto, uint, *string, error) {
	var event response.EventDetailResponseDto
	var hostID uint
	var groupLink string

	query := r.db.Table("events").
		Select(`
			events.id AS event_id,
			events.title,
			events.location,
			events.specific_address,
			events.address_link,
			events.start_date,
			events.end_date,
			events.start_time,
			events.end_time,
			events.cover_image,
			events.description,
			events.terms,
			events.min_age,
			events.max_age,
			profiles.name AS host_name,
			events.user_id,
			events.status,
			events.sub_status
		`).
		Joins("JOIN profiles ON profiles.user_id = events.user_id").
		Where("events.id = ?", eventID).
		Take(&event)

	if query.Error != nil {
		return nil, 0, nil, query.Error
	}

	// Ambil group link terpisah
	queryGroup := r.db.
		Table("events").
		Select("group_link").
		Where("id = ?", eventID).
		Scan(&groupLink).Error

	if queryGroup != nil {
		return nil, 0, nil, queryGroup
	}

	// Ambil host id terpisah
	err := r.db.
		Table("events").
		Select("user_id").
		Where("id = ?", eventID).
		Scan(&hostID).Error

	if err != nil {
		return nil, 0, nil, err
	}

	return &event, hostID, &groupLink, nil
}

func (r *eventRepository) GetCarouselEvents() (map[string]*response.EventCarouselItemDto, error) {
	categories := []string{
		"Health",
		"Environment",
		"Education",
		"Community",
	}

	result := make(map[string]*response.EventCarouselItemDto)

	for _, category := range categories {
		var event response.EventCarouselItemDto

		err := r.db.Table("events").
			Select(`
				events.id AS event_id,
				events.title,
				events.category,
				events.cover_image
			`).
			Where("events.status = ?", "approved").
			Where("events.sub_status IN ?", []string{"opened"}).
			Where("events.category = ?", category).
			Order("events.start_date DESC").
			Limit(1).
			Scan(&event).Error

		if err != nil {
			return nil, err
		}

		if event.EventID == 0 {
			result[strings.ToLower(category)] = nil
		} else {
			result[strings.ToLower(category)] = &event
		}
	}

	return result, nil
}

func (r *eventRepository) GetRecommendationCandidates(userID uint) ([]response.RecommendationCandidate, error) {
	var events []response.RecommendationCandidate

	subQuery := r.db.
		Table("participants").
		Select("event_id").
		Where("user_id = ?", userID)

	err := r.db.Table("events").
		Select(`
			events.id AS event_id,
			events.title,
			events.category,
			events.cover_image,
			events.start_date,
			events.location,
			profiles.name AS host_name
		`).
		Joins("JOIN profiles ON profiles.user_id = events.user_id").
		Where("events.status = ?", "approved").
		Where("events.sub_status = ?", "opened").
		Where("events.id NOT IN (?)", subQuery).
		Scan(&events).Error

	return events, err
}

func (r *eventRepository) GetFallbackRecommendation() ([]response.EventRecommendationItemDto, error) {
	var events []response.EventRecommendationItemDto

	err := r.db.Table("events").
		Select(`
			events.id AS event_id,
			events.title,
			events.category,
			events.cover_image,
			events.start_date,
			events.location,
			profiles.name AS host_name
		`).
		Joins("JOIN profiles ON profiles.user_id = events.user_id").
		Where("events.status = ?", "approved").
		Where("events.sub_status = ?", "opened").
		Order("events.start_date ASC").
		Limit(4).
		Scan(&events).Error

	return events, err
}

func (r *eventRepository) GetUserCategoryHistory(userID uint) (map[string]int, error) {

	type CategoryCount struct {
		Category string
		Total    int
	}

	var results []CategoryCount

	err := r.db.Table("participants").
		Select(`
			events.category,
			COUNT(*) AS total
		`).
		Joins("JOIN events ON events.id = participants.event_id").
		Where("participants.user_id = ?", userID).
		Group("events.category").
		Scan(&results).Error

	if err != nil {
		return nil, err
	}

	history := make(map[string]int)

	for _, r := range results {
		history[r.Category] = r.Total
	}

	return history, nil
}

func (r *eventRepository) GetEventForJoin(eventID uint) (*response.EventJoinCheckDto, error) {
	var event response.EventJoinCheckDto

	err := r.db.Table("events").
		Select(`
			id AS event_id,
			user_id,
			status,
			sub_status,
			min_age,
			max_age
		`).
		Where("id = ?", eventID).
		Scan(&event).Error

	if err != nil {
		return nil, err
	}
	if event.EventID == 0 {
		return nil, gorm.ErrRecordNotFound
	}

	return &event, nil
}

func (r *eventRepository) AdminGetAllEvents(status, search string) ([]response.AdminEventsResponseDto, int64, error) {
	var events []response.AdminEventsResponseDto
	var total int64

	query := r.db.Table("events").
		Where("status = ?", status)

	if search != "" {
		if id, err := strconv.Atoi(search); err == nil {
			query = query.Where("id = ?", id)
		} else {
			query = query.Where("LOWER(title) LIKE LOWER(?)", "%"+search+"%")
		}
	}

	if err := query.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	err := query.
		Select("id AS event_id, title").
		Order("id ASC").
		Scan(&events).Error

	return events, total, err
}

func (r *eventRepository) AdminGetEventDetail(eventID uint) (*response.EventResponseDto, error) {
	var event response.EventResponseDto

	err := r.db.Table("events").
		Select(`
			profiles.name AS host_name,
			events.user_id,
			events.id AS event_id,
			events.title,
			events.category,
			events.location,
			events.specific_address,
			events.address_link,
			events.start_date,
			events.end_date,
			events.start_time,
			events.end_time,
			events.max_participant,
			events.cover_image,
			events.description,
			events.terms,
			events.min_age,
			events.max_age,
			events.group_link,
			events.status,
			events.sub_status
		`).
		Joins("JOIN profiles ON profiles.user_id = events.user_id").
		Where("events.id = ?", eventID).
		Scan(&event).Error

	if err != nil {
		return nil, err
	}

	if event.EventID == 0 {
		return nil, gorm.ErrRecordNotFound
	}

	return &event, nil
}

func (r *eventRepository) UpdateApprovalStatus(event *models.Event) error {
	return r.db.Model(&models.Event{}).
		Where("id = ?", event.ID).
		Updates(map[string]interface{}{
			"status":     event.Status,
			"sub_status": event.SubStatus,
		}).Error
}

func (r *eventRepository) UpdateSubStatus(eventID uint, subStatus string) error {
	return r.db.Model(&models.Event{}).
		Where("id = ?", eventID).
		Update("sub_status", subStatus).Error
}

func (r *eventRepository) IncrementParticipant(tx *gorm.DB, eventID uint) error {
	return tx.Model(&models.Event{}).
		Where("id = ?", eventID).
		UpdateColumn("current_participant", gorm.Expr("current_participant + 1")).
		Error
}

func (r *eventRepository) DecrementParticipant(eventID uint) error {
	return r.db.Model(&models.Event{}).
		Where("id = ? AND current_participant > 0", eventID).
		UpdateColumn("current_participant", gorm.Expr("current_participant - 1")).Error
}

func (r *eventRepository) WithTx(fn func(tx *gorm.DB) error) error {
	tx := r.db.Begin()
	if err := fn(tx); err != nil {
		tx.Rollback()
		return err
	}
	return tx.Commit().Error
}

func (r *eventRepository) GetEventByIDAndHost(eventID, userID uint) (*models.Event, error) {
	var event models.Event

	err := r.db.
		Where("id = ? AND user_id = ?", eventID, userID).
		First(&event).Error

	if err != nil {
		return nil, errors.New("event not found or not owned by user")
	}

	return &event, nil
}

func (r *eventRepository) GetApplicantsByEventID(eventID uint) ([]response.EventUserDto, error) {
	var applicants []response.EventUserDto

	err := r.db.
		Table("applicants").
		Select("applicants.user_id, profiles.name").
		Joins("JOIN profiles ON profiles.user_id = applicants.user_id").
		Where("applicants.event_id = ?", eventID).
		Scan(&applicants).Error

	return applicants, err
}

func (r *eventRepository) GetParticipantsByEventID(eventID uint) ([]response.EventUserDto, error) {
	var participants []response.EventUserDto

	err := r.db.
		Table("participants").
		Select("participants.user_id, profiles.name").
		Joins("JOIN profiles ON profiles.user_id = participants.user_id").
		Where("participants.event_id = ?", eventID).
		Scan(&participants).Error

	return participants, err
}

func (r *eventRepository) GetJoinedEvents(userID uint, status string) ([]response.YourEventResponseDto, error) {
	var events []response.YourEventResponseDto

	now := time.Now()

	query := r.db.Table("participants").
		Joins("JOIN events ON events.id = participants.event_id").
		Joins("JOIN profiles ON profiles.user_id = events.user_id").
		Where("participants.user_id = ?", userID)

	// 🔹 Filter logic
	switch strings.ToLower(status) {
	case "ongoing":
		query = query.Where(`
			? >= TIMESTAMP(DATE(events.start_date), events.start_time)
			AND ? < TIMESTAMP(DATE(events.end_date), events.end_time)
			AND events.sub_status != ?
			AND events.sub_status != ?
		`, now, now, "completed", "cancelled")

	case "upcoming":
		query = query.Where(`
			? < TIMESTAMP(DATE(events.start_date), events.start_time)
			AND events.sub_status != ?
			AND events.sub_status != ?
		`, now, "completed", "cancelled")

	case "completed":
		query = query.Where(`events.sub_status = ?`, "completed")

	case "cancelled":
		query = query.Where("events.sub_status = ?", "cancelled")

		// case "all" → tidak perlu tambahan status
	}

	err := query.
		Select(`
			events.id AS event_id,
			events.title,
			events.start_date,
			events.location,
			events.status,
			events.sub_status,
			profiles.name AS host_name
		`).
		Order("events.start_date DESC").
		Scan(&events).Error

	return events, err
}

func (r *eventRepository) GetCompletedEventsByParticipant(userID uint) ([]response.ProfileCompletedEventDto, error) {
	var events []response.ProfileCompletedEventDto

	err := r.db.Table("participants").
		Joins("JOIN events ON events.id = participants.event_id").
		Joins("JOIN profiles ON profiles.user_id = events.user_id").
		Where("participants.user_id = ?", userID).
		Where("events.sub_status = ?", "completed").
		Select(`
			events.id AS event_id,
			events.title,
			profiles.name AS creator,
			events.start_date,
			events.description,
			events.cover_image
		`).
		Order("events.start_date DESC").
		Scan(&events).Error

	return events, err
}

func (r *eventRepository) GetApprovedEvents() ([]models.Event, error) {
	var events []models.Event
	err := r.db.
		Where("status = ?", "approved").
		Find(&events).Error
	return events, err
}

func (r *eventRepository) GetNearbyEvents(userID uint) ([]models.Event, error) {
	var events []models.Event

	err := r.db.
		Where("status = ?", "approved").
		Where("sub_status = ?", "opened").
		Where("user_id != ?", userID). // exclude own events
		Where("latitude IS NOT NULL").
		Where("longitude IS NOT NULL").
		Find(&events).Error

	return events, err
}
