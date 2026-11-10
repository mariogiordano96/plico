# Security policy

If you find a security problem (for example a way to leak the stored API key or local data), please do not
open a public issue. Use GitHub's private vulnerability reporting on this repository
("Security" tab → "Report a vulnerability"). Response times are best-effort.

The Gemini API key you enter is stored in the app's local database on your device (not in the system keystore, so it is not encrypted at rest) and is sent only to Google's Gemini API.
