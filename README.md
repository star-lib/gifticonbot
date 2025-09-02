# 기프티콘 발송기 (Gifticon Sender)

디스코드 서버 이벤트에서 당첨된 사용자들에게 기프티콘을 자동으로 DM으로 발송하는 Flutter 앱입니다.

## 주요 기능

- 📁 **CSV/JSON 파일 지원**: 기프티콘 데이터를 CSV 또는 JSON 형식으로 읽어옵니다
- 🖼️ **이미지 폴더 관리**: 기프티콘 이미지를 타입별로 폴더에 정리하여 관리합니다
- 🤖 **디스코드 봇 연동**: Discord API를 통해 자동으로 DM을 발송합니다
- 📊 **발송 내역 관리**: 발송된 기프티콘의 중복 방지 및 발송 내역을 추적합니다
- 🎨 **사용자 친화적 UI**: 직관적이고 아름다운 사용자 인터페이스를 제공합니다

## 시스템 요구사항

- **개발 환경**: macOS (Flutter 개발용)
- **사용 환경**: Windows 10/11 (최종 사용자용)
- **Flutter**: 3.9.0 이상
- **Dart**: 3.0.0 이상

## 설치 및 실행

### 개발 환경에서 실행

1. **저장소 클론**
   ```bash
   git clone <repository-url>
   cd gifticon_sender
   ```

2. **의존성 설치**
   ```bash
   flutter pub get
   ```

3. **앱 실행**
   ```bash
   flutter run
   ```

### Windows .exe 파일 빌드

Windows에서 .exe 파일을 생성하려면:

1. **Windows 환경에서 Flutter 설정**
   ```bash
   flutter config --enable-windows-desktop
   ```

2. **Windows 빌드**
   ```bash
   flutter build windows --release
   ```

3. **빌드된 파일 위치**
   ```
   build/windows/runner/Release/gifticon_sender.exe
   ```

## 사용 방법

### 1. 디스코드 봇 설정

1. [Discord Developer Portal](https://discord.com/developers/applications)에서 새 애플리케이션 생성
2. 봇 섹션에서 "New Bot" 클릭
3. 봇 토큰을 복사하여 앱의 설정 탭에 입력
4. 봇에게 다음 권한 부여:
   - Send Messages
   - Read Message History
   - Use Slash Commands

### 2. 기프티콘 데이터 준비

#### CSV 형식
```csv
사용자명,기프티콘타입,상품명,금액,유효기간,쿠폰번호,메시지
홍길동,스타벅스,아메리카노,5000원,2024-12-31,ABC123,축하합니다!
김철수,맥도날드,빅맥세트,8000원,2024-12-31,DEF456,이벤트 당첨!
```

#### JSON 형식
```json
[
  {
    "username": "홍길동",
    "gifticonType": "스타벅스",
    "gifticonName": "아메리카노",
    "gifticonValue": "5000원",
    "gifticonExpiry": "2024-12-31",
    "gifticonCode": "ABC123",
    "message": "축하합니다!"
  }
]
```

### 3. 기프티콘 이미지 폴더 구조

```
기프티콘_이미지/
├── 스타벅스/
│   ├── gifticon1.jpg
│   ├── gifticon2.png
│   └── gifticon3.jpg
├── 맥도날드/
│   ├── gifticon1.jpg
│   └── gifticon2.png
└── 쿠팡/
    └── gifticon1.jpg
```

### 4. 앱 사용 순서

1. **설정 탭**: 디스코드 봇 토큰 입력 및 연결 확인
2. **발송 탭**: 
   - 기프티콘 데이터 파일 선택 (CSV 또는 JSON)
   - 기프티콘 이미지 폴더 선택
   - 발송 버튼 클릭
3. **발송내역 탭**: 발송된 기프티콘 내역 확인

## 프로젝트 구조

```
lib/
├── models/           # 데이터 모델
│   └── gifticon_data.dart
├── services/         # 비즈니스 로직
│   ├── file_service.dart
│   └── discord_service.dart
├── providers/        # 상태 관리
│   └── gifticon_provider.dart
├── screens/          # 화면
│   ├── main_screen.dart
│   ├── send_screen.dart
│   ├── settings_screen.dart
│   └── history_screen.dart
└── main.dart         # 앱 진입점
```

## 주요 기능 설명

### 파일 서비스 (FileService)
- CSV/JSON 파일 읽기 및 파싱
- 기프티콘 이미지 폴더 분석
- 발송 완료 파일 관리
- 중복 발송 방지

### 디스코드 서비스 (DiscordService)
- 봇 토큰 검증
- DM 채널 생성
- 텍스트 및 이미지 메시지 전송
- 임베드 메시지 지원

### 상태 관리 (GifticonProvider)
- 앱 전체 상태 관리
- 파일 로드 및 폴더 분석
- 발송 프로세스 관리
- 에러 처리

## 개발자 정보

- **개발자**: 별빛도서관 (Discord star_lib)
- **버전**: 1.0.0
- **라이선스**: 개인 사용 제한 라이선스

## 문제 해결

### 자주 발생하는 문제

1. **봇 연결 실패**
   - 봇 토큰이 올바른지 확인
   - 봇에게 필요한 권한이 부여되었는지 확인

2. **파일 읽기 실패**
   - 파일 형식이 올바른지 확인 (CSV 또는 JSON)
   - 파일 경로에 특수문자가 없는지 확인

3. **이미지 폴더 분석 실패**
   - 폴더 구조가 올바른지 확인
   - 이미지 파일 확장자가 지원되는 형식인지 확인 (jpg, jpeg, png, gif, webp)

## 기여하기

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 라이선스

이 프로젝트는 개인 사용 제한 라이선스 하에 배포됩니다. 

**중요**: 이 프로그램은 직접 제공받은 사용자만 사용할 수 있으며, 제3자에게 재배포하거나 공유하는 것을 금지합니다.

자세한 내용은 `LICENSE` 파일을 참조하세요.