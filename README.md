# flutter_chat — Real-Time Chat App

> A minimal real-time chat application built with Flutter and Firebase: email/password auth plus a shared, live-updating message feed backed by Cloud Firestore.

## Why

Built as a hands-on exercise to learn the core Flutter + Firebase stack end to end: wiring up Firebase Authentication, persisting data in Cloud Firestore, and rendering a live message stream with `StreamBuilder`. The goal was a working slice of a chat product (auth → send → real-time read), not a fully featured messenger.

## Status

🟢 개선 (2026-07-13) — **메시지 전송 UI 연결**(이전엔 보낼 방법이 없었음), 로그인/회원가입 실패 피드백 추가, 본인/상대 버블 구분, 오타·미사용 스텁 정리.

> ⚠️ 이 변경은 Flutter SDK가 없는 환경에서 작성돼 **컴파일/실행 검증을 거치지 못했습니다.** `flutter run`으로 확인 필요.

## Features

Confirmed in source:

- **Email/password authentication** — sign up, sign in, and sign out via Firebase Auth (`auth_service.dart`).
- **Send messages** — writes `{ message, sender, timestamp }` documents to the Firestore `chats` collection (`chat_service.dart`).
- **Real-time message feed** — `ChatScreen` subscribes to the `chats` collection with a Firestore snapshot stream, ordered by server timestamp (newest first), so new messages appear live.
- **Navigation flow** — sign-in screen → sign-up screen → chat screen, with logout returning to sign-in.
- **Message model** — `Message.fromDocument` factory maps Firestore documents to typed objects, with required-field validation.

- **Message composer + bubbles** — `ChatScreen`에 입력창(엔터/전송 버튼)을 추가해 `ChatService.sendMessage`를 호출하고, 본인/상대를 좌우·색으로 구분하는 `MessageBubble`을 렌더한다. (2026-07-13 연결)
- **Auth 실패 피드백** — 로그인/회원가입 실패 시 `SnackBar`로 안내(이전엔 조용히 무시).

Not implemented: channels/topics, media/image sharing, push notifications, Google/OAuth sign-in. (빈 스텁이던 `message_bubble.dart`·`message_input.dart`는 제거하고 `MessageBubble`을 `chat_screen.dart`에 인라인 구현.)

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
```

(빈 스텁이던 `widgets/message_bubble.dart`·`message_input.dart`는 제거 — 입력창·버블은 `chat_screen.dart`에 구현.)

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

- [x] 메시지 작성 UI + `ChatService.sendMessage`를 `ChatScreen`에 연결 (2026-07-13)
- [x] `MessageBubble` 본인/상대 정렬·색 구분 (2026-07-13)
- [x] Auth 실패 사용자 피드백(SnackBar) (2026-07-13)
- [ ] 원시 UID 대신 표시 이름(닉네임) 저장·표시
- [ ] 입력 유효성(빈 값·이메일 형식) 강화 + 전송 중 로딩 표시
- [ ] Firebase 의존성 상향(core 2→3 등) + `flutter_lints` 2→최신

## Changelog

### 2026-07-13 — 채팅 전송 UX 연결 + 정리
- **메시지 전송 가능화**: `ChatScreen`에 입력창(엔터/버튼) 추가 → `ChatService.sendMessage` 호출(이전엔 전송 UI가 없어 메시지를 보낼 수 없었음)
- **버블 UI**: 본인/상대를 좌우·색으로 구분해 표시(원시 UID 6자 축약)
- **Auth 피드백**: 로그인·회원가입 실패 시 SnackBar 안내(빈 `else{}`로 무시되던 문제)
- **정리**: "Sigin In/Up" 오타, 'Flutter Demo' 타이틀·템플릿 주석·미사용 import 제거, 빈 스텁 위젯 2개 삭제, async 후 `mounted` 가드
- ⚠️ Flutter SDK 부재로 **컴파일/실행 미검증** — 구버전 호환(로컬 null 승격, `State.mounted`)에 유의해 작성. `flutter run` 확인 필요
