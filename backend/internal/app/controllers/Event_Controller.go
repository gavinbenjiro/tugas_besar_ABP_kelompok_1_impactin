package controllers

import (
	"net/http"
	"strconv"

	"backend/internal/app/dtos/request"
	"backend/internal/app/services"

	"github.com/gin-gonic/gin"
)

type EventController struct {
   eventService services.EventService
   profileService services.ProfileService
}

func NewEventController(eventService services.EventService, profileService services.ProfileService) *EventController {
   return &EventController{eventService, profileService}
}

func (c *EventController) CreateEvent(ctx *gin.Context) {
   uid, exists := ctx.Get("user_id")
   if !exists {
       ctx.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
       return
   }

   userID := uid.(uint)

   // Ambil profile berdasarkan user_id
   profile, err := c.profileService.GetByUserID(userID)
   if err != nil {
       ctx.JSON(http.StatusBadRequest, gin.H{"error": "profile not found"})
       return
   }

   var req request.EventRequestDto
   if err := ctx.ShouldBindJSON(&req); err != nil {
       ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
       return
   }

   resp, err := c.eventService.CreateEvent(profile.UserID, req)
   if err != nil {
       ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
       return
   }

   ctx.JSON(http.StatusCreated, resp)
}

func (c *EventController) GetAllEvents(ctx *gin.Context) {
    category := ctx.Query("category")
    search := ctx.Query("search")
	ageRanges := ctx.QueryArray("age")

	resp, err := c.eventService.GetAllEvents(category, search, ageRanges)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{
			"error": err.Error(),
		})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{
		"message": "events retrieved",
		"data":    resp,
	})
}

func (c *EventController) GetYourCreatedEvents(ctx *gin.Context) {
	uid, exists := ctx.Get("user_id")
	status := ctx.Query("status")

    if !exists {
        ctx.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
        return
    }

	if status == "" {
		ctx.JSON(http.StatusBadRequest, gin.H{
			"error": "status query is required",
		})
		return
	}

    userID := uid.(uint)

	profile, err := c.profileService.GetByUserID(userID)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	events, err := c.eventService.GetYourCreatedEvents(profile.UserID, status)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

    ctx.JSON(http.StatusOK, gin.H{
		"message": "events retrieved",
		"data":    events,
	})
}

func (c *EventController) GetYourCreatedEventDetail(ctx *gin.Context) {
	uid, exists := ctx.Get("user_id")
	eventIDParam := ctx.Param("event_id")

	if !exists {
        ctx.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
        return
    }

	eventID, err := strconv.Atoi(eventIDParam)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "invalid event id"})
		return
	}

	result, err := c.eventService.GetYourCreatedEventDetail(uid.(uint), uint(eventID))
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{
			"message": err.Error(),
		})
		return
	}

	ctx.JSON(http.StatusOK, result)
}

func (c *EventController) GetEventDetail(ctx *gin.Context) {
    uid, exists := ctx.Get("user_id")
	eventIDParam := ctx.Param("event_id")

    if !exists {
        ctx.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
        return
    }

	eventID, err := strconv.Atoi(eventIDParam)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "invalid event id"})
		return
	}

    userID := uid.(uint)

    profile, err := c.profileService.GetByUserID(userID)
    if err == nil {
        userID = profile.UserID
    }

	event, err := c.eventService.GetEventDetail(uint(eventID), userID)
	if err != nil {
		ctx.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusOK, event)
}

func (c *EventController) GetCarouselEvents(ctx *gin.Context) {
	events, err := c.eventService.GetCarouselEvents()
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{
			"message": "failed to fetch carousel events",
		})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{
		"message": "success",
		"data":    events,
	})
}

func (c *EventController) GetRecommendedEvents(ctx *gin.Context) {

	userID, exists := ctx.Get("user_id")
	if !exists {
		ctx.JSON(http.StatusUnauthorized, gin.H{
			"message": "unauthorized",
		})
		return
	}

	resp, err := c.eventService.GetRecommendedEvents(userID.(uint))
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{
			"message": err.Error(),
		})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{
		"message": "success",
		"data": resp.Events,
	})
}

func (c *EventController) JoinEvent(ctx *gin.Context) {
	uid, exists := ctx.Get("user_id")
	eventIDParam := ctx.Param("event_id")

	if !exists {
        ctx.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
        return
    }

	eventID, err := strconv.Atoi(eventIDParam)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "invalid event id"})
		return
	}

	userID := uid.(uint)
	resp, err := c.eventService.JoinEvent(userID, uint(eventID))
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"message": err.Error()})
		return
	}

	ctx.JSON(http.StatusOK, resp)
}

