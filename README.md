# Google Maps Integration in Flutter — MapGo

**Repository:** https://github.com/anushkagupta65/MapsImpl  
**Project Name:** `MapGo`

---

## 📌 Summary

This project is the implementation of **Google Maps**, which includes:

- Displaying Google Map centered on the user’s current location  
- Handling location permissions  
- Dropping markers on map tap  
- Source & destination search  
- Autocomplete search using Google Places API  
- Fetching route using Google Directions API  
- Drawing polyline  
- Displaying distance & estimated duration  
- My Location button  
- Clear markers  
- Organized folder architecture (data → models → services → presentation → widgets → utils)


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


---

## 🎯 Features Implemented

### 🔹 Core Features
- ✔️ Google Map display  
- ✔️ Current location  
- ✔️ Permission handling  
- ✔️ Add markers on tap  
- ✔️ Search source & destination  
- ✔️ Google Places Autocomplete  
- ✔️ Fetch route using Directions API  
- ✔️ Draw polyline  
- ✔️ Show distance & duration  

### 🔹 Additional UX Features
- ✔️ "My Location" floating action button  
- ✔️ "Clear Markers" button  
- ✔️ Clean UI  
- ✔️ Google Fonts  

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

### Dev Dependencies
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

# 🔑 **API Key Integration Guide (MANDATORY CHANGES)**

To run this project, **you must add your Google API key in 3 places**:

---

## **1️⃣ Add API Key in `.env` (Project Root)**

Create a `.env` file:

```
API_KEY=YOUR_API_KEY
```

Do **NOT** push this file to GitHub.

---

## **2️⃣ Add API Key in Android → `AndroidManifest.xml`**

Open:

```
android/app/src/main/AndroidManifest.xml
```

Inside the `<application>` tag add:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY_HERE"/>
```

This allows **Maps SDK** to use your API key for Android.

---

## **3️⃣ Add API Key in iOS → AppDelegate.swift**

Open:

```
ios/Runner/AppDelegate.swift
```

Add inside the `didFinishLaunchingWithOptions` method:

```swift
GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
```

---

# 📍 How Routing Works (Short Explanation)

1. Autocomplete provides place_id  
2. Using place_id → fetch coordinates  
3. Directions API request calls the route endpoint  
4. Polyline decoded using `flutter_polyline_points`  
5. Map draws the polyline  
6. UI displays distance & duration  

---

## ▶️ Run the App

```bash
flutter pub get
flutter run
```

Make sure:

- `.env` file exists and key is set 
- AndroidManifest key is set  
- iOS AppDelegate key is set  

---

## 🧩 Troubleshooting

| Issue | Reason | Fix |
|------|--------|-----|
| Map not loading | API key missing/wrong | Check Manifest & Info.plist |
| Autocomplete failing | Places API disabled | Enable Places API |
| Route not drawing | Directions API disabled | Enable Directions API |
| Location stuck | Permission denied | Allow location manually |

---

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

MIT License — free to use & modify.

---

## 📩 Contact

If you want this README updated with GIF demo, API documentation, or auto-generated diagrams — feel free to ask!
