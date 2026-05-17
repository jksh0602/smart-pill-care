# 수정
.dart_tool\package_config.json
.dart_tool\package_graph.json
.idea\libraries\Dart_SDK.xml
.idea\workspace.xml
android\app\src\main\AndroidManifest.xml
android\app\build.gradle.kts
android\app\google-services.json
android\gradle.properties
android\local.properties
ios\Runner\GoogleService-Info.plist
lib\providers\auth_provider.dart
lib\screens\guardian\guardian_dashboard_screen.dart
lib\firebase_options.dart
lib\main.dart
linux\flutter\ephemeral\.plugin_symlinks
windows\flutter\ephemeral\.plugin_symlinks
windows\flutter\generated_plugin_registrant.cc
windows\flutter\generated_plugins.cmake
.flutter-plugins-dependencies
smart_pill_care.iml


# 스마트 복약 관리 앱 - 프로젝트 가이드

## 📁 파일 구조

```
lib/
├── main.dart                          # 앱 진입점, Firebase 초기화
├── core/
│   └── theme/
│       └── app_colors.dart            # 색상/테마 상수
├── models/
│   ├── user_model.dart                # AppUser (어르신/보호자 공통)
│   └── medication_model.dart          # 복약 기록
├── services/
│   └── auth_service.dart              # Firebase Auth + Firestore
├── providers/
│   └── auth_provider.dart             # 상태관리 (Provider)
└── screens/
    ├── home/
    │   └── home_screen.dart            # 홈 - 모드 선택
    ├── auth/
    │   ├── auth_gate_screen.dart       # 로그인/회원가입 선택
    │   ├── login_screen.dart           # 로그인 (공통)
    │   ├── register_screen.dart        # 회원가입 (어르신/보호자 분기)
    │   └── snr_code_display_screen.dart # 어르신 SNR 코드 안내
    ├── elder/
    │   └── elder_main_screen.dart      # 어르신 복약 확인
    └── guardian/
        ├── guardian_dashboard_screen.dart  # 보호자 대시보드
        ├── add_elder_sheet.dart         # SNR 코드로 어르신 추가
        └── elder_detail_screen.dart     # 어르신 상세 모니터링
```

---

## 🔑 SNR 코드 시스템

- **형태**: `SNR-XXXX` (대문자 + 숫자 4자리, 혼동되는 O/I/1/0 제외)
- **발급**: 어르신 회원가입 시 자동 생성 (Firestore 중복 체크)
- **연결 흐름**:
  1. 어르신 회원가입 → SNR 코드 발급 및 화면에 표시
  2. 어르신이 보호자에게 SNR 코드 전달
  3. 보호자 대시보드 → `+` 버튼 → SNR 코드 입력 → 검색 → 연결

---

## 🔥 Firebase 설정

### 1. FlutterFire CLI 설치 및 초기화
```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=YOUR_PROJECT_ID
```

### 2. Firestore 컬렉션 구조

```
users/{uid}
  email: string
  name: string
  role: "elder" | "guardian"
  snrCode: string          # "SNR-A3F7"
  age: number              # 어르신만
  linkedElderCodes: []     # 보호자만 - 연결된 어르신 SNR 목록
  createdAt: timestamp

medications/{auto_id}
  elderSnrCode: string     # 어떤 어르신의 복약인지
  name: string             # 약 이름
  time: "morning"|"lunch"|"dinner"
  scheduledAt: timestamp
  takenAt: timestamp | null
  status: "pending"|"taken"|"missed"
```

### 3. Firestore 보안 규칙

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // users: 본인만 읽기/쓰기
    // 보호자는 연결된 어르신 정보 읽기 가능
    match /users/{uid} {
      allow read, write: if request.auth.uid == uid;

      // SNR 코드로 어르신 조회 (보호자용)
      allow read: if request.auth != null
        && resource.data.role == 'elder';
    }

    // medications: 본인(어르신) 또는 연결된 보호자
    match /medications/{medId} {
      allow read, write: if request.auth != null
        && (
          // 어르신 본인
          request.auth.uid == resource.data.elderUid
          // 또는 연결된 보호자 (보호자 linkedElderCodes에 포함)
          // 실제 구현 시 Cloud Functions로 처리 권장
        );
    }
  }
}
```

---

## 🚀 시작하기

```bash
# 1. 의존성 설치
flutter pub get

# 2. Firebase 설정
flutterfire configure

# 3. 실행
flutter run
```

---

## 📋 다음 단계 구현 목록

- [ ] 복약 일정 등록/수정 화면 (어르신)
- [ ] 실시간 복약 현황 스트림 (보호자 상세)
- [ ] 복약 캘린더 (4주 히트맵)
- [ ] 로컬 알림 (flutter_local_notifications)
- [ ] 푸시 알림 (FCM - 미복약 시 보호자에게)
- [ ] 움직임 센서 연동 (accelerometer)
- [ ] AI 복약 패턴 분석 (Cloud Functions + Gemini API)
- [ ] PDF 리포트 다운로드
