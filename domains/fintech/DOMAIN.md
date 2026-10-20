# Fintech domain (generic best practices)
- Money: use integer minor units or decimal types, never double. Round once, at display.
- Show currency and amount format per locale.
- Confirm screens before any money movement. Idempotency key per request.
- Handle: timeout after submit, duplicate tap, insufficient balance, limits, reversed payments.
- PIN/OTP: masked, never logged, limited retries, no screenshots on sensitive screens.
- Secure storage for tokens. Clear session on logout and on device change.
- Audit-friendly logs with no personal data.
