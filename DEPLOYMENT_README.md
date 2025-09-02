# 기프티콘 발송기 - Windows 배포 버전

## 📋 시스템 요구사항

- **운영체제**: Windows 10/11
- **메모리**: 최소 4GB RAM
- **저장공간**: 최소 100MB 여유공간
- **인터넷**: Discord API 연결을 위한 인터넷 연결

## 🚀 설치 방법

### 방법 1: 포터블 버전 (권장)
1. `GifticonSender_Portable.zip` 파일을 다운로드
2. 원하는 폴더에 압축 해제
3. `gifticon_sender.exe` 파일을 더블클릭하여 실행

### 방법 2: 설치 프로그램
1. `GifticonSender_Setup.exe` 파일을 다운로드
2. 관리자 권한으로 실행
3. 설치 마법사를 따라 설치 완료
4. 바탕화면 또는 시작 메뉴에서 실행

## 📁 폴더 구조

```
GifticonSender/
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
│   ├── 쿠팡/
│   ├── 배달의민족/
│   └── 네이버페이/
└── TEST_GUIDE.md               # 테스트 가이드
```

## 🎯 사용 방법

### 1. 디스코드 봇 설정
1. [Discord Developer Portal](https://discord.com/developers/applications)에서 봇 생성
2. 봇 토큰 복사
3. 서버 ID와 채널 ID 확인
4. 앱의 설정 탭에서 정보 입력

### 2. 기프티콘 데이터 준비
1. CSV 파일 준비 (유저명, 기프티콘타입)
2. 기프티콘 이미지를 타입별 폴더에 정리
3. 앱에서 파일과 폴더 선택

### 3. 발송 실행
1. 모든 설정 완료 후 발송 버튼 클릭
2. 발송 진행 상황 확인
3. 발송 내역에서 결과 확인

## ⚠️ 문제 해결

### 자주 발생하는 문제

1. **프로그램이 실행되지 않음**
   - Visual C++ Redistributable 설치
   - 관리자 권한으로 실행 시도

2. **봇 연결 실패**
   - 봇 토큰이 올바른지 확인
   - 봇 권한 설정 확인
   - 서버 ID와 채널 ID 확인

3. **파일 읽기 실패**
   - CSV 파일 형식 확인
   - 파일 경로에 특수문자 없는지 확인
   - 이미지 파일 형식 확인 (jpg, png, gif, webp)

4. **DM 전송 실패**
   - 봇이 서버 멤버에 접근할 수 있는지 확인
   - 사용자명이 정확한지 확인
   - 봇에게 DM 전송 권한이 있는지 확인

## 📞 지원

- **개발자**: 별빛도서관 (Discord star_lib)
- **라이선스**: 개인 사용 제한 라이선스
- **문의**: Discord star_lib

## 🔒 라이선스

이 프로그램은 개인 사용 제한 라이선스 하에 배포됩니다.
- 직접 제공받은 사용자만 사용 가능
- 제3자 재배포, 공유, 판매 금지
- 상업적 용도 사용 금지

자세한 내용은 LICENSE 파일을 참조하세요.

---

**© 2025 별빛도서관 (Discord star_lib)**
