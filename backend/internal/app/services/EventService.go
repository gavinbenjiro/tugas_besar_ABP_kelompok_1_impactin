package services

import (
	"errors"
	"sort"
	"strings"
	"time"

	"backend/internal/app/dtos/request"
	"backend/internal/app/dtos/response"
	"backend/internal/app/models"
	"backend/internal/app/repositories"
	"backend/internal/app/utils"

	"gorm.io/gorm"
)

type EventService interface {
	CreateEvent(userID uint, dto request.EventRequestDto) (response.EventResponseDto, error)
	GetAllEvents(category, search string, ageRanges []string) ([]response.EventListResponseDto, error)
	GetYourCreatedEvents(userID uint, status string) ([]response.YourEventResponseDto, error)
	GetYourCreatedEventDetail(userID, eventID uint) (*response.YourCreatedEventDetailResponseDto, error)
	GetEventDetail(eventID uint, userID uint) (*response.EventDetailResponseDto, error)
	GetCarouselEvents() (*response.EventCarouselResponseDto, error)
	GetRecommendedEvents(userID uint) (*response.EventRecommendationResponseDto, error)
	GetNearbyEvents(
		userID uint,
		latitude float64,
		longitude float64,
	) ([]response.NearbyEventResponseDto, error)
	JoinEvent(userID, eventID uint) (response.JoinEventResponseDto, error)
	AdminGetAllEvents(status, search string) ([]response.AdminEventsResponseDto, int64, error)
	AdminGetEventDetail(eventID uint) (response.EventResponseDto, error)
	AdminEventApproval(eventID uint, action string) (response.AdminEventApprovalResponseDto, error)
	HostApplicantApproval(hostID uint, eventID uint, dto request.HostApplicantApprovalRequestDto) (response.HostApplicantApprovalResponseDto, error)
	HostRemoveParticipant(hostID uint, eventID uint, dto request.HostRemoveParticipantRequestDto) (response.HostRemoveParticipantResponseDto, error)
	CancelEvent(eventID uint, userID *uint, adminID *uint) (response.CancelEventResponseDto, error)
	CloseEvent(userID, eventID uint) (response.EventSubStatusUpdateResponseDto, error)
	OpenEvent(userID, eventID uint) (response.EventSubStatusUpdateResponseDto, error)
	GetYourJoinedEvents(userID uint, status string) ([]response.YourEventResponseDto, error)
	AutoUpdateEventSubStatus() error
}

type eventService struct {
	eventRepo              repositories.EventRepository
	profileRepo            repositories.ProfileRepository
	applicantRepo          repositories.ApplicantRepository
	participantRepo        repositories.ParticipantRepository
	userRepo               *repositories.UserRepository
	notificationService    *NotificationService
	notificationHistorySvc *NotificationHistoryService
}

func (s *eventService) GetNearbyEvents(
	userID uint,
	latitude float64,
	longitude float64,
) ([]response.NearbyEventResponseDto, error) {

	events, err := s.eventRepo.GetNearbyEvents(userID)
	if err != nil {
		return nil, err
	}

	var result []response.NearbyEventResponseDto

	for _, event := range events {

		if event.Latitude == nil || event.Longitude == nil {
			continue
		}

		distance := utils.CalculateDistanceKM(
			latitude,
			longitude,
			*event.Latitude,
			*event.Longitude,
		)

		result = append(result, response.NearbyEventResponseDto{
			EventID:    event.ID,
			Title:      event.Title,
			Category:   event.Category,
			CoverImage: event.CoverImage,
			StartDate:  event.StartDate.Format("2006-01-02"),
			Location:   event.Location,
			DistanceKM: distance,
		})
	}

	sort.Slice(result, func(i, j int) bool {
		return result[i].DistanceKM < result[j].DistanceKM
	})

	if len(result) > 10 {
		result = result[:10]
	}

	return result, nil
}
func NewEventService(
	eventRepo repositories.EventRepository,
	profileRepo repositories.ProfileRepository,
	applicantRepo repositories.ApplicantRepository,
	participantRepo repositories.ParticipantRepository,
	userRepo *repositories.UserRepository,
	notificationService *NotificationService,
	notificationHistorySvc *NotificationHistoryService,
) EventService {

	return &eventService{
		eventRepo:              eventRepo,
		profileRepo:            profileRepo,
		applicantRepo:          applicantRepo,
		participantRepo:        participantRepo,
		userRepo:               userRepo,
		notificationService:    notificationService,
		notificationHistorySvc: notificationHistorySvc,
	}
}

