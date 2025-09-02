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
    
    # 샘플 데이터 복사
    SetOutPath "$INSTDIR\sample_data"
    File "sample_data\*"
    
    # 샘플 이미지 복사
    SetOutPath "$INSTDIR\sample_images"
    File /r "sample_images\*"
    
    # 문서 복사
    File "README.md"
    File "LICENSE"
    File "TEST_GUIDE.md"
    
    # 바로가기 생성
    CreateShortCut "$DESKTOP\${APPNAME}.lnk" "$INSTDIR\gifticon_sender.exe"
    CreateShortCut "$SMPROGRAMS\${APPNAME}.lnk" "$INSTDIR\gifticon_sender.exe"
    
    # 제거 프로그램 등록
    WriteUninstaller "$INSTDIR\uninstall.exe"
    
    # 레지스트리 등록
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "DisplayName" "${APPNAME}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "UninstallString" "$INSTDIR\uninstall.exe"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "Publisher" "${COMPANYNAME}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "DisplayVersion" "${VERSIONMAJOR}.${VERSIONMINOR}.${VERSIONBUILD}"
SectionEnd

Section "uninstall"
    Delete "$INSTDIR\*"
    RMDir /r "$INSTDIR"
    Delete "$DESKTOP\${APPNAME}.lnk"
    Delete "$SMPROGRAMS\${APPNAME}.lnk"
    
    # 레지스트리 제거
    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}"
SectionEnd
