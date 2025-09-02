# Windows .exe 빌드 가이드

이 가이드는 macOS에서 개발된 Flutter 앱을 Windows .exe 파일로 빌드하는 방법을 설명합니다.

## 방법 1: Windows 환경에서 직접 빌드 (권장)

### 1. Windows 환경 준비

1. **Windows 10/11 PC 준비**
2. **Flutter SDK 설치**
   ```bash
   # Flutter 공식 사이트에서 다운로드
   # https://flutter.dev/docs/get-started/install/windows
   ```

3. **필요한 도구 설치**
   ```bash
   flutter doctor
   # 필요한 도구들을 설치하라는 안내를 따르세요
   ```

### 2. 프로젝트 설정

1. **프로젝트 복사**
   ```bash
   # 프로젝트를 Windows PC로 복사
   git clone <repository-url>
   cd gifticon_sender
   ```

2. **Windows 데스크톱 지원 활성화**
   ```bash
   flutter config --enable-windows-desktop
   ```

3. **의존성 설치**
   ```bash
   flutter pub get
   ```

### 3. 빌드 실행

1. **릴리즈 빌드**
   ```bash
   flutter build windows --release
   ```

2. **빌드된 파일 위치**
   ```
   build/windows/runner/Release/gifticon_sender.exe
   ```

## 방법 2: GitHub Actions를 이용한 자동 빌드

### 1. GitHub Actions 워크플로우 생성

`.github/workflows/build-windows.yml` 파일을 생성합니다:

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

## 방법 3: Docker를 이용한 크로스 컴파일

### 1. Dockerfile 생성

```dockerfile
FROM ubuntu:20.04

# 필요한 패키지 설치
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Flutter 설치
RUN git clone https://github.com/flutter/flutter.git /flutter
ENV PATH="/flutter/bin:/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Flutter 설정
RUN flutter config --no-analytics
RUN flutter config --enable-windows-desktop

# 작업 디렉토리 설정
WORKDIR /app

# 프로젝트 파일 복사
COPY . .

# 의존성 설치 및 빌드
RUN flutter pub get
RUN flutter build windows --release

# 빌드 결과물을 호스트로 복사
CMD ["cp", "-r", "build/windows/runner/Release/", "/output/"]
```

### 2. Docker 빌드 실행

```bash
# Docker 이미지 빌드
docker build -t gifticon-sender-builder .

# 컨테이너 실행 및 결과물 추출
docker run --rm -v $(pwd)/output:/output gifticon-sender-builder
```

## 배포 패키지 생성

### 1. NSIS를 이용한 설치 프로그램 생성

1. **NSIS 설치**
   - https://nsis.sourceforge.io/ 에서 다운로드

2. **설치 스크립트 생성** (`installer.nsi`)
   ```nsis
   !define APPNAME "기프티콘 발송기"
   !define COMPANYNAME "Gifticon Sender Team"
   !define DESCRIPTION "디스코드 기프티콘 자동 발송 프로그램"
   !define VERSIONMAJOR 1
   !define VERSIONMINOR 0
   !define VERSIONBUILD 0

   !include "MUI2.nsh"

   Name "${APPNAME}"
   OutFile "GifticonSender_Setup.exe"
   InstallDir "$PROGRAMFILES\${APPNAME}"

   !insertmacro MUI_PAGE_WELCOME
   !insertmacro MUI_PAGE_LICENSE "LICENSE.txt"
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

3. **설치 프로그램 빌드**
   ```bash
   makensis installer.nsi
   ```

### 2. 포터블 버전 생성

빌드된 폴더를 ZIP으로 압축하여 포터블 버전을 만들 수 있습니다:

```bash
cd build/windows/runner/Release
zip -r ../../../GifticonSender_Portable.zip .
```

## 배포 체크리스트

- [ ] Windows 10/11에서 테스트 완료
- [ ] 바이러스 검사 통과
- [ ] 설치 프로그램 생성
- [ ] 사용자 매뉴얼 작성
- [ ] 라이선스 파일 포함
- [ ] 버전 정보 설정

## 문제 해결

### 빌드 오류

1. **Visual Studio Build Tools 누락**
   ```bash
   # Visual Studio Build Tools 2019 이상 설치 필요
   # https://visualstudio.microsoft.com/downloads/
   ```

2. **Windows SDK 누락**
   ```bash
   # Windows 10 SDK 설치 필요
   ```

3. **Flutter 버전 호환성**
   ```bash
   flutter --version
   flutter upgrade
   ```

### 런타임 오류

1. **Visual C++ Redistributable 누락**
   - Microsoft Visual C++ Redistributable 설치 필요

2. **권한 문제**
   - 관리자 권한으로 실행 시도

## 최종 배포 파일 구조

```
GifticonSender_v1.0.0/
├── gifticon_sender.exe          # 메인 실행 파일
├── data/                        # Flutter 엔진 파일들
├── flutter_windows.dll          # Flutter 런타임
├── README.md                    # 사용자 매뉴얼
├── LICENSE                      # 라이선스
└── GifticonSender_Setup.exe     # 설치 프로그램 (선택사항)
```

이 가이드를 따라하면 macOS에서 개발된 Flutter 앱을 Windows .exe 파일로 성공적으로 빌드할 수 있습니다.
