Community Waste Collection and Reporting System (Frontend)

Project Overview
The Community Waste Collection and Reporting System is a cross-platform application developed to bridge the communication gap between residents and local government units (LGU) regarding waste management. Built using Flutter, this frontend application empowers residents to easily access garbage collection schedules, report waste-related issues (such as missed pickups or illegal dumping) with photographic evidence, and track the progress of their reports in real-time. On the other hand, it provides barangay administrators with a comprehensive dashboard to manage schedules, review and resolve reports, broadcast announcements, and analyze community data for better decision-making.

Key Features Implemented

1. Authentication and Security
- Resident Login and Registration.
- Admin Secure Login with a dedicated prompt requiring specific credentials.
- Session management and secure logout with confirmation dialogs.
- Profile Management with an "Edit Profile" feature.

2. Resident Dashboard
- Collection Schedule: A real-time synced view of collection days categorized by waste type.
- Report Submission: A comprehensive form allowing residents to submit waste issues with descriptions and image attachments using the Image Picker.
- Local Data Persistence (Offline Drafts): Residents can save their reports as drafts locally, which are automatically loaded when they return.
- My Reports and Status Timeline: A personalized list of submitted reports featuring a vertical timeline for transparency.
- Resident Feedback: A 5-star rating and comment section to evaluate the service once a report is resolved.
- Announcements: A dynamic banner displaying real-time updates posted by the Admin.
- Waste Segregation Guide: An educational page with guidelines and emergency contact numbers.

3. Admin Dashboard
- System Overview: Clickable gradient stat cards providing quick analytics (Total, Pending, In Progress, Resolved) that filter the report list.
- Monthly Community Reports: Interactive Analytics screen featuring a Pie Chart (Reports by Status) and a Bar Chart (Reports per Barangay).
- Manage Schedules: A complete system to add and delete collection schedules, instantly synced with the Resident's view.
- Post Announcements: Real-time broadcasting of important community announcements.
- Recent Reports and Search: A searchable and filterable list of community reports.
- Duplicate Report Flagging: An automatic flagging system that detects and displays warnings for reports with the same category and location.
- Report Review and Status Update: A detailed view where Admins can review report photos, update the status, add administrative remarks, and assign the report to a specific collection crew.
- Activity Log: A historical log tracking all admin actions (e.g., schedules added, reports updated) for accountability.

Tech Stack and Tools
- Framework: Flutter (Dart)
- State Management: Provider
- Image Handling: Image Picker
- Charts and Analytics: FL Chart
- Local Storage: Shared Preferences
- UI Design: Custom Dark Theme, Gradients, Animations, and Soft Shadows.

Local Development Setup

Prerequisites
Ensure you have Flutter installed on your machine. Verify by running:
flutter --version

Installation Guide
1. Clone the repository:
git clone https://github.com/YOUR-GITHUB-USERNAME/community-waste-frontend.git

2. Navigate to the project directory:
cd community-waste-frontend

3. Install dependencies:
flutter pub get

4. Launch the application on Chrome:
flutter run -d chrome

Default Mock Credentials (For Testing)
Since the backend is still in development, use these credentials to test the features:

Resident Login:
- Register a new account first, then log in using those credentials.

Admin Login:
- Email: admin@waste.com
- Password: admin123

Development Team
- Elopre - Frontend Developers (Flutter UI, State Management, Features)
- Bagsican - Backend Developer (Node.js and PostgreSQL - In Progress)
- Cinco - Team Leader
- Quezon - Project Manager
- Tomogsok - Quality Assurance

This project is developed as part of our academic requirement for Insert Subject Name Here.