func (s *eventService) CreateEvent(userID uint, dto request.EventRequestDto) (response.EventResponseDto, error) {

	// Validasi kategori
	validCategories := map[string]bool{
		"Environment": true,
		"Education":   true,
		"Community":   true,
		"Health":      true,
	}

	if !validCategories[strings.TrimSpace(dto.Category)] {
		return response.EventResponseDto{}, errors.New("invalid event category")
	}

	startDate, err := time.Parse("2006-01-02", dto.StartDate)
	if err != nil {
		return response.EventResponseDto{}, errors.New("invalid start_date format (YYYY-MM-DD)")
	}

	endDate, err := time.Parse("2006-01-02", dto.EndDate)
	if err != nil {
		return response.EventResponseDto{}, errors.New("invalid end_date format (YYYY-MM-DD)")
	}

	if endDate.Before(startDate) {
		return response.EventResponseDto{}, errors.New("end date cannot be before start date")
	}

	if startDate.Equal(endDate) {
		startTime, err := time.Parse("15:04", dto.StartTime)
		if err != nil {
			return response.EventResponseDto{}, errors.New("invalid start time format (HH:mm)")
		}

		endTime, err := time.Parse("15:04", dto.EndTime)
		if err != nil {
			return response.EventResponseDto{}, errors.New("invalid end time format (HH:mm)")
		}

		if endTime.Before(startTime) || endTime.Equal(startTime) {
			return response.EventResponseDto{}, errors.New("end time cannot be before or equal start time on the same day")
		}
	}

	if dto.MaxParticipant <= 0 {
		return response.EventResponseDto{}, errors.New("max participant must be greater than 0")
	}

	if dto.MinAge < 0 || dto.MaxAge < 0 {
		return response.EventResponseDto{}, errors.New("age cannot less than 0")
	}

	profile, err := s.profileRepo.GetByUserID(userID)
	if err != nil {
		return response.EventResponseDto{}, err
	}

	if profile.Name == nil || strings.TrimSpace(*profile.Name) == "" {
		return response.EventResponseDto{}, errors.New("profile name must be completed before creating event")
	}

	event := models.Event{
		UserID:             userID,
		Title:              dto.Title,
		Category:           dto.Category,
		Location:           dto.Location,
		SpecificAddress:    dto.SpecificAddress,
		AddressLink:        dto.AddressLink,
		StartDate:          startDate,
		EndDate:            endDate,
		StartTime:          dto.StartTime,
		EndTime:            dto.EndTime,
		MaxParticipant:     dto.MaxParticipant,
		CurrentParticipant: 0,
		CoverImage:         dto.CoverImage,
		Description:        dto.Description,
		Terms:              dto.Terms,
		MinAge:             dto.MinAge,
		MaxAge:             dto.MaxAge,
		GroupLink:          dto.GroupLink,
		Status:             "pending",
		SubStatus:          nil,

		Latitude:  dto.Latitude,
		Longitude: dto.Longitude,
	}

	if err := s.eventRepo.Create(&event); err != nil {
		return response.EventResponseDto{}, err
	}

	return response.EventResponseDto{
		UserID:          userID,
		HostName:        *profile.Name,
		EventID:         event.ID,
		Title:           event.Title,
		Category:        event.Category,
		Location:        event.Location,
		SpecificAddress: event.SpecificAddress,
		AddressLink:     event.AddressLink,
		StartDate:       event.StartDate.Format("2006-01-02"),
		EndDate:         event.EndDate.Format("2006-01-02"),
		StartTime:       event.StartTime,
		EndTime:         event.EndTime,
		MaxParticipant:  event.MaxParticipant,
		CoverImage:      event.CoverImage,
		Description:     event.Description,
		Terms:           event.Terms,
		MinAge:          event.MinAge,
		MaxAge:          event.MaxAge,
		GroupLink:       event.GroupLink,
		Status:          event.Status,
		Message:         "event created successfully, waiting for admin approval",
	}, nil
}

