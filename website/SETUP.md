# Manual setup and production readiness

## Google sign-in

Use only the Narcotic Drug Detection project:
https://supabase.com/dashboard/project/dfstveieqlmkumycaknn/auth/providers

1. In your Google Cloud project, configure the OAuth consent screen and create a Web application OAuth client.
2. Add `https://dfstveieqlmkumycaknn.supabase.co/auth/v1/callback` as an authorised redirect URI.
3. Enable Google under Supabase Authentication providers and enter the Google client ID and client secret there. Do not put the secret in website source or send it in chat.
4. In Supabase Authentication URL Configuration, add `http://127.0.0.1:5173/` for local testing. Add your exact HTTPS deployment URL when deploying and set the Site URL accordingly.
5. If the Google consent screen is in testing mode, add the intended operators as test users.
6. Test Google login and logout with an actual account. The website checks provider availability and gives an actionable error while Google is disabled.

Official guide: https://supabase.com/docs/guides/auth/social-login/auth-google

Email login is already enabled in the project. Supply authorised operator accounts through your administrator; the website does not create privileged operator profiles automatically.

## Before real field evidence

- Supply the actual test-kit outcome specification, reference-card specification, and a licensed/approved labelled dataset. A generic colour threshold or arbitrary confidence percentage is not a validated narcotics classifier.
- Implement and validate reference-card detection, lighting correction, region selection and inconclusive handling. Record model/rule versions, reagent/kit details and calibration quality.
- Harden database/storage access and profile provisioning. Existing policies permit broader authenticated reads than ownership alone; client-side filtering is not an authorisation boundary.
- Replace development HMAC functions with a server-authenticated signing flow and Google Cloud KMS. Remove fallback secrets, check caller ownership, sign an immutable canonical record including all evidentiary fields, and verify against a trusted public key.
- Implement reliable storage of original image bytes and a server-generated timestamp, atomic record creation, and auditable signed-record verification. A device GPS coordinate is device-reported, not independently attested.
- Current captures remain tab-local unsigned drafts by design. Export the JSON and keep the original image; do not treat them as signed evidence.

## Review paths

`/#overview`, `/#capture`, `/#history`, `/#verify`, `/#guide`, `/#settings`, `/#login`.

No production deployment was made by this redesign. The local preview uses port 5173.
