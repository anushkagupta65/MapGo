# Flutter Google Maps Assessment

**Repository:** https://github.com/anushkagupta65/MapsImpl  
**Project Name:** `MapGo`

---

## 📌 Summary

This project is the implementation of the **Google Maps**, which includes:

- Displaying Google Map centered on the user’s current location  
- Handling location permissions  
- Dropping markers on map tap  
- Source & destination search  
- Autocomplete search using Google Places API  
- Fetching route from the Google Directions API  
- Drawing polyline on the map  
- Showing distance & estimated duration  
- My Location button  
- Clear markers  
- Clean folder architecture (data → models → services → presentation → widgets → utils)

All requirements are fully implemented.

---

## 📁 Project Structure (Actual)

```
lib/
└── src/
    ├── data/
    │   ├── directions_api.dart
    │   └── places_api.dart
    │
    ├── models/
    │   ├── prediction.dart
    │   └── route_info.dart
    │
    ├── presentation/
    │   ├── screens/
    │   │   ├── map_screen.dart
    │   │   └── route_search_screen.dart
    │   │
    │   └── widgets/
    │       ├── custom_autocomplete.dart
    │       └── search_bar.dart
    │
    ├── services/
    │   ├── location_service.dart
    │   └── map_service.dart
    │
    ├── utils/
    │   ├── app_colors.dart
    │   └── app_constants.dart
    │
    └── main.dart
```

This clean architecture separates **API**, **Models**, **UI**, **Widgets**, **Services**, and **Utilities**.

---

## 🎯 Features Implemented

### 🔹 Core Requirements

- ✔️ Display Google Map  
- ✔️ Get current location  
- ✔️ Handle permissions (Geolocator)  
- ✔️ Tap on map → Add marker  
- ✔️ Search source & destination  
- ✔️ Google Places autocomplete  
- ✔️ Fetch Directions API route  
- ✔️ Draw polyline  
- ✔️ Show distance & duration  

### 🔹 Extra UX Features

- ✔️ “My Location” floating button  
- ✔️ “Clear Markers” button 
- ✔️ Custom fonts via **google_fonts**  
- ✔️ Clean & responsive UI  

---

## 🚀 Dependencies (From pubspec.yaml)

```
google_maps_flutter: ^2.9.0
geolocator: ^13.0.1
http: ^1.2.2
flutter_polyline_points: ^2.1.0
uuid: ^4.5.0
google_places_flutter: ^2.0.6
provider: ^6.1.5+1
google_fonts: ^6.3.2
flutter_dotenv: ^6.0.0
```

### Dev dependencies

```
flutter_lints: ^5.0.0
flutter_test:
```

### Assets

```
assets/images/
.env
```

---

## 🔑 Google API Key Setup

### 1️⃣ Create API Key  
From Google Cloud Console → Enable:

- Maps SDK (Android/iOS)
- Directions API
- Places API

### 2️⃣ Add Key in `.env`:

```
GOOGLE_MAPS_API_KEY=YOUR_API_KEY
```

### 3️⃣ Load `.env` in `main.dart`:

```dart
await dotenv.load(fileName: ".env");
```

### 4️⃣ Add API Key to AndroidManifest.xml

```xml
<meta-data
  android:name="com.google.android.geo.API_KEY"
  android:value="${GOOGLE_MAPS_API_KEY}" />
```

### 5️⃣ Add API Key to Info.plist (iOS)

```xml
<key>GMSApiKey</key>
<string>YOUR_API_KEY</string>
```

---

## 📍 How Routing Works (Short Explanation)

1. User selects source & destination  
2. Google Places API returns place_id  
3. Directions API is called via **directions_api.dart**  
4. Response → decoded using **PolylinePoints**  
5. Polyline drawn on map  
6. Distance & duration parsed → displayed in UI  

---

## ▶️ Run the App

```
flutter pub get
flutter run
```

Make sure `.env` exists in the project root.

---

## 🧩 Troubleshooting

| Issue | Reason | Fix |
|------|--------|-----|
| Map tiles not loading | Wrong / missing API key | Check Android & iOS setup |
| Directions API returns ZERO_RESULTS | Billing not enabled | Enable billing in Google Cloud |
| Location not showing | Permission denied | Allow location from system settings |
| Autocomplete not working | Places API disabled | Enable Places API |


## 🖼️ Screenshots

<details>
<summary><strong>📍 App Preview Screens</strong></summary>

<br>

| Map View | Autocomplete | Route Drawing |
|---------|--------------|---------------|
| ![img1](https://github.com/user-attachments/assets/81be2d1f-dd33-45a1-96ea-93f82fcb1e86) | ![img2](https://github.com/user-attachments/assets/6d23da66-b331-4159-8203-42132e7e1682) | ![img3](https://github.com/user-attachments/assets/6b724977-5da0-4a59-80f9-c7ef147544fe) |

</details>

---

<details>
<summary><strong>🚫 Permission Denied Screens</strong></summary>

<br>

| Permission Denied Preview 1 | Permission Denied Preview 2 |
|-----------------------------|------------------------------|
| ![ss4](https://github.com/user-attachments/assets/1877212c-990e-4671-8b20-90a4d1c1425e) | ![ss5](https://github.com/user-attachments/assets/3e374ac4-837d-42fa-ace5-1f03936bca03) |

</details>



---

## 📜 License

MIT License — open for use and enhancement.

---

## 📩 Contact

If you want this README updated with GIF demo or more technical documentation, feel free to ask!

