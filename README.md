# flutter_chat — Real-Time Chat App

> A minimal real-time chat application built with Flutter and Firebase: email/password auth plus a shared, live-updating message feed backed by Cloud Firestore.

## Why

Built as a hands-on exercise to learn the core Flutter + Firebase stack end to end: wiring up Firebase Authentication, persisting data in Cloud Firestore, and rendering a live message stream with `StreamBuilder`. The goal was a working slice of a chat product (auth → send → real-time read), not a fully featured messenger.

## Status

⚫ Dormant — last commit `2023-10-26`. Functional core, but unfinished UI widgets remain (see Roadmap).

## Features

Confirmed in source:

- **Email/password authentication** — sign up, sign in, and sign out via Firebase Auth (`auth_service.dart`).
- **Send messages** — writes `{ message, sender, timestamp }` documents to the Firestore `chats` collection (`chat_service.dart`).
- **Real-time message feed** — `ChatScreen` subscribes to the `chats` collection with a Firestore snapshot stream, ordered by server timestamp (newest first), so new messages appear live.
- **Navigation flow** — sign-in screen → sign-up screen → chat screen, with logout returning to sign-in.
- **Message model** — `Message.fromDocument` factory maps Firestore documents to typed objects, with required-field validation.

Not implemented (despite earlier claims): channels/topics, media/image sharing, push notifications, and Google/OAuth sign-in. The `MessageBubble` and `MessageInput` widget files exist but are empty stubs. There is currently no in-app UI to compose/send a message — `ChatService.sendMessage` and the message model are not yet wired into a screen.

## Stack

- **Flutter / Dart** — Dart SDK `>=3.1.4 <4.0.0`, Material 3 theming.
- **State management** — none beyond `StatefulWidget` + `StreamBuilder` (no external state library).
- **Backend** — Firebase:
  - `firebase_core` ^2.20.0
  - `firebase_auth` ^4.12.0 (authentication)
  - `cloud_firestore` ^4.12.0 (message storage + real-time stream)
- **Lint** — `flutter_lints` ^2.0.0
- Cross-platform scaffolding present for Android, iOS, web, macOS, Linux, and Windows.

## Structure

```
lib/
├── main.dart                 # App entry; initializes Firebase, sets AuthScreen as home
├── firebase_options.dart     # FlutterFire-generated platform config
├── models/
│   └── message.dart          # Message model + fromDocument factory
├── screens/
│   ├── signIn_screen.dart    # Email/password sign-in (AuthScreen)
│   ├── signUp_screen.dart    # Account registration
│   └── chat_screen.dart      # Live Firestore message stream + logout
├── services/
│   ├── auth_service.dart     # Firebase Auth wrapper (sign up/in/out)
│   └── chat_service.dart     # Firestore message writes
└── widgets/
    ├── message_bubble.dart   # (empty stub)
    └── message_input.dart    # (empty stub)
```

## Run

```bash
flutter pub get
flutter run
```

**Firebase setup required.** The app calls `Firebase.initializeApp()` and talks to a live Firestore/Auth backend, so you need your own Firebase project:

1. Create a Firebase project; enable Email/Password authentication and Cloud Firestore.
2. Run `flutterfire configure` to regenerate `lib/firebase_options.dart` for your project (note: `main.dart` currently calls `Firebase.initializeApp()` without passing `DefaultFirebaseOptions.currentPlatform` — pass it, or rely on the native platform config files).
3. Add a Firestore security rule set appropriate for your use case before any real deployment.

## Roadmap

- [ ] Build the message composer UI (fill in `MessageInput`) and wire `ChatService.sendMessage` into `ChatScreen`.
- [ ] Implement `MessageBubble` with sender alignment/styling and use the `Message` model in the feed.
- [ ] Add input validation and user-facing error handling for auth failures (currently failures are silently swallowed).
- [ ] Persist/display a friendly user identity instead of raw UID, and add per-user message styling.
