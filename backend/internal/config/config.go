package config

import (
	"os"
	"strconv"
)

type Config struct {
	Env string

	HTTPHost string
	HTTPPort int

	DatabaseURL string

	// Xendit
	XenditCallbackToken string
	XenditSecretKey     string
	XenditBaseURL       string
}

func LoadFromEnv() Config {
	port := 8080
	if raw := os.Getenv("PORT"); raw != "" {
		if v, err := strconv.Atoi(raw); err == nil {
			port = v
		}
	}

	return Config{
		Env: os.Getenv("ENV"),

		HTTPHost: os.Getenv("HOST"),
		HTTPPort: port,

		DatabaseURL: os.Getenv("DATABASE_URL"),

		XenditCallbackToken: os.Getenv("XENDIT_CALLBACK_TOKEN"),
		XenditSecretKey:     os.Getenv("XENDIT_SECRET_KEY"),
		XenditBaseURL:       os.Getenv("XENDIT_BASE_URL"),
	}
}

func (c Config) HTTPAddr() string {
	host := c.HTTPHost
	if host == "" {
		host = "0.0.0.0"
	}
	return host + ":" + strconv.Itoa(c.HTTPPort)
}
