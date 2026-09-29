# NarcTrace by Etaernal

Digital companion for presumptive field drug testing · SIH 26231.

## Website (new)

The responsive browser application lives in `website/`. It has light and dark themes, the supplied logo, an overview, camera/image capture, searchable history, image fingerprint verification, a field guide, settings, and a Supabase login screen with Google sign-in integration.

```powershell
cd C:\Users\Lenovo\OneDrive\Desktop\GitHub\Narcotics-detector\website
npm.cmd install
npm.cmd run dev -- --port 5173
```

Open http://127.0.0.1:5173. Use Ctrl+C to stop. For the production build run `npm.cmd run build`; deploy `website/dist` to a static host with HTTPS. Browser camera and location require HTTPS or localhost.

`npm.cmd test` checks filtering, actual SHA-256 hashing, and safe CSV exports.

## Existing mobile work

`lib/`, `web/`, and the Flutter platform folders remain the original mobile/Flutter-web prototype. The new website is a separate browser-focused frontend, not a rewrite of the mobile app. Existing Flutter services are mock implementations and are not used by the new website.

## Connected project

Only **Narcotic Drug Detection** (`dfstveieqlmkumycaknn`) is configured. The ETA Supabase project is not used or changed. Browser configuration contains only a publishable key, never a service-role key. Existing database schema and Edge Functions were not changed or deployed during this redesign.

## What works and what remains

- Light/dark preference persists on the device; layouts adapt to mobile and desktop.
- Preview starts empty. Optional sample records are explicitly labelled and never uploaded.
- Email sign-in uses Supabase; history reads the signed-in user's records. Successful account login still needs testing with an actual operator account.
- Google sign-in is wired, but the provider was disabled when checked on 29 September 2026. See `website/SETUP.md` for the manual configuration.
- Camera and file capture use browser APIs; SHA-256 is calculated over the actual image bytes. GPS is requested only when the operator clicks its button. Camera/GPS permission outcomes depend on the device.
- Captures are **unsigned, unclassified, in-memory drafts**. They are not uploaded or represented as chemical results. Export JSON before closing/reloading the tab; preserve the original image separately. The interface warns before leaving with drafts.
- History search, outcome filters, CSV export, record details, identifier QR generation, and image hash matching work. QR codes identify records; they do not certify signatures.
- Automated reference-card detection, OpenCV calibration, validated chemical classification, server-backed capture storage, Google Cloud KMS signing, and signed-record/QR verification still require implementation and validation. No dataset or classifier accuracy claim is fabricated.

The original backend scaffolding uses development HMAC signing and has broad read policies. It must be hardened before sensitive records are stored. The new website intentionally does not invoke those signing functions or upload evidence to this backend.

All field outcomes remain presumptive; laboratory confirmatory testing is required.