func (s *eventService) GetAllEvents(category, search string, ageRanges []string) ([]response.EventListResponseDto, error) {

	validCategories := map[string]bool{
		"Environment": true,
		"Health":      true,
		"Education":   true,
		"Community":   true,
	}

	if category != "" {
		if !validCategories[category] {
			return nil, errors.New("invalid category")
		}
	}

	events, err := s.eventRepo.GetAllEvents(category, search, ageRanges)
	if err != nil {
		return nil, err
	}

	var result []response.EventListResponseDto
	for _, event := range events {
		result = append(result, response.EventListResponseDto{
			EventID:    event.EventID,
			Title:      event.Title,
			Category:   event.Category,
			CoverImage: event.CoverImage,
			StartDate:  event.StartDate,
			Location:   event.Location,
			HostName:   event.HostName,
		})
	}

	return result, nil
}

func (s *eventService) GetYourCreatedEvents(userID uint, status string) ([]response.YourEventResponseDto, error) {

	validStatus := map[string]bool{
		"pending":   true,
		"approved":  true,
		"declined":  true,
		"cancelled": true,
		"completed": true,
		"all":       true,
	}

	if !validStatus[status] {
		return nil, errors.New("invalid status filter")
	}

	events, err := s.eventRepo.GetYourCreatedEvents(userID, status)
	if err != nil {
		return nil, err
	}

	return events, nil

}

func (s *eventService) GetYourCreatedEventDetail(userID, eventID uint) (*response.YourCreatedEventDetailResponseDto, error) {
	// 1. Ambil event (sekalian validasi ini milik host)
	event, err := s.eventRepo.GetEventByIDAndHost(eventID, userID)
	if err != nil {
		return nil, err
	}

	if event.Status != "approved" {
		return nil, errors.New("event is not approved")
	}

	if *event.SubStatus != "opened" && *event.SubStatus != "closed" {
		return nil, errors.New("event detail cannot be accessed in this state")
	}

	// 2. Ambil applicants
	applicants, err := s.eventRepo.GetApplicantsByEventID(eventID)
	if err != nil {
		return nil, err
	}

	// 3. Ambil participants
	participants, err := s.eventRepo.GetParticipantsByEventID(eventID)
	if err != nil {
		return nil, err
	}

	startT, _ := time.Parse("15:04", event.StartTime)
	startDateTime := time.Date(
		event.StartDate.Year(),
		event.StartDate.Month(),
		event.StartDate.Day(),
		startT.Hour(),
		startT.Minute(),
		0, 0, time.Local,
	)

	now := time.Now()

	canOpen := false
	if event.Status == "approved" &&
		event.SubStatus != nil &&
		*event.SubStatus == "closed" &&
		now.Before(startDateTime) &&
		event.CurrentParticipant < event.MaxParticipant {
		canOpen = true
	}

	canClose := false
	if event.Status == "approved" && event.SubStatus != nil && *event.SubStatus == "opened" {
		canClose = true
	}

	return &response.YourCreatedEventDetailResponseDto{
		EventID:            event.ID,
		Title:              event.Title,
		Location:           event.Location,
		StartDate:          event.StartDate,
		CurrentParticipant: event.CurrentParticipant,
		MaxParticipant:     event.MaxParticipant,
		Status:             event.Status,
		SubStatus:          *event.SubStatus,
		CanOpen:            canOpen,
		CanClose:           canClose,
		Applicants:         applicants,
		Participants:       participants,
		CoverImage:         event.CoverImage,
	}, nil
}

