# Flutter Google Maps Integration (Assessment)

**Repository:** `<your-github-repo-url>`  
**Author:** `<Your Name>`  
**Date:** `<YYYY-MM-DD>`

---

## Summary

This project implements the Flutter Google Maps assessment: display a Google Map centered on the user's current location (with permission handling), allow dropping markers by tapping, accept a source and destination, draw a route (polyline) using the Google Directions API, and show total distance & estimated duration. Optional features such as Places Autocomplete, Clear Markers, and "My Location" button are also included as toggles (see features). :contentReference[oaicite:1]{index=1}

---

## Features

- Request and handle location permission (graceful denial message).
- Show Google Map centered on user’s current location.
- Drop markers by tapping any location on the map.
- Input fields for **Source** and **Destination**.
- Use Google Directions API to:
  - Fetch route and draw polyline between source & destination.
  - Display total distance and estimated duration for route.
- Bonus (optional / included):
  - Google Places Autocomplete for address entry (optional package).
  - "Clear Markers" button.
  - "My Location" floating button to re-centre on user location.

These features align with the assessment requirements. :contentReference[oaicite:2]{index=2}

---

## Screenshots

_Add screenshots of your app here (optional)._

---

## Prerequisites

- Flutter SDK (>= 3.0 recommended)
- Android Studio / Xcode (for emulators / devices)
- A Google Cloud Platform project with the following APIs enabled:
  - **Maps SDK for Android**
  - **Maps SDK for iOS**
  - **Directions API**
  - **Places API** (only if using Autocomplete)

> Note: Directions API may require billing to be enabled on the GCP project even for free-tier testing.

---

## Packages / Dependencies

Add these (or similar) to your `pubspec.yaml` under `dependencies:`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  google_maps_flutter: ^2.4.0
  geolocator: ^9.0.2
  permission_handler: ^10.0.0
  flutter_dotenv: ^5.0.2
  http: ^0.14.0
  flutter_polyline_points: ^1.0.0
  intl: ^0.18.0
  # Optional:
  google_place: ^0.6.0 # for Places Autocomplete (optional)
```

(Adjust versions as needed.)

---

## Setup — Google API Keys

**1. Create API key**

- Go to Google Cloud Console → Create / choose a project → APIs & Services → Credentials → Create API key.

**2. Enable APIs**

- Enable Maps SDK for Android, Maps SDK for iOS, Directions API, and Places API (if used).

**3. Restrict the key**

- For development, you can leave it unrestricted (not recommended). For production, restrict by Android package name / iOS bundle ID and HTTP referrers.

**4. Add API key to the app**

Option A — using environment file (`.env`) and `flutter_dotenv` (recommended):

- Create a file at project root named `.env` (do **not** commit to git).

```
GOOGLE_MAPS_API_KEY=YOUR_API_KEY_HERE
```

- Load this in `main.dart`:

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}
```

Option B — Android / iOS native config (useful for Maps SDK):

**Android** (`android/app/src/main/AndroidManifest.xml`) — add inside `<application>`:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY_HERE" />
```

**iOS** (`ios/Runner/Info.plist`) — add:

```xml
<key>GMSApiKey</key>
<string>YOUR_API_KEY_HERE</string>
```

If you use `flutter_dotenv`, pass the API key into widgets that need it.

---

## Android-specific Setup

- In `android/app/build.gradle` ensure `minSdkVersion` >= 20 (or as required by packages).
- Add the `meta-data` entry in `AndroidManifest.xml` as shown above.
- Add permissions in `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

---

## iOS-specific Setup

- Open `ios/Runner/Info.plist` and add:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>App requires location to show your current position on the map.</string>
```

- Add `GMSApiKey` entry shown above.
- Enable `Maps` capability in Xcode if necessary.

---

## Example: Getting Directions & Drawing Polyline

A simplified flow (the full implementation resides in the app):

1. Convert source/destination text into coordinates:

   - Option 1: Geocoding (server or Geocoding API).
   - Option 2: Let user tap map as source/destination (you already get LatLng).

2. Call Directions API:

   ```
   https://maps.googleapis.com/maps/api/directions/json?origin=lat,lng&destination=lat,lng&key=YOUR_API_KEY
   ```

   - Parse returned `overview_polyline.points`.
   - Use `flutter_polyline_points` to decode and create a `List<LatLng>`.

3. Create `Polyline` and add to `GoogleMap` `polylines` set.

4. Extract distance & duration from `routes[0].legs[0].distance.text` and `routes[0].legs[0].duration.text`.

---

## Run the App

1. Install dependencies:

```bash
flutter pub get
```

2. Prepare `.env` (if used) or ensure API keys are set in native files.

3. Run on device/emulator:

```bash
flutter run
```

---

## Troubleshooting

- **Blank map tiles**: ensure the API key is valid and Maps SDK is enabled for the platform.
- **Directions not returning**: check Directions API is enabled, and that billing is enabled if required.
- **Permissions denied**: app should show a friendly explanation and a button to open app settings (use `permission_handler`).

---

## Project Structure (example)

```
lib/
  main.dart
  screens/
    map_screen.dart
  services/
    location_service.dart
    directions_service.dart
  widgets/
    location_input.dart
    route_info_card.dart
assets/
  images/
```

---

## Approach (brief)

- Use `geolocator` to get current location and to request/handle permissions.
- Use `google_maps_flutter` to render map, markers, and polylines.
- Use `flutter_polyline_points` to decode route polylines from Directions API responses.
- Use `http` to call Directions API and parse JSON for distance/duration.
- (Optional) Use `google_place` for autocomplete inputs to improve UX.

This approach keeps separation of concerns by moving API calls into `services/` and UI into `screens/` and `widgets/`.

---

## Notes on Assessment Requirements

The app implements the core tasks from the assessment: map display centered on user location, marker drop on tap, routing via Directions API with polyline and distance/duration display. Optional features like Places Autocomplete, Clear Markers, and My Location floating button can be toggled on or off. See the original assessment document for exact requirements. :contentReference[oaicite:3]{index=3}

---

## License

MIT License — feel free to adapt for your submission.

---

## Contact

If you want me to update this README with actual screenshots or the final repo link, paste the repo URL and I will update the README content accordingly.
