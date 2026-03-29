# News Application

An intelligent news application powered by Google Gemini AI. This app fetches the latest headlines and provides instant AI-driven analysis, summaries, and sentiment checks for each article. Built with Flutter for a beautiful, cross-platform user experience.

## ✨ Features

- **Live News Feed:** Fetches real-time headlines from top sources.
- **AI Analysis:** Uses Google Gemini to summarize articles and extract key points.
- **Modern UI:** Clean, responsive design with dark/light mode support.
- **Fast & Lightweight:** Optimized state management for smooth performance.
- **Secure:** API keys managed via environment configuration.

## 🏗 Architecture

This project follows a simplified MVVM (Model-View-ViewModel) architecture to ensure code maintainability and separation of concerns.

## Key Components

1. **News Service:** Handles HTTP requests to the News API.
2. **Gemini Service:** Handles prompts and responses from the Google Gemini API.
3. **Repository:** Acts as a single source of truth, combining data from both services.
4. **ViewModel:** Manages UI state (Loading, Success, Error) and exposes data to the UI.

## 📶 Offline Mode

This app supports **Offline Caching**. 

- **When Online:** The app fetches the latest news and generates fresh AI analysis.
- **When Offline:** The app loads the last fetched news and saved analysis from your device storage.
- **Limitation:** New AI analysis cannot be generated without an internet connection (Gemini requires cloud access).

## 🚀 Getting Started

Follow these steps to get the app up and running on your local machine.
1. Prerequisites
Ensure you have the following installed:
- Flutter SDK (Version 3.0 or higher)
- Dart
- A code editor (VS Code or Android Studio)
- API Keys:
    - Google Gemini API Key
    - NewsAPI.org Key (or any news provider you prefer)

2. Clone the Repository

git clone https://github.com/Sirilak2004/News_App_With_Offline_First_Supported

cd news_app

3. Install Dependencies

Fetch the required Flutter packages:

Command: flutter pub get

4. Run the App

Connect a device or start an emulator, then run:

Command: flutter run
