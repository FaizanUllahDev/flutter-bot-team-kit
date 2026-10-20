# Telecom domain (generic best practices)
- Remote config drives features per market; cache it with a TTL and safe defaults.
- Plans/bundles: cache lists, refresh on pull, show stale state clearly.
- Balances and usage: show last updated time.
- Many languages and long strings: test truncation and overflow.
- Low-end devices and weak networks: small payloads, retries with backoff, offline states.
- Phone number input: validate per country format, never hardcode one format.
