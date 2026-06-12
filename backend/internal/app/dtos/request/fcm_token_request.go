package request

type FCMTokenRequest struct {
	Token string `json:"token" binding:"required"`
}
