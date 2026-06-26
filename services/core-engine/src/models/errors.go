package models

import (
    "time"
)

type Auth struct {
    Token     string    `json:"token"`
    ExpiresAt time.Time `json:"expires_at"`
    Type      string    `json:"type"`
    UserID    string    `json:"user_id"`
}

type SimulationUpdate struct {
    Status    string                 `json:"status"`
    Result    interface{}           `json:"result"`
    Error     string                 `json:"error"`
    Timestamp time.Time             `json:"timestamp"`
}

type ErrorResponse struct {
    Message    string                 `json:"message"`
    Code       string                 `json:"code"`
    Details    interface{}           `json:"details"`
}

var knownErrors = map[string]string{
    "Not Found":     "ERROR_NOT_FOUND",
    "Unauthorized": "ERROR_UNAUTHORIZED",
    "Bad Request":   "ERROR_BAD_REQUEST",
    "Internal":      "ERROR_INTERNAL",
}