func (s *eventService) GetEventDetail(eventID uint, userID uint) (*response.EventDetailResponseDto, error) {
	event, hostID, groupLink, err := s.eventRepo.GetEventDetailByID(eventID)
	if err != nil {
		return nil, err
	}

	// default
	event.IsHost = false
	event.IsApplicant = false
	event.IsParticipant = false
	event.Message = "event detail retrieved successfully"

	if userID == hostID {
		event.IsHost = true
		event.GroupLink = groupLink
	}

	appExist, err := s.applicantRepo.IsAlreadyApplicant(userID, eventID)
	if err != nil {
		return &response.EventDetailResponseDto{}, err
	}
	if appExist {
		event.IsApplicant = true
	}

	parExist, err := s.participantRepo.IsAlreadyParticipant(userID, eventID)
	if err != nil {
		return &response.EventDetailResponseDto{}, err
	}
	if parExist {
		event.IsParticipant = true
		event.GroupLink = groupLink
	}

	return event, nil
}

func (s *eventService) GetCarouselEvents() (*response.EventCarouselResponseDto, error) {
	data, err := s.eventRepo.GetCarouselEvents()
	if err != nil {
		return nil, err
	}

	return &response.EventCarouselResponseDto{
		Health:      data["health"],
		Environment: data["environment"],
		Education:   data["education"],
		Community:   data["community"],
	}, nil
}

func (s *eventService) GetRecommendedEvents(userID uint) (*response.EventRecommendationResponseDto, error) {

	history, err := s.eventRepo.GetUserCategoryHistory(userID)
	if err != nil {
		return nil, err
	}

	// User belum pernah ikut event
	if len(history) == 0 {

		events, err := s.eventRepo.GetFallbackRecommendation()
		if err != nil {
			return nil, err
		}

		return &response.EventRecommendationResponseDto{
			Events: events,
		}, nil
	}

	candidates, err := s.eventRepo.GetRecommendationCandidates(userID)
	if err != nil {
		return nil, err
	}

	for i := range candidates {
		candidates[i].Score = history[candidates[i].Category]
	}

	sort.Slice(candidates, func(i, j int) bool {

		// score sama → pilih yang tanggalnya lebih dekat
		if candidates[i].Score == candidates[j].Score {
			return candidates[i].StartDate.Before(candidates[j].StartDate)
		}

		return candidates[i].Score > candidates[j].Score
	})

	if len(candidates) > 4 {
		candidates = candidates[:4]
	}

	var result []response.EventRecommendationItemDto

	for _, c := range candidates {
		result = append(result, response.EventRecommendationItemDto{
			EventID:    c.EventID,
			Title:      c.Title,
			Category:   c.Category,
			CoverImage: c.CoverImage,
			StartDate:  c.StartDate.Format("2006-01-02"),
			Location:   c.Location,
			HostName:   c.HostName,
		})
	}

	return &response.EventRecommendationResponseDto{
		Events: result,
	}, nil
}

