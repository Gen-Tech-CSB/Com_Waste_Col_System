Community Waste Collection and Reporting System - Project Documentation
Project Overview
The Community Waste Collection and Reporting System is a cross-platform solution designed to streamline waste management operations for local communities. This Intermediate-level project provides residents with a centralized platform to view garbage collection schedules and submit reports regarding missed pickups or improper waste disposal. Barangay and Local Government Unit (LGU) staff utilize an administrative dashboard to manage schedules, process reports, and generate monthly community reports.

The system addresses critical gaps in community waste management by consolidating scattered communication channels (text messages, social media) into a unified platform with organized record-keeping and status tracking.

Project Scope
In-Scope Features
Core Features (from Project Concept)
Module	Description	Platform Support
User Management & Authentication	Resident and admin registration/login with role-based access control; profile stores barangay/purok for automatic schedule display	Mobile, Web, Desktop
Collection Schedule Management	Admins create/edit/delete schedules per barangay/zone by day, time, and waste type; residents view weekly/monthly calendars	Residents: Mobile, Web; Admin: Web, Desktop
Waste Issue Reporting with Photos	Submit reports for missed pickups, illegal dumping, overflowing bins; includes category, description, location, and up to 3 photos	Mobile, Web
Report Status Tracking	Unique reference numbers; status flow: Submitted → Under Review → In Progress → Resolved/Rejected; residents view status timeline with admin remarks	Mobile, Web, Desktop
Admin Dashboard	Summary cards, searchable/filterable report lists, photo viewing, status updates, remarks, crew assignment	Web, Desktop
Monthly Community Reports	Auto-generated summaries with charts, resolution rates, average resolution time; PDF and CSV export	Web, Desktop
Proposed Additional Features
Module	Description	Platform Support
Notifications & Announcements	In-app notifications for status changes and collection reminders; admin announcements for schedule changes	Mobile, Web
Waste Segregation Guide & Contacts	Educational content on proper waste sorting; FAQ section; waste office contact numbers	Mobile, Web
Duplicate Report Flagging	System flags potential duplicates based on category, location, and date for admin review	Web, Desktop
Resident Feedback	Post-resolution ratings and comments to measure service quality	Mobile, Web
Local Data Persistence (Offline Cache)	SQLite caching for schedules and reports; offline draft saving with auto-sync	Mobile, Desktop
Audit/Activity Log	Records admin actions (status changes, schedule edits) with timestamps	Web, Desktop
Out of Scope
The following features are explicitly excluded from this project:

Real-time GPS tracking of garbage trucks and route optimization

Payment or billing for waste collection fees

IoT or smart bin sensors; AI-based image classification

SMS or email gateway integration (requires paid services)

Integration with official government systems or multi-LGU deployment

Cloud deployment and public hosting (local development server only)

App Store or Google Play Store publishing

System Architecture
Technology Stack
Frontend
Framework: Flutter (Dart) - single codebase for Mobile, Web, and Desktop

Mobile: Android (APK primary target); iOS optional (requires macOS)

Web: Chrome, Firefox, Edge/Safari

Desktop: Windows (primary); macOS optional

Local Storage: SQLite for offline caching

Backend
Runtime: Node.js with Express.js (JavaScript)

API: RESTful JSON API

Server: http://localhost:3000

Authentication: JWT with bcrypt-hashed passwords; role-based access control (Resident/Admin)

File Storage: Multer for photo uploads to local /uploads folder

Database
Primary: PostgreSQL (managed via pgAdmin)

Client-side: SQLite for local persistence

Development Tools
Tool	Purpose
Visual Studio Code	Primary IDE
Android Studio	Android development and emulator
Flutter SDK	Cross-platform framework
Node.js & npm	Backend runtime and package management
PostgreSQL & pgAdmin	Database management
Postman	API testing
Figma / Draw.io	UI mockups and diagrams
Google Chrome	Web testing
