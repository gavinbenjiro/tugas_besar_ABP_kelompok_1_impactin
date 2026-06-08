package controllers

import (
	"backend/internal/app/dtos/request"
	"backend/internal/app/services"
	"log"
	"net/http"

	"github.com/gin-gonic/gin"
)

type UserController struct {
	UserService *services.UserService
}

func NewUserController(us *services.UserService) *UserController {
	return &UserController{
		UserService: us,
	}
}

func (c *UserController) Register(ctx *gin.Context) {

	log.Println("REGISTER ENDPOINT HIT")

	var req request.RegisterRequestDto

	if err := ctx.ShouldBindJSON(&req); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{
			"error": "invalid request",
		})
		return
	}

	resp, err := c.UserService.Register(req)
	if err != nil {
		if err.Error() == "EMAIL_EXISTS" {
			ctx.JSON(http.StatusBadRequest, gin.H{
				"error": "Email already exists",
			})
			return
		}

		if err.Error() == "USERNAME_EXISTS" {
			ctx.JSON(http.StatusBadRequest, gin.H{
				"error": "Username already exists",
			})
			return
		}

		ctx.JSON(http.StatusInternalServerError, gin.H{
			"error": err.Error(),
		})
		return
	}

	ctx.JSON(http.StatusCreated, gin.H{
		"message": "registration success",
		"data":    resp,
	})
}

func (c *UserController) Login(ctx *gin.Context) {
	var req request.LoginRequestDto

	if err := ctx.ShouldBindJSON(&req); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "invalid request"})
		return
	}

	resp, err := c.UserService.Login(req)
	if err != nil {
		if err.Error() == "invalid username or password" {
			ctx.JSON(http.StatusUnauthorized, gin.H{"error": err.Error()})
			return
		}

		ctx.JSON(http.StatusInternalServerError, gin.H{"error": "internal server error"})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{
		"message": resp.Message,
		"token":   resp.Token,
		"data":    resp.Data,
	})
}