func (s *eventService) JoinEvent(userID, eventID uint) (response.JoinEventResponseDto, error) {
	// 1. Event
	event, err := s.eventRepo.GetEventForJoin(eventID)
	if err != nil {
		return response.JoinEventResponseDto{}, errors.New("event not found")
	}

	// 2. Status
	if event.Status != "approved" || event.SubStatus != "opened" {
		return response.JoinEventResponseDto{}, errors.New("event is not open for joining")
	}

	// 3. Profile
	profile, err := s.profileRepo.GetByUserID(userID)
	if err != nil {
		return response.JoinEventResponseDto{}, errors.New("profile not found")
	}
	if profile.UserID == event.UserID {
		return response.JoinEventResponseDto{}, errors.New("cannot join your own event")
	}
	if profile.Age == nil || *profile.Age <= 0 {
		return response.JoinEventResponseDto{}, errors.New("profile age must be completed before joining event")
	}
	if profile.Name == nil || strings.TrimSpace(*profile.Name) == "" {
		return response.JoinEventResponseDto{}, errors.New("profile name must be completed before joining event")
	}

	// 4. Age validation
	switch {
	case event.MinAge == 0 && event.MaxAge == 0:
		// all ages allowed
	case event.MinAge == 0 && *profile.Age > event.MaxAge:
		return response.JoinEventResponseDto{}, errors.New("age exceeds maximum limit")
	case event.MaxAge == 0 && *profile.Age < event.MinAge:
		return response.JoinEventResponseDto{}, errors.New("age does not meet minimum requirement")
	case *profile.Age < event.MinAge || *profile.Age > event.MaxAge:
		return response.JoinEventResponseDto{}, errors.New("age not within allowed range")
	}

	// 5. Duplicate join
	appExist, err := s.applicantRepo.IsAlreadyApplicant(userID, eventID)
	if err != nil {
		return response.JoinEventResponseDto{}, err
	}
	if appExist {
		return response.JoinEventResponseDto{}, errors.New("you already joining this event, waiting for host approval")
	}

	parExist, err := s.participantRepo.IsAlreadyParticipant(userID, eventID)
	if err != nil {
		return response.JoinEventResponseDto{}, err
	}
	if parExist {
		return response.JoinEventResponseDto{}, errors.New("you already joined this event")
	}

	// 6. Save
	applicant := &models.Applicant{
		EventID: eventID,
		UserID:  userID,
	}
	if err := s.applicantRepo.Create(applicant); err != nil {
		return response.JoinEventResponseDto{}, err
	}

	return response.JoinEventResponseDto{
		EventID: applicant.EventID,
		UserID:  applicant.UserID,
		Name:    *profile.Name,
		Age:     *profile.Age,
		Message: "successfully joining event, waiting for host approval",
	}, nil
}

func (s *eventService) AdminGetAllEvents(status, search string) ([]response.AdminEventsResponseDto, int64, error) {
	validStatus := map[string]bool{
		"pending":  true,
		"approved": true,
		"declined": true,
	}

	if !validStatus[status] {
		return nil, 0, errors.New("invalid status filter")
	}

	return s.eventRepo.AdminGetAllEvents(status, search)
}

func (s *eventService) AdminGetEventDetail(eventID uint) (response.EventResponseDto, error) {

	event, err := s.eventRepo.AdminGetEventDetail(eventID)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return response.EventResponseDto{}, errors.New("event not found")
		}
		return response.EventResponseDto{}, err
	}

	event.Message = "success"

	return *event, nil
}

func (s *eventService) AdminEventApproval(eventID uint, action string) (response.AdminEventApprovalResponseDto, error) {

	event, err := s.eventRepo.GetEventByID(eventID)
	if err != nil {
		return response.AdminEventApprovalResponseDto{}, errors.New("event not found")
	}

	if event.Status != "pending" {
		return response.AdminEventApprovalResponseDto{}, errors.New("event already processed")
	}

	switch action {
	case "accept":
		event.Status = "approved"
		subStatus, err := utils.DetermineSubStatus(event.StartDate, event.StartTime, event.EndDate, event.EndTime)
		if err != nil {
			return response.AdminEventApprovalResponseDto{}, err
		}
		event.SubStatus = &subStatus

	case "reject":
		event.Status = "declined"
		event.SubStatus = nil

	default:
		return response.AdminEventApprovalResponseDto{}, errors.New("invalid action")
	}

	if err := s.eventRepo.UpdateApprovalStatus(event); err != nil {
		return response.AdminEventApprovalResponseDto{}, err
	}

	title := ""
	message := ""

	if action == "accept" {
		title = "Event Approved"
		message = "Your event \"" + event.Title + "\" has been approved."
	} else {
		title = "Event Rejected"
		message = "Your event \"" + event.Title + "\" has been rejected."
	}

	_ = s.notificationHistorySvc.CreateNotification(
		event.UserID,
		title,
		message,
	)

	_ = s.userRepo.UpdateHasUnreadNotification(
		event.UserID,
		true,
	)

	tokens, err := s.userRepo.GetFCMTokensByUserID(
		event.UserID,
	)

	if err == nil {

		body := message

		for _, token := range tokens {

			_ = s.notificationService.SendToToken(
				token,
				title,
				body,
			)
		}
	}

	return response.AdminEventApprovalResponseDto{
		EventID:   event.ID,
		Status:    event.Status,
		SubStatus: event.SubStatus,
		Message:   "event successfully " + action + "ed",
	}, nil
}

