# Assignment10 – Task Manager (SwiftUI + Firebase)

A simple to-do app for iOS built with **SwiftUI**, using **Firebase Authentication** for login and **Cloud Firestore** for real-time task storage. Each user sees only their own tasks.

## Features

- Sign up / log in with email and password
- Add, edit, complete, and delete tasks
- Real-time sync with Firestore
- Progress summary (done vs. remaining)
- Swipe to delete, tap a task to edit
- Clean card-based UI with a shared gradient theme

## Tech Stack

- Swift, SwiftUI (iOS 16+)
- Firebase Auth
- Cloud Firestore
- Swift Package Manager

## Project Structure

```
Assignment10/
├── Assignment10App.swift     # App entry, Firebase setup
├── RootView.swift            # Switches between Login and Task list
├── AuthViewModel.swift       # Sign up / sign in / sign out
├── TaskViewModel.swift       # Firestore CRUD + real-time listener
├── TodoTask.swift            # Task model
├── LoginView.swift           # Login / sign-up screen (+ Theme)
├── TaskListView.swift        # Task list screen
└── TaskEditView.swift        # Add / edit task screen
```

Tasks are stored at `users/{uid}/tasks/{taskId}`.

## Setup

1. Clone the repo and open `Assignment10.xcodeproj` in Xcode.
2. Wait for Swift Package Manager to resolve the Firebase packages.
3. Create a Firebase project and add an iOS app with your bundle identifier.
4. Download your own `GoogleService-Info.plist` and replace the one in `Assignment10/`.
5. In the Firebase console, enable **Authentication → Email/Password** and create a **Firestore Database**.
6. Use these Firestore rules so users can only access their own tasks:

   ```
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{uid}/tasks/{taskId} {
         allow read, write: if request.auth != null && request.auth.uid == uid;
       }
     }
   }
   ```

7. Select a simulator or device and run.

## Author

Sanzida Alam Jerin
