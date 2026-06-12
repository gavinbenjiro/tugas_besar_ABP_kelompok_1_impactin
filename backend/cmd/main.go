package main

import (
	"backend/internal/app/controllers"
	"backend/internal/app/models"
	"backend/internal/app/repositories"
	"backend/internal/app/routes"
	"backend/internal/app/services"
	"backend/internal/app/utils"
	"backend/internal/config"

	"log"
	"time"

	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

func main() {
	// Initialize DB
	db := config.InitDB()
	config.InitFirebase()
	SeedAdmin(db)

	// === Repository ===
	userRepo := repositories.NewUserRepository(db)
	profileRepo := repositories.NewProfileRepository(db)
	skillRepo := repositories.NewSkillRepository(db)
	adminRepo := repositories.NewAdminRepository(db)
	eventRepo := repositories.NewEventRepository(db)
	applicantRepo := repositories.NewApplicantRepository(db)
	participantRepo := repositories.NewParticipantRepository(db)
	reportRepo := repositories.NewReportRepository(db)
	expRepo := repositories.NewExperienceRepository(db)

	// === Service ===
	notificationSvc, err := services.NewNotificationService()
	if err != nil {
		log.Fatal(err)
	}
	userSvc := services.NewUserService(userRepo, profileRepo)
	profileSvc := services.NewProfileService(profileRepo, userRepo, skillRepo, eventRepo, expRepo)
	eventSvc := services.NewEventService(
		eventRepo,
		profileRepo,
		applicantRepo,
		participantRepo,
		userRepo,
		notificationSvc,
	)
	adminSvc := services.NewAdminService(adminRepo)
	reportSvc := services.NewReportService(reportRepo, eventRepo, participantRepo, profileRepo)
	expSvc := services.NewExperienceService(expRepo)

	// === Controller ===
	userCtrl := controllers.NewUserController(userSvc)
	profileCtrl := controllers.NewProfileController(profileSvc)
	adminCtrl := controllers.NewAdminController(adminSvc)
	eventCtrl := controllers.NewEventController(eventSvc, profileSvc)
	reportCtrl := controllers.NewReportController(reportSvc)
	expCtrl := controllers.NewExperienceController(expSvc)

	// === Auto Update Sub Status ===
	StartEventSubStatusScheduler(eventSvc, 30*time.Second)

	// Setup Gin router and routes
	r := gin.Default()

	r.Use(utils.CORSMiddleware())
	routes.SetupAllRoutes(
		r,
		eventCtrl,
		userCtrl,
		profileCtrl,
		adminCtrl,
		reportCtrl,
		expCtrl,
	)

	// Start server
	if err := r.Run(":8080"); err != nil {
		log.Fatalf("failed to start server: %v", err)
	}
}

func SeedAdmin(db *gorm.DB) {
	var count int64
	db.Model(&models.Admin{}).Count(&count)

	// Kalau admin sudah ada, jangan insert lagi
	if count > 0 {
		return
	}

	password, err := bcrypt.GenerateFromPassword(
		[]byte("admin123"),
		bcrypt.DefaultCost,
	)
	if err != nil {
		log.Fatal(err)
	}

	admin := models.Admin{
		Username: "admin",
		Password: string(password),
	}

	if err := db.Create(&admin).Error; err != nil {
		log.Fatal("failed to seed admin:", err)
	}

	log.Println("✅ Admin seeded successfully")
}

func StartEventSubStatusScheduler(updater services.EventService, interval time.Duration) {
	ticker := time.NewTicker(interval) // interval aman
	go func() {
		for range ticker.C {
			if err := updater.AutoUpdateEventSubStatus(); err != nil {
				log.Println("AutoUpdateEventSubStatus error:", err)
			}
		}
	}()
}