func (s *eventService) HostApplicantApproval(hostID uint, eventID uint, dto request.HostApplicantApprovalRequestDto) (response.HostApplicantApprovalResponseDto, error) {

	// 1. Ambil event
	event, err := s.eventRepo.GetEventByID(eventID)
	if err != nil {
		return response.HostApplicantApprovalResponseDto{}, errors.New("event not found")
	}

	// 2. Validasi host
	if event.UserID != hostID {
		return response.HostApplicantApprovalResponseDto{}, errors.New("only host can manage applicants")
	}

	// 3. Cek applicant & participant
	appExist, err := s.applicantRepo.IsAlreadyApplicant(dto.UserID, eventID)
	if err != nil {
		return response.HostApplicantApprovalResponseDto{}, err
	}
	if !appExist {
		return response.HostApplicantApprovalResponseDto{}, errors.New("applicant not found")
	}

	parExist, err := s.participantRepo.IsAlreadyParticipant(dto.UserID, eventID)
	if err != nil {
		return response.HostApplicantApprovalResponseDto{}, err
	}
	if parExist {
		return response.HostApplicantApprovalResponseDto{}, errors.New("applicant already in participant")
	}

	profile, err := s.profileRepo.GetByUserID(dto.UserID)
	if err != nil {
		return response.HostApplicantApprovalResponseDto{}, errors.New("applicant profile not found")
	}

	switch dto.Action {

	case "reject":
		if err := s.applicantRepo.Delete(dto.UserID, eventID); err != nil {
			return response.HostApplicantApprovalResponseDto{}, err
		}

	case "approve":
		// cek kuota
		if event.CurrentParticipant >= event.MaxParticipant {
			return response.HostApplicantApprovalResponseDto{}, errors.New("event is already full")
		}

		// TRANSACTION
		err := s.eventRepo.WithTx(func(tx *gorm.DB) error {
			if err := s.participantRepo.Create(tx, &models.Participant{
				UserID:  dto.UserID,
				EventID: eventID,
			}); err != nil {
				return err
			}

			if err := s.applicantRepo.DeleteTx(tx, dto.UserID, eventID); err != nil {
				return err
			}

			if err := s.eventRepo.IncrementParticipant(tx, eventID); err != nil {
				return err
			}
			event.CurrentParticipant++

			// kalau penuh → closed
			if event.CurrentParticipant >= event.MaxParticipant {
				sub := "closed"
				return tx.Model(&models.Event{}).
					Where("id = ?", eventID).
					Update("sub_status", &sub).Error
			}

			return nil
		})

		if err != nil {
			return response.HostApplicantApprovalResponseDto{}, err
		}

	default:
		return response.HostApplicantApprovalResponseDto{}, errors.New("invalid action")
	}

	return response.HostApplicantApprovalResponseDto{
		EventID:            eventID,
		UserID:             dto.UserID,
		Name:               *profile.Name,
		Action:             dto.Action,
		CurrentParticipant: event.CurrentParticipant,
		Message:            "success",
	}, nil
}

