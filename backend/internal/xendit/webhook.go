package xendit

import (
	"errors"
	"net/http"
	"strings"
)

// VerifyCallbackToken is a minimal, optional guard.
//
// If expectedToken is empty, verification is skipped.
func VerifyCallbackToken(header http.Header, expectedToken string) error {
	expectedToken = strings.TrimSpace(expectedToken)
	if expectedToken == "" {
		return nil
	}

	// Commonly used header name in Xendit callbacks.
	got := strings.TrimSpace(header.Get("x-callback-token"))
	if got == "" {
		got = strings.TrimSpace(header.Get("X-CALLBACK-TOKEN"))
	}

	if got == "" {
		return errors.New("missing callback token")
	}
	if got != expectedToken {
		return errors.New("invalid callback token")
	}
	return nil
}
