package routes

import (
	"backend/internal/app/controllers"
	"backend/internal/app/utils"

	"github.com/gin-gonic/gin"
)

func EventRoutes(router *gin.Engine, eventController *controllers.EventController) {
	r := router.Group("api/user/events")
	{
		r.GET("/", eventController.GetAllEvents)
		r.GET("/carousel", eventController.GetCarouselEvents)
	}

	auth := router.Group("api/user/events")
	auth.Use(utils.Auth()) // JWT middleware
	{
		auth.POST("/", eventController.CreateEvent)
		auth.GET("/your", eventController.GetYourCreatedEvents)
		auth.GET("/your/:event_id", eventController.GetYourCreatedEventDetail)
		auth.GET("joined", eventController.GetYourJoinedEvents)
		auth.GET("/:event_id", eventController.GetEventDetail)
		auth.GET("/recommendation", eventController.GetRecommendedEvents)
		auth.POST("/join/:event_id", eventController.JoinEvent)
		auth.PATCH("/applicants/:event_id", eventController.HostApplicantApproval)
		auth.DELETE("/participants/:event_id", eventController.HostRemoveParticipant)
		auth.PATCH("/cancel/:event_id", eventController.CancelEvent)
		auth.PATCH("/close/:event_id", eventController.CloseEvent)
		auth.PATCH("/open/:event_id", eventController.OpenEvent)
		auth.POST("/nearby", eventController.GetNearbyEvents)
	}

	authAdmin := router.Group("api/admin/events")
	authAdmin.Use(utils.AdminAuth()) // JWT middleware
	{
		authAdmin.GET("/", eventController.AdminGetAllEvents)
		authAdmin.GET("/:event_id", eventController.AdminGetEventDetail)
		authAdmin.PATCH("/approval/:event_id", eventController.AdminEventApproval)
		authAdmin.PATCH("/cancel/:event_id", eventController.CancelEvent)
	}
}

func ReportRoutes(router *gin.Engine, reportController *controllers.ReportController) {
	r := router.Group("/api/user/events")
	r.Use(utils.Auth())
	{
		r.POST("/report/:event_id", reportController.CreateEventReport)
	}

	authAdmin := router.Group("api/admin/events")
	authAdmin.Use(utils.AdminAuth())
	{
		authAdmin.GET("/report", reportController.AdminGetAllReportedEvents)
		authAdmin.GET("/report/:report_id", reportController.AdminGetReportedEventDetail)
		authAdmin.PATCH("/report/resolve/:report_id", reportController.ResolveReport)
	}
}

func UserRoutes(router *gin.Engine, userController *controllers.UserController) {
	r := router.Group("/api/user")
	{
		r.POST("/register", userController.Register)
		r.POST("/login", userController.Login)
	}

	auth := router.Group("/api/user")
	auth.Use(utils.Auth())
	{
		auth.POST("/fcm-token", userController.SaveFCMToken)
		auth.POST("/logout", userController.Logout) // ADD THIS
	}
}

func AdminRoutes(router *gin.Engine, adminController *controllers.AdminController) {
	r := router.Group("/api/admin")
	{
		r.POST("/login", adminController.Login)
	}
}

func ProfileRoutes(router *gin.Engine, profileController *controllers.ProfileController) {
	r := router.Group("/api/user/profile")
	r.Use(utils.Auth()) // JWT middleware
	{
		r.GET("/:user_id", profileController.GetProfile)
		r.PATCH("/", profileController.EditProfileAndSkills)
		r.PATCH("/password", profileController.ChangePassword)
	}
}

func ExperienceRoutes(router *gin.Engine, experienceController *controllers.ExperienceController) {
	r := router.Group("/api/user/profile/experience")
	r.Use(utils.Auth())
	{
		r.POST("/", experienceController.Create)
		r.PATCH("/:experience_id", experienceController.Update)
		r.DELETE("/:experience_id", experienceController.Delete)
	}
}
func NotificationRoutes(
	router *gin.Engine,
	notificationController *controllers.NotificationController,
) {

	auth := router.Group("/api")
	auth.Use(utils.Auth())

	{
		auth.GET(
			"/notification/bell-status",
			notificationController.GetBellStatus,
		)

		auth.PATCH(
			"/notification",
			notificationController.MarkBellRead,
		)

		auth.GET(
			"/notifications",
			notificationController.GetNotifications,
		)
	}
}

func SetupAllRoutes(router *gin.Engine,
	eventController *controllers.EventController,
	userController *controllers.UserController,
	profileController *controllers.ProfileController,
	adminController *controllers.AdminController,
	reportController *controllers.ReportController,
	experienceController *controllers.ExperienceController,
	notificationController *controllers.NotificationController,
) {
	EventRoutes(router, eventController)
	UserRoutes(router, userController)
	ProfileRoutes(router, profileController)
	AdminRoutes(router, adminController)
	ReportRoutes(router, reportController)
	ExperienceRoutes(router, experienceController)
	NotificationRoutes(router, notificationController)
}
