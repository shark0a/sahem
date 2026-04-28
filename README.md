# 🍽️ Sahem
Sahem is a context-aware recipe discovery Flutter application that recommends meals based on time of day, user location, and search intent. It combines online recipe lookup, local caching, favorites, and smart reminders to help users quickly decide what to cook.

---

## 🌟 Overview
Sahem uses contextual signals such as current time and geographic region to deliver relevant meal suggestions.

- 🌅 In the morning, users see breakfast-friendly recipes  
- ☀️ Around midday, the app prioritizes lunch options  
- 🌙 In the evening, dinner suggestions take focus  
- 📍 Location is used to slightly adapt results to regional preferences  

Users can also browse categories, search recipes in real time, save favorites, and view detailed cooking instructions.

---

## ✨ Features
- 🧠 Context-aware home feed based on meal time and user location  
- 🌐 Recipes fetched from TheMealDB API  
- 🔍 Real-time search with debounced input using RxDart  
- 📂 Category-based browsing (Breakfast, Lunch, Dinner, Dessert)  
- ❤️ Favorites stored locally using Hive  
- 📴 Offline support with cached data  
- 📋 Detailed recipe view (ingredients, instructions, metadata)  
- 🔔 Daily meal reminders (breakfast, lunch, dinner)  
- 🎨 Smooth UI animations and shimmer loading states  
- 🧭 Clean navigation using GoRouter  

---

## 🛠️ Tech Stack
- 💙 Flutter & Dart  
- 🧩 BLoC / Cubit (State Management)  
- 🏛️ Clean Architecture (layered approach)  
- 💉 GetIt (Dependency Injection)  
- 🌐 Dio (Networking)  
- 🐝 Hive (Local Storage & Caching)  
- 🍲 TheMealDB API  
- 📡 Geolocator & Geocoding (Location Awareness)  
- 🔔 Flutter Local Notifications  
- ⚙️ Workmanager (Background Tasks)  
- 🧭 GoRouter (Navigation)  
- 🔁 RxDart (Reactive Programming)  
- 🖼️ Cached Network Image  
- ✨ Flutter Animate & Shimmer  

---

## 🏗️ Architecture & Design Decisions
Sahem follows a Clean Architecture-inspired structure with clear separation of concerns:

- 🖼️ **Presentation Layer**: UI, Screens, and Cubits  
- 🧠 **Domain Layer**: Business logic, entities, and use cases  
- 💾 **Data Layer**: API calls, local storage, repository implementations  
- ⚙️ **Core Module**: Shared utilities, services, DI, and routing  

### 🔑 Key Decisions
- Cubits manage UI state to keep widgets lightweight  
- Repository pattern abstracts data sources (remote/local)  
- Hive is used for fast offline access and persistence  
- Search input is debounced to optimize API usage  
- Notifications are scheduled in the background using Workmanager  

---

## 📁 Project Structure
```text
lib/
├── core/
│   ├── constants/
│   ├── di/
│   ├── errors/
│   ├── network/
│   ├── router/
│   ├── services/
│   ├── utils/
│   └── widgets/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── feature/
│   ├── home/
│   ├── search/
│   ├── favorites/
│   ├── detail/
│   └── splash/
├── main.dart
└── sahem_app.dart
```

---

## 👨‍💻 Author

**Ahmed Elsharkawy**

[![GitHub](https://img.shields.io/badge/GitHub-shark0a-181717?style=for-the-badge&logo=github)](https://github.com/shark0a)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Ahmed%20Elsharkawy-0A66C2?style=for-the-badge&logo=linkedin)](https://www.linkedin.com/in/ahmed-elsharkawy-46046525a)
