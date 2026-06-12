package services

import (
	"backend/internal/app/dtos/request"
	"backend/internal/app/dtos/response"
	"backend/internal/app/models"
	"backend/internal/app/repositories"
	"backend/internal/app/utils"
	"errors"

	"golang.org/x/crypto/bcrypt"
)

type UserService struct {
	UserRepo    *repositories.UserRepository
	ProfileRepo repositories.ProfileRepository
}

func NewUserService(userRepo *repositories.UserRepository, profileRepo repositories.ProfileRepository) *UserService {
	return &UserService{
		UserRepo:    userRepo,
		ProfileRepo: profileRepo,
	}
}

func (s *UserService) Register(req request.RegisterRequestDto) (response.RegisterResponseDto, error) {
	if s.UserRepo.IsEmailExists(req.Email) {
		return response.RegisterResponseDto{}, errors.New("email already exists")
	}

	// Cek username sudah ada?
	if s.UserRepo.IsUsernameExists(req.Username) {
		return response.RegisterResponseDto{}, errors.New("username already exists")
	}

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		return response.RegisterResponseDto{}, err
	}

	user := models.User{
		Email:    req.Email,
		Username: req.Username,
		Password: string(hashedPassword),
	}

	err = s.UserRepo.Create(&user)
	if err != nil {
		return response.RegisterResponseDto{}, err
	}

	profile := models.Profile{
		UserID:   user.ID,
		Username: user.Username,
	}

	if err := s.ProfileRepo.Create(&profile); err != nil {
		return response.RegisterResponseDto{}, err
	}

	return response.RegisterResponseDto{
		Email:    user.Email,
		Username: user.Username,
	}, nil
}

func (s *UserService) Login(req request.LoginRequestDto) (response.LoginResponseDto, error) {

	// ambil user dengan username
	user, err := s.UserRepo.FindByUsername(req.Username)
	if err != nil {
		return response.LoginResponseDto{}, errors.New("invalid username or password")
	}

	// cek password
	if bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(req.Password)) != nil {
		return response.LoginResponseDto{}, errors.New("invalid username or password")
	}

	// generate JWT
	token, err := utils.GenerateJWT(user.ID)
	if err != nil {
		return response.LoginResponseDto{}, err
	}

	// response
	return response.LoginResponseDto{
		Message: "login success",
		Token:   token,
		Data: response.UserData{
			ID:       user.ID,
			Email:    user.Email,
			Username: user.Username,
		},
	}, nil
}

func (s *UserService) SaveFCMToken(
	userID uint,
	token string,
) error {
	return s.UserRepo.SaveFCMToken(
		userID,
		token,
	)
}

func (s *UserService) Logout(
	token string,
) error {
	return s.UserRepo.RemoveFCMToken(token)
}
