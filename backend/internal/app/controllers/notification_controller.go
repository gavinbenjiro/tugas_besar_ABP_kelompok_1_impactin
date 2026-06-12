package controllers

import (
	"net/http"

	"backend/internal/app/services"

	"github.com/gin-gonic/gin"
)

type NotificationController struct {
	service *services.NotificationHistoryService
}

func NewNotificationController(
	service *services.NotificationHistoryService,
) *NotificationController {

	return &NotificationController{
		service: service,
	}
}

func (c *NotificationController) GetBellStatus(
	ctx *gin.Context,
) {

	uid, exists := ctx.Get("user_id")
	if !exists {
		ctx.JSON(
			http.StatusUnauthorized,
			gin.H{"error": "unauthorized"},
		)
		return
	}

	hasUnread, err := c.service.GetBellStatus(
		uid.(uint),
	)

	if err != nil {
		ctx.JSON(
			http.StatusInternalServerError,
			gin.H{"error": err.Error()},
		)
		return
	}

	ctx.JSON(
		http.StatusOK,
		gin.H{
			"has_unread": hasUnread,
		},
	)
}

func (c *NotificationController) MarkBellRead(
	ctx *gin.Context,
) {

	uid, exists := ctx.Get("user_id")
	if !exists {
		ctx.JSON(
			http.StatusUnauthorized,
			gin.H{"error": "unauthorized"},
		)
		return
	}

	err := c.service.MarkBellRead(
		uid.(uint),
	)

	if err != nil {
		ctx.JSON(
			http.StatusInternalServerError,
			gin.H{"error": err.Error()},
		)
		return
	}

	ctx.JSON(
		http.StatusOK,
		gin.H{
			"message": "notification marked as read",
		},
	)
}

func (c *NotificationController) GetNotifications(
	ctx *gin.Context,
) {

	uid, exists := ctx.Get("user_id")
	if !exists {
		ctx.JSON(
			http.StatusUnauthorized,
			gin.H{"error": "unauthorized"},
		)
		return
	}

	notifications, err :=
		c.service.GetNotifications(
			uid.(uint),
		)

	if err != nil {
		ctx.JSON(
			http.StatusInternalServerError,
			gin.H{"error": err.Error()},
		)
		return
	}

	ctx.JSON(
		http.StatusOK,
		gin.H{
			"data": notifications,
		},
	)
}