func (s *eventService) HostRemoveParticipant(hostID uint, eventID uint, dto request.HostRemoveParticipantRequestDto) (response.HostRemoveParticipantResponseDto, error) {
	// 1. Ambil event
	event, err := s.eventRepo.GetEventByID(eventID)
	if err != nil {
		return response.HostRemoveParticipantResponseDto{}, errors.New("event not found")
	}

	// 2. Validasi host
	if event.UserID != hostID {
		return response.HostRemoveParticipantResponseDto{}, errors.New("only host can remove participant")
	}

	// 3. Pastikan participant ada
	exist, err := s.participantRepo.IsAlreadyParticipant(dto.UserID, eventID)
	if err != nil {
		return response.HostRemoveParticipantResponseDto{}, err
	}
	if !exist {
		return response.HostRemoveParticipantResponseDto{}, errors.New("participant not found")
	}

	profile, err := s.profileRepo.GetByUserID(dto.UserID)
	if err != nil {
		return response.HostRemoveParticipantResponseDto{}, errors.New("participant profile not found")
	}

	// 4. Hapus participant
	if err := s.participantRepo.Delete(dto.UserID, eventID); err != nil {
		return response.HostRemoveParticipantResponseDto{}, err
	}

	// 5. Kurangi current_participant (aman)
	if event.CurrentParticipant > 0 {
		if err := s.eventRepo.DecrementParticipant(eventID); err != nil {
			return response.HostRemoveParticipantResponseDto{}, err
		}
		event.CurrentParticipant--
	}

	// KOMEN DINYALAIN KALAU MAU OTOMATIS OPEN EVENT SAAT MAX PARTICIPANT TIDAK PENUH
	// if event.Status == "approved" && event.SubStatus != nil {
	// 	if *event.SubStatus == "closed" && event.CurrentParticipant < event.MaxParticipant {

	// 		subStatus, err := utils.DetermineSubStatus(
	// 			event.StartDate,
	// 			event.StartTime,
	// 			event.EndDate,
	// 			event.EndTime,
	// 		)
	// 		if err != nil {
	// 			return response.HostRemoveParticipantResponseDto{}, err
	// 		}

	// 		// hanya update kalau opened
	// 		if subStatus == "opened" {
	// 			if err := s.eventRepo.UpdateSubStatus(eventID, subStatus); err != nil {
	// 				return response.HostRemoveParticipantResponseDto{}, err
	// 			}
	// 		}
	// 	}
	// }

	return response.HostRemoveParticipantResponseDto{
		EventID:            eventID,
		UserID:             dto.UserID,
		Name:               *profile.Name,
		CurrentParticipant: event.CurrentParticipant,
		Message:            "participant removed successfully",
	}, nil
}

func (s *eventService) CancelEvent(eventID uint, userID *uint, adminID *uint) (response.CancelEventResponseDto, error) {
	event, err := s.eventRepo.GetEventByID(eventID)
	if err != nil {
		return response.CancelEventResponseDto{}, errors.New("event not found")
	}

	if event.Status != "approved" {
		return response.CancelEventResponseDto{}, errors.New("event cannot be cancelled")
	}

	if event.SubStatus == nil || (*event.SubStatus != "opened" && *event.SubStatus != "closed") {
		if *event.SubStatus == "cancelled" {
			return response.CancelEventResponseDto{}, errors.New("event already cancelled")
		}
		return response.CancelEventResponseDto{}, errors.New("event cannot be cancelled")
	}

	if adminID == nil {
		if userID == nil || event.UserID != *userID {
			return response.CancelEventResponseDto{}, errors.New("only host or admin can cancel this event")
		}
	}

	subStatus := "cancelled"
	event.SubStatus = &subStatus

	if err := s.eventRepo.UpdateSubStatus(eventID, subStatus); err != nil {
		return response.CancelEventResponseDto{}, err
	}

	profile, err := s.profileRepo.GetByUserID(event.UserID)
	if err != nil {
		return response.CancelEventResponseDto{}, errors.New("host profile not found")
	}

	return response.CancelEventResponseDto{
		EventID:   event.ID,
		Title:     event.Title,
		HostName:  *profile.Name,
		Status:    event.Status,
		SubStatus: event.SubStatus,
	}, nil
}

