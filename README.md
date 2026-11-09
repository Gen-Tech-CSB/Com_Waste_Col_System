Community Waste Collection and Reporting System (Frontend)

A cross-platform Flutter application designed for residents and LGU/Barangay staff. This system allows residents to view garbage collection schedules, submit waste-related reports (with photo evidence), and track the status of their reports. Admins can manage schedules, review reports, post announcements, and monitor community activities.

Project Overview

This repository contains the Frontend application built with Flutter. It features a Premium Dark Theme with Gradient effects and smooth animations to provide a modern, user-friendly, and professional experience across Mobile (Android), Web, and Desktop (Windows).

Features Implemented (Frontend)

Authentication and Security
- Resident Login and Registration for community members.
- Admin Secure Login with a dedicated prompt requiring specific credentials.
- Session navigation and secure logout functionalities.

Resident Dashboard Features
- Collection Schedule: A real-time synced view of collection days showing Biodegradable, Non-Biodegradable, and Recyclable waste types.
- Report Submission with Photo Evidence: A comprehensive form allowing residents to submit waste issues, including category, detailed description, and image attachment using the Image Picker package.
- My Reports with Status Timeline: A personalized list of submitted reports. Includes a vertical Status Timeline (Submitted -> Under Review -> In Progress -> Resolved) for tracking.
- Resident Feedback System: A 5-star rating and comment section that appears when a report is resolved.
- Announcements Banner: A dynamic banner on the schedule page displaying the latest announcements posted by the Admin.
- Waste Segregation Guide: An educational page with guidelines on proper waste segregation and emergency contact numbers.
- Profile and Logout: A dedicated profile screen displaying user details with a secure logout function.

Admin Dashboard Features
- System Overview: Gradient stat cards showing Total, Pending, In Progress, and Resolved reports for quick analytics.
- Manage Schedules: A complete CRUD (Create and Delete) system for collection schedules, instantly synced with the Resident's view.
- Post Announcements: A feature allowing Admins to post real-time announcements that immediately appear on the Resident's dashboard.
- Recent Reports and Search: A searchable list of the latest community reports, filterable by title or location.
- Duplicate Report Flagging: An automatic flagging system that detects and displays a warning for reports with the same category and location.
- Report Review and Status Update: A detailed view where Admins can view report details (including photos), update the report status, and add administrative remarks.
- Activity Log: A historical log tracking all admin actions (e.g., schedules added, reports updated) for accountability.

Tech Stack (Frontend)
- Framework: Flutter (Dart)
- State Management: Provider (Used for sharing data between Admin and Resident views)
- Image Handling: Image Picker (For attaching photos to reports)
- UI Design: Custom Dark Theme, Gradients, Custom Animations, and Soft Shadows.

How to Run this Project Locally

Prerequisites
Ensure you have Flutter installed. You can verify by running:
flutter --version

Installation Steps
1. Clone the repository:
git clone https://github.com/YOUR-GITHUB-USERNAME/community-waste-frontend.git

2. Navigate to the project folder:
cd community-waste-frontend

3. Install dependencies:
flutter pub get

4. Run the application on Chrome (Web):
flutter run -d chrome

Mock Credentials (For Testing)
Since the backend is currently in development, use these credentials to test the features:
- Resident Login: Just type any email/password, then click "Log In as Resident".
- Admin Login: Click "Log In as Admin", then use:
  Email: admin@waste.com
  Password: admin123

Development Team
- Elopre and Bagsican - Frontend Developers (Flutter UI, State Management, Features)
- Backend Developer Name - Backend Developer (Node.js and PostgreSQL - In Progress)
- Cinco - Team Leader
- Quezon - Project Manager
- Tomogsok - Quality Assurance

This project is developed as part of our academic requirement for Insert Subject Name Here.