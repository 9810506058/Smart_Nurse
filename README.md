🩺 Smart Nurse - Flutter App
Smart Nurse is a modern, Firebase-backed Flutter application designed to assist nurses and supervisors in managing patient care effectively. It enables real-time recording of patient vitals, streamlined task management, and centralized oversight by supervisors.

🚀 Features
👩‍⚕️ For Nurses
✅ Record Patient Vitals (temperature, blood pressure, pulse, respiration, etc.)

📋 View Assigned Patients and Tasks

🗓️ Receive Daily Schedules and Reminders

🔔 Real-time Notifications for New Assignments

👨‍💼 For Supervisors
👥 Assign Patients and Tasks to Nurses

📊 Track Nurse Activities and Vital Updates

🔍 Monitor Patient Health Trends in Real-time

📁 Manage Patient Profiles and Task Logs

🛠️ Tech Stack
Flutter – Cross-platform UI toolkit

Firebase – Backend-as-a-Service

Firebase Authentication

Cloud Firestore

Firebase Cloud Messaging (FCM)

Firebase Storage (if used)



🔧 Getting Started
Prerequisites
Flutter SDK: Install Flutter

Dart >= 2.18

Firebase Project Setup: Firebase Console

Installation
Clone the repository:
git clone https://github.com/your-username/smart-nurse.git
cd smart-nurse
Install dependencies:
flutter pub get
Set up Firebase:
Add your google-services.json (Android) and GoogleService-Info.plist (iOS) to the respective platform folders.

Enable necessary Firebase services (Authentication, Firestore, FCM).

Run the app:
flutter run
🧪 Testing
flutter test
Ensure you have tests for:

Vitals input validation

Firebase data interactions

Task assignment flows

📂 Project Structure
bash
Copy
Edit
lib/
├── models/         # Data models (Vitals, User, Task, etc.)
├── screens/        # UI Screens (Nurse, Supervisor)
├── services/       # Firebase interactions
├── providers/      # State management logic
├── widgets/        # Reusable UI components
└── main.dart       # App entry point

💡 Future Enhancements
📈 Graphical Trends of Patient Vitals

📋 Export Data to PDF/CSV

🌐 Multi-language Support

🔐 Role-based Access & Permissions

🧠 AI Health Alerts & Suggestions