func (s *eventService) CloseEvent(userID, eventID uint) (response.EventSubStatusUpdateResponseDto, error) {
	event, err := s.eventRepo.GetEventByID(eventID)
	if err != nil {
		return response.EventSubStatusUpdateResponseDto{}, errors.New("event not found")
	}

	// host only
	if event.UserID != userID {
		return response.EventSubStatusUpdateResponseDto{}, errors.New("only host can close this event")
	}

	if event.Status != "approved" || (event.SubStatus != nil && *event.SubStatus != "opened") {
		return response.EventSubStatusUpdateResponseDto{}, errors.New("event cannot be closed")
	}

	subStatus := "closed"

	if err := s.eventRepo.UpdateSubStatus(event.ID, subStatus); err != nil {
		return response.EventSubStatusUpdateResponseDto{}, err
	}

	return response.EventSubStatusUpdateResponseDto{
		EventID:   event.ID,
		Title:     event.Title,
		Status:    event.Status,
		SubStatus: subStatus,
		Message:   "event successfully closed",
	}, nil
}

func (s *eventService) OpenEvent(userID, eventID uint) (response.EventSubStatusUpdateResponseDto, error) {
	event, err := s.eventRepo.GetEventByID(eventID)
	if err != nil {
		return response.EventSubStatusUpdateResponseDto{}, errors.New("event not found")
	}

	// host only
	if event.UserID != userID {
		return response.EventSubStatusUpdateResponseDto{}, errors.New("only host can open this event")
	}

	if event.Status != "approved" || (event.SubStatus != nil && *event.SubStatus != "closed") {
		return response.EventSubStatusUpdateResponseDto{}, errors.New("event cannot be opened")
	}

	if event.CurrentParticipant >= event.MaxParticipant {
		return response.EventSubStatusUpdateResponseDto{}, errors.New("event cannot be opened because is already full")
	}

	subStatus, err := utils.DetermineSubStatus(
		event.StartDate,
		event.StartTime,
		event.EndDate,
		event.EndTime,
	)
	if err != nil {
		return response.EventSubStatusUpdateResponseDto{}, err
	}

	if subStatus != "opened" {
		return response.EventSubStatusUpdateResponseDto{}, errors.New("event cannot be opened at this time")
	}

	if err := s.eventRepo.UpdateSubStatus(event.ID, "opened"); err != nil {
		return response.EventSubStatusUpdateResponseDto{}, err
	}

	return response.EventSubStatusUpdateResponseDto{
		EventID:   event.ID,
		Title:     event.Title,
		Status:    event.Status,
		SubStatus: "opened",
		Message:   "event successfully opened",
	}, nil
}

func (s *eventService) GetYourJoinedEvents(userID uint, status string) ([]response.YourEventResponseDto, error) {
	validStatus := map[string]bool{
		"all":       true,
		"ongoing":   true,
		"upcoming":  true,
		"completed": true,
		"cancelled": true,
	}

	if !validStatus[status] {
		return nil, errors.New("invalid status filter")
	}

	events, err := s.eventRepo.GetJoinedEvents(userID, status)
	if err != nil {
		return nil, err
	}

	return events, nil
}

func (s *eventService) AutoUpdateEventSubStatus() error {
	events, err := s.eventRepo.GetApprovedEvents()
	if err != nil {
		return err
	}

	for _, event := range events {
		newSubStatus, err := utils.DetermineSubStatus(
			event.StartDate,
			event.StartTime,
			event.EndDate,
			event.EndTime,
		)
		if err != nil {
			continue
		}

		if event.SubStatus == nil || *event.SubStatus == "cancelled" {
			continue
		}

		if *event.SubStatus == "closed" && newSubStatus == "opened" {
			continue
		}

		if *event.SubStatus != newSubStatus {
			_ = s.eventRepo.UpdateSubStatus(event.ID, newSubStatus)
		}
	}
	return nil
}
