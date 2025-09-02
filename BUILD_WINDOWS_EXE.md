# Windows .exe 파일 빌드 가이드

## 🖥️ Windows 환경에서 빌드하기

### 1. Windows PC 준비
- Windows 10/11 PC 필요
- Flutter SDK 설치 필요

### 2. Flutter 설치
```bash
# Flutter 공식 사이트에서 다운로드
# https://flutter.dev/docs/get-started/install/windows

# 설치 후 환경변수 설정
# PATH에 Flutter bin 폴더 추가
```

### 3. 프로젝트 복사
```bash
# 프로젝트를 Windows PC로 복사
git clone <repository-url>
cd gifticon_sender
```

### 4. Windows 데스크톱 지원 활성화
```bash
flutter config --enable-windows-desktop
```

### 5. 의존성 설치
```bash
flutter pub get
```

### 6. Windows 빌드
```bash
# 릴리즈 빌드
flutter build windows --release
```

### 7. 빌드된 파일 위치
```
build/windows/runner/Release/gifticon_sender.exe
```

## 📦 배포 패키지 생성

### 1. 포터블 버전 (권장)
```bash
# 빌드된 폴더를 ZIP으로 압축
cd build/windows/runner/Release
zip -r ../../../GifticonSender_Portable.zip .
```

### 2. 설치 프로그램 생성 (NSIS 사용)
```nsis
!define APPNAME "기프티콘 발송기"
!define COMPANYNAME "별빛도서관"
!define DESCRIPTION "디스코드 기프티콘 자동 발송 프로그램"
!define VERSIONMAJOR 1
!define VERSIONMINOR 0
!define VERSIONBUILD 0

!include "MUI2.nsh"

Name "${APPNAME}"
OutFile "GifticonSender_Setup.exe"
InstallDir "$PROGRAMFILES\${APPNAME}"

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "LICENSE"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

!insertmacro MUI_LANGUAGE "Korean"

Section "install"
    SetOutPath $INSTDIR
    File /r "build\windows\runner\Release\*"
    
    CreateShortCut "$DESKTOP\${APPNAME}.lnk" "$INSTDIR\gifticon_sender.exe"
    CreateShortCut "$SMPROGRAMS\${APPNAME}.lnk" "$INSTDIR\gifticon_sender.exe"
    
    WriteUninstaller "$INSTDIR\uninstall.exe"
SectionEnd

Section "uninstall"
    Delete "$INSTDIR\*"
    RMDir /r "$INSTDIR"
    Delete "$DESKTOP\${APPNAME}.lnk"
    Delete "$SMPROGRAMS\${APPNAME}.lnk"
SectionEnd
```

## 🚀 GitHub Actions 자동 빌드 (권장)

### 1. GitHub Actions 워크플로우 생성
`.github/workflows/build-windows.yml` 파일 생성:

```yaml
name: Build Windows

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: windows-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.9.0'
        channel: 'stable'
    
    - name: Enable Windows desktop
      run: flutter config --enable-windows-desktop
    
    - name: Get dependencies
      run: flutter pub get
    
    - name: Build Windows app
      run: flutter build windows --release
    
    - name: Upload build artifacts
      uses: actions/upload-artifact@v3
      with:
        name: windows-build
        path: build/windows/runner/Release/
```

### 2. 자동 빌드 실행
1. 코드를 GitHub에 푸시
2. Actions 탭에서 빌드 진행 상황 확인
3. 빌드 완료 후 Artifacts에서 .exe 파일 다운로드

## 📋 최종 배포 파일 구조

```
GifticonSender_v1.0.0/
├── gifticon_sender.exe          # 메인 실행 파일
├── data/                        # Flutter 엔진 파일들
├── flutter_windows.dll          # Flutter 런타임
├── README.md                    # 사용자 매뉴얼
├── LICENSE                      # 라이선스
├── sample_data/                 # 샘플 데이터
│   └── gifticon_data.csv
├── sample_images/               # 샘플 이미지
│   ├── 스타벅스/
│   ├── 맥도날드/
│   └── ...
└── GifticonSender_Setup.exe     # 설치 프로그램 (선택사항)
```

## ⚠️ 주의사항

### 빌드 전 확인사항
- [ ] Windows 10/11 환경
- [ ] Flutter SDK 설치 완료
- [ ] Visual Studio Build Tools 설치
- [ ] Windows 10 SDK 설치

### 런타임 요구사항
- [ ] Visual C++ Redistributable 설치
- [ ] Windows 10/11 운영체제
- [ ] 인터넷 연결 (Discord API 사용)

## 🎯 추천 방법

**GitHub Actions 자동 빌드**를 가장 추천합니다:
1. 코드를 GitHub에 푸시
2. 자동으로 Windows .exe 파일 생성
3. Artifacts에서 다운로드
4. Windows PC에서 바로 사용 가능

이 방법이 가장 간단하고 안정적입니다!
