# FocusFlow

A native iOS SwiftUI productivity tracker with social features.

## Features

- **Auth** — Sign up / sign in with email + password; 3-step onboarding (name → avatar color → team)
- **Tasks** — Todo list with 6 categories, swipe-to-complete, play button to start focus
- **Focus** — 25-minute circular ring timer with pulse animation, SVG play/pause controls, session logging
- **Feed** — Team members row, session cards, clap reactions on teammates' sessions
- **Groups** — Browse and join groups, create custom groups, group feed with likes & comments
- **Profile** — Avatar with photo picker, stats, friends row, personal posts
- **Settings** — Theme picker (8 gradients), language (EN/TR), avatar color, profile edit
- **Day Summary** — Bottom sheet at 21:00 with animated category bars and task breakdown

## Tech Stack

- SwiftUI (iOS 17+)
- MVVM with `ObservableObject` view models
- `UserDefaults` persistence
- `PhotosUI` for photo picker
- Combine for timer
- Custom `ViewModifier` for card/pill styles
- English + Turkish localisation (`Localizable.strings`)

## Design

- Dark sunrise gradient palette
- Coral `#F07A5A`, Gold `#F5C26A`, Rose `#D4607E`, Lavender `#9B7EC8`
- DM Serif Display (headings) · DM Mono (stats) · DM Sans (body)
- Frosted-glass tab bar, spring animations, pulse keyframes

## File Structure

```
FocusFlow/
├── App/               FocusFlowApp.swift
├── Models/            User, Task, Session, Group, Post
├── ViewModels/        AuthViewModel, TaskViewModel, FocusViewModel, AppViewModel
├── Components/        AvatarView, RingTimerView, PostCardView, DaySummarySheet, ViewModifiers
├── Views/
│   ├── Auth/          AuthView, OnboardingView
│   ├── Tasks/         TasksView, AddTaskSheet
│   ├── Focus/         FocusView
│   ├── Feed/          FeedView
│   ├── Groups/        GroupsView, GroupDetailView, CreateGroupSheet
│   ├── Profile/       ProfileView
│   ├── Settings/      SettingsView
│   └── MainTabView.swift
└── Resources/
    ├── en.lproj/Localizable.strings
    ├── tr.lproj/Localizable.strings
    └── Info.plist
```

## Setup

1. Clone the repo
2. Open `FocusFlow.xcodeproj` in Xcode 15+
3. Select an iOS 17 simulator or device
4. Build & run (`Cmd+R`)

> **Note:** DM Serif Display, DM Mono, and DM Sans fonts must be added to the project and listed in `Info.plist` under `UIAppFonts` for full visual fidelity. Download them from [Google Fonts](https://fonts.google.com).
