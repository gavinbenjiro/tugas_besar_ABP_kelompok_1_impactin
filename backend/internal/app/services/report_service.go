package services

import (
	"backend/internal/app/dtos/request"
	"backend/internal/app/dtos/response"
	"backend/internal/app/models"
	"backend/internal/app/repositories"
	"errors"
)

type ReportService interface {
	CreateReportEvent(userID uint, eventID uint, dto request.ReportEventRequestDto,) (response.ReportEventResponseDto, error)
	AdminGetAllReportedEvents(status, search string) ([]response.AdminReportedEventsResponseDto, int64, error)
	AdminGetReportDetail(reportID uint) (*response.AdminReportedEventDetailResponseDto, error)
	ResolveReport(reportID uint, req request.AdminResolveReportRequestDto) (*response.AdminResolveReportResponseDto, error)
}

type reportService struct {
	reportRepo repositories.ReportRepository
	eventRepo repositories.EventRepository
	participantRepo repositories.ParticipantRepository
	profileRepo repositories.ProfileRepository
}

func NewReportService(
	reportRepo repositories.ReportRepository,
	eventRepo repositories.EventRepository,
	participantRepo repositories.ParticipantRepository,
	profileRepo repositories.ProfileRepository) ReportService {
	return &reportService{reportRepo, eventRepo, participantRepo, profileRepo}
}

func (s *reportService) CreateReportEvent(userID uint, eventID uint, dto request.ReportEventRequestDto,) (response.ReportEventResponseDto, error) {

	// 1️⃣ Ambil event
	event, err := s.eventRepo.GetEventByID(eventID)
	if err != nil {
		return response.ReportEventResponseDto{}, errors.New("event not found")
	}

	// 2️⃣ Validasi status
	if event.Status != "approved" {
		return response.ReportEventResponseDto{}, errors.New("event cannot be reported")
	}

	// 3️⃣ Host tidak boleh report
	if event.UserID == userID {
		return response.ReportEventResponseDto{}, errors.New("host cannot report own event")
	}

	// 4️⃣ Validasi sub status
	switch *event.SubStatus {
	case "opened", "closed":
		// semua user boleh

	case "completed":
		isParticipant, err := s.participantRepo.IsAlreadyParticipant(userID, eventID)
		if err != nil {
			return response.ReportEventResponseDto{}, err
		}
		if !isParticipant {
			return response.ReportEventResponseDto{}, errors.New("only participant can report completed event")
		}

	default:
		return response.ReportEventResponseDto{}, errors.New("event already cancelled")
	}

	// 5️⃣ Simpan report
	report := &models.Report{
		UserID:      userID,
		EventID:     eventID,
		Description: dto.Description,
		Status:      "pending",
	}

	if err := s.reportRepo.Create(report); err != nil {
		return response.ReportEventResponseDto{}, err
	}

	// 6️⃣ Ambil host name
	hostProfile, err := s.profileRepo.GetByUserID(event.UserID)
	if err != nil {
		return response.ReportEventResponseDto{}, errors.New("host profile not found")
	}

	return response.ReportEventResponseDto{
		UserID:      userID,
		EventID:     eventID,
		EventTitle:  event.Title,
		HostName:    *hostProfile.Name,
		Description: report.Description,
		ReportedAt:  report.CreatedAt.Format("2006-01-02"),
	}, nil
}

func (s *reportService) AdminGetAllReportedEvents(status, search string) ([]response.AdminReportedEventsResponseDto, int64, error) {
	validStatus := map[string]bool{
		"pending": true,
		"resolved": true,
	}

	if !validStatus[status] {
		return nil, 0, errors.New("invalid status filter")
	}

	return s.reportRepo.AdminGetAllReportedEvents(status, search)
}

func (s *reportService) AdminGetReportDetail(reportID uint) (*response.AdminReportedEventDetailResponseDto, error) {
	return s.reportRepo.AdminGetReportDetail(reportID)
}

func (s *reportService) ResolveReport(reportID uint, req request.AdminResolveReportRequestDto) (*response.AdminResolveReportResponseDto, error) {
	report, err := s.reportRepo.GetReportByID(reportID)
	if err != nil {
		return nil, errors.New("report not found")
	}

	err = s.reportRepo.ResolveReport(report, req.AdminResponse)
	if err != nil {
		return nil, err
	}

	return &response.AdminResolveReportResponseDto{
		ReportID:      report.ID,
		Status:        report.Status,
		AdminResponse: *report.AdminResponse,
		RespondedAt:   *report.RespondedAt,
	}, nil
}