func (c *EventController) AdminGetAllEvents(ctx *gin.Context) {
	search := ctx.Query("search")
	status := ctx.Query("status")

	if status == "" {
		ctx.JSON(http.StatusBadRequest, gin.H{
			"error": "status is required (pending | approved | declined)",
		})
		return
	}

	events, total, err := c.eventService.AdminGetAllEvents(status, search)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{
		"total":  total,
		"events": events,
	})
}

func (c *EventController) AdminGetEventDetail(ctx *gin.Context) {

	// pastikan admin auth sudah jalan
	if _, exists := ctx.Get("admin_id"); !exists {
		ctx.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}

	eventIDParam := ctx.Param("event_id")
	eventID, err := strconv.Atoi(eventIDParam)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "invalid event id"})
		return
	}

	resp, err := c.eventService.AdminGetEventDetail(uint(eventID))
	if err != nil {
		ctx.JSON(http.StatusNotFound, gin.H{"message": err.Error()})
		return
	}

	ctx.JSON(http.StatusOK, resp)
}

func (c *EventController) AdminEventApproval(ctx *gin.Context) {
	// pastikan middleware admin sudah set ini
	_, exists := ctx.Get("admin_id")
	if !exists {
		ctx.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}

	eventIDParam := ctx.Param("event_id")
	eventID, err := strconv.Atoi(eventIDParam)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "invalid event id"})
		return
	}

	var req request.AdminApprovalRequestDto
	if err := ctx.ShouldBindJSON(&req); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	resp, err := c.eventService.AdminEventApproval(uint(eventID), req.Action)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusOK, resp)
}

func (c *EventController) HostApplicantApproval(ctx *gin.Context) {
	uid, exists := ctx.Get("user_id")
	if !exists {
		ctx.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}

	eventID, err := strconv.Atoi(ctx.Param("event_id"))
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "invalid event id"})
		return
	}

	var req request.HostApplicantApprovalRequestDto
	if err := ctx.ShouldBindJSON(&req); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	resp, err := c.eventService.HostApplicantApproval(uid.(uint), uint(eventID), req)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"message": err.Error()})
		return
	}

	ctx.JSON(http.StatusOK, resp)
}

func (c *EventController) HostRemoveParticipant(ctx *gin.Context) {
	eventIDParam := ctx.Param("event_id")

	uid, exists := ctx.Get("user_id")
	if !exists {
		ctx.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}

	eventID, err := strconv.Atoi(eventIDParam)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "invalid event id"})
		return
	}

	var dto request.HostRemoveParticipantRequestDto
	if err := ctx.ShouldBindJSON(&dto); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	resp, err := c.eventService.HostRemoveParticipant(uid.(uint), uint(eventID), dto)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusOK, resp)
}

func (c *EventController) CancelEvent(ctx *gin.Context) {
	eventIDParam := ctx.Param("event_id")
	eventID, err := strconv.Atoi(eventIDParam)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{
			"message": "invalid event id",
		})
		return
	}

	var userID *uint
	if uid, exists := ctx.Get("user_id"); exists {
		u := uid.(uint)
		userID = &u
	}

	var adminID *uint
	if aid, exists := ctx.Get("admin_id"); exists {
		a := aid.(uint)
		adminID = &a
	}
	
	resp, err := c.eventService.CancelEvent(uint(eventID), userID, adminID)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{
			"message": err.Error(),
		})
		return
	}

	ctx.JSON(http.StatusOK, resp)
}

func (c *EventController) CloseEvent(ctx *gin.Context) {
	uid, _ := ctx.Get("user_id")
	eventID, _ := strconv.Atoi(ctx.Param("event_id"))

	resp, err := c.eventService.CloseEvent(uid.(uint), uint(eventID))
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"message": err.Error()})
		return
	}

	ctx.JSON(http.StatusOK, resp)
}

func (c *EventController) OpenEvent(ctx *gin.Context) {
	uid, _ := ctx.Get("user_id")
	eventID, _ := strconv.Atoi(ctx.Param("event_id"))

	resp, err := c.eventService.OpenEvent(uid.(uint), uint(eventID))
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"message": err.Error()})
		return
	}

	ctx.JSON(http.StatusOK, resp)
}

func (c *EventController) GetYourJoinedEvents(ctx *gin.Context) {
	uid, exists := ctx.Get("user_id")
	if !exists {
		ctx.JSON(http.StatusUnauthorized, gin.H{"message": "unauthorized"})
		return
	}

	userID := uid.(uint)
	status := ctx.DefaultQuery("status", "all")

	events, err := c.eventService.GetYourJoinedEvents(userID, status)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{
		"data": events,
	})
}
