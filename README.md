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
- **Backend** — Firebase (firebase_core는 3.x로 고정 — 4.x가 `pluginConstants`를 제거해 auth와 조합 시 웹 빌드가 깨짐):
  - `firebase_core` `>=3.0.0 <4.0.0`
  - `firebase_auth` `>=5.0.0 <6.0.0` (authentication)
  - `cloud_firestore` `>=5.0.0 <6.0.0` (message storage + real-time stream)
- **Lint** — `flutter_lints` ^6.0.0
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
2. Run `flutterfire configure` to regenerate `lib/firebase_options.dart` for your project. `main.dart` passes `DefaultFirebaseOptions.currentPlatform` to `Firebase.initializeApp()`, so web·desktop도 이 파일이 있어야 초기화된다 (`firebase_options.dart`는 `.gitignore` 대상).
3. **Firestore 보안 규칙을 반드시 잠글 것.** Firebase 클라이언트 apiKey는 빌드에 실려 공개되므로, 실제 방어선은 규칙이다. 규칙은 이제 텍스트가 아니라 배포 가능한 [`firestore.rules`](firestore.rules) 파일로 버전 관리한다 — `firebase.json`이 이를 가리킨다. 배포:

   ```bash
   firebase deploy --only firestore:rules
   ```

   > 프로젝트 연결(`.firebaserc`)이 없으면 `firebase use --add`로 대상 프로젝트를 먼저 지정한다. `.firebaserc`는 프로젝트 ID를 담아 `.gitignore` 대상이다.

   `firestore.rules`가 강제하는 최소 규칙(참고): `chats` 컬렉션은 **로그인 사용자만 읽기**, **본인 uid(`sender == auth.uid`)로만 작성**, **수정·삭제 금지**, 그 외 경로는 **전면 차단(기본 deny)**. 문서 구조 `{ message, sender, timestamp }`와 `sender = 작성자 uid`는 `lib/services/chat_service.dart`·`chat_screen.dart`와 일치한다.

## Roadmap

- [x] 메시지 작성 UI + `ChatService.sendMessage`를 `ChatScreen`에 연결 (2026-07-13)
- [x] `MessageBubble` 본인/상대 정렬·색 구분 (2026-07-13)
- [x] Auth 실패 사용자 피드백(SnackBar) (2026-07-13)
- [x] Firebase 의존성 상향(core 3.x 고정·auth/firestore 5.x) + `flutter_lints` 6, 웹/데스크톱 초기화 배선 (2026-07-15)
- [ ] 원시 UID 대신 표시 이름(닉네임) 저장·표시
- [ ] 입력 유효성(빈 값·이메일 형식) 강화 + 전송 중 로딩 표시

## Changelog

### 2026-07-16 — Firestore 규칙 파일화
- **`firestore.rules` + `firebase.json` 추가**: README 텍스트로만 있던 보안 규칙을 배포 가능한 파일로 분리해 버전 관리 대상으로 전환. `firebase deploy --only firestore:rules`로 배포. 규칙 내용(로그인만 read·`sender==auth.uid`만 create·update/delete 금지·기본 deny)은 코드의 문서 구조 `{ message, sender, timestamp }`와 일치 확인. `.firebaserc`는 프로젝트 ID 소유자가 로컬 생성.

### 2026-07-15 — 웹 빌드 복구 + 입력 UX + 공개
- **웹/데스크톱 초기화**: `main.dart`가 `DefaultFirebaseOptions.currentPlatform`을 넘겨 `initializeApp` — 인자 없이 호출하면 네이티브 설정이 있는 Android/iOS만 초기화되고 웹은 실패하던 문제 해결
- **firebase_core 3.x 고정**: 4.x가 `FirebasePluginPlatform.pluginConstants`를 제거했는데 auth 6.5.5가 이를 참조해 웹(dart2js) 컴파일이 깨짐 → core를 3.x로 고정해 pub이 호환 조합(3.15.2/5.7.0/5.6.12)을 선택하게 함
- **입력 UX**: 엔터 전송 후 `FocusNode`로 입력창에 포커스 복귀(연속 입력), 전송 중 중복 전송 차단, 전송 실패 시 SnackBar, 전송 성공 후에만 입력창 비움(실패 시 글 보존), 메시지 시각 표시·`SelectableText`
- **실기 검증**: `flutter run -d edge`로 회원가입→메시지 전송→실시간 반영 성공(2026-07-14)
- **공개 전환**: 저장소 public (히스토리엔 Firebase **클라이언트** 키만 — 비밀 아님, 실제 방어선은 Firestore 규칙). Setup에 잠금 규칙 문서화

### 2026-07-13 — 채팅 전송 UX 연결 + 정리
- **메시지 전송 가능화**: `ChatScreen`에 입력창(엔터/버튼) 추가 → `ChatService.sendMessage` 호출(이전엔 전송 UI가 없어 메시지를 보낼 수 없었음)
- **버블 UI**: 본인/상대를 좌우·색으로 구분해 표시(원시 UID 6자 축약)
- **Auth 피드백**: 로그인·회원가입 실패 시 SnackBar 안내(빈 `else{}`로 무시되던 문제)
- **정리**: "Sigin In/Up" 오타, 'Flutter Demo' 타이틀·템플릿 주석·미사용 import 제거, 빈 스텁 위젯 2개 삭제, async 후 `mounted` 가드
- ⚠️ Flutter SDK 부재로 **컴파일/실행 미검증** — 구버전 호환(로컬 null 승격, `State.mounted`)에 유의해 작성. `flutter run` 확인 필요
