import 'package:flutter/material.dart';
import '../models/gifticon_data.dart';
import '../services/file_service.dart';
import '../services/discord_service.dart';

class GifticonProvider extends ChangeNotifier {
  List<GifticonData> _gifticonData = [];
  Map<String, List<String>> _folderStructure = {};
  String? _selectedFolderPath;
  String? _botToken;
  String? _serverId;
  String? _logChannelId;
  String? _dmLogChannelId;
  bool _isConnected = false;
  List<SentGifticon> _sentGifticons = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<GifticonData> get gifticonData => _gifticonData;
  Map<String, List<String>> get folderStructure => _folderStructure;
  String? get selectedFolderPath => _selectedFolderPath;
  String? get botToken => _botToken;
  String? get serverId => _serverId;
  String? get logChannelId => _logChannelId;
  String? get dmLogChannelId => _dmLogChannelId;
  bool get isConnected => _isConnected;
  List<SentGifticon> get sentGifticons => _sentGifticons;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // CSV 파일에서 기프티콘 데이터 로드
  Future<void> loadGifticonDataFromCSV() async {
    _setLoading(true);
    _clearError();
    
    try {
      _gifticonData = await FileService.readGifticonDataFromCSV();
      notifyListeners();
    } catch (e) {
      _setError('CSV 파일 로드 실패: $e');
    } finally {
      _setLoading(false);
    }
  }

  // JSON 파일에서 기프티콘 데이터 로드
  Future<void> loadGifticonDataFromJSON() async {
    _setLoading(true);
    _clearError();
    
    try {
      _gifticonData = await FileService.readGifticonDataFromJSON();
      notifyListeners();
    } catch (e) {
      _setError('JSON 파일 로드 실패: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 기프티콘 폴더 선택 및 분석
  Future<void> selectAndAnalyzeGifticonFolder() async {
    _setLoading(true);
    _clearError();
    
    try {
      String? folderPath = await FileService.selectGifticonFolder();
      if (folderPath != null) {
        _selectedFolderPath = folderPath;
        _folderStructure = await FileService.analyzeGifticonFolder(folderPath);
        notifyListeners();
      }
    } catch (e) {
      _setError('폴더 분석 실패: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 봇 설정 및 연결 확인
  Future<void> setBotConfig(String token, String serverId, String logChannelId, String dmLogChannelId) async {
    _setLoading(true);
    _clearError();
    
    try {
      _botToken = token;
      _serverId = serverId;
      _logChannelId = logChannelId;
      _dmLogChannelId = dmLogChannelId;
      
      DiscordService discordService = DiscordService(
        botToken: token,
        serverId: serverId,
        logChannelId: logChannelId,
        dmLogChannelId: dmLogChannelId,
      );
      
      // 봇 토큰 검증
      bool tokenValid = await discordService.validateBotToken();
      if (!tokenValid) {
        _setError('봇 토큰이 유효하지 않습니다');
        _isConnected = false;
        notifyListeners();
        return;
      }
      
      // 서버 정보 확인
      var serverInfo = await discordService.getServerInfo();
      if (serverInfo == null) {
        _setError('서버 ID가 유효하지 않거나 봇이 해당 서버에 접근할 수 없습니다');
        _isConnected = false;
        notifyListeners();
        return;
      }
      
      // 로그 채널 정보 확인
      var channelInfo = await discordService.getChannelInfo();
      if (channelInfo == null) {
        _setError('로그 채널 ID가 유효하지 않거나 봇이 해당 채널에 접근할 수 없습니다');
        _isConnected = false;
        notifyListeners();
        return;
      }
      
      // DM 로그 채널 정보 확인
      var dmLogChannelInfo = await discordService.getDmLogChannelInfo();
      if (dmLogChannelInfo == null) {
        _setError('DM 로그 채널 ID가 유효하지 않거나 봇이 해당 채널에 접근할 수 없습니다');
        _isConnected = false;
        notifyListeners();
        return;
      }
      
      _isConnected = true;
      debugPrint('봇 연결 성공: ${serverInfo['name']} - ${channelInfo['name']} - ${dmLogChannelInfo['name']}');
      
      notifyListeners();
    } catch (e) {
      _setError('봇 연결 실패: $e');
      _isConnected = false;
    } finally {
      _setLoading(false);
    }
  }

  // 기프티콘 발송
  Future<void> sendGifticons() async {
    if (!_isConnected || _botToken == null || _serverId == null || _logChannelId == null || _dmLogChannelId == null) {
      _setError('봇이 연결되지 않았습니다');
      return;
    }

    if (_gifticonData.isEmpty) {
      _setError('발송할 기프티콘 데이터가 없습니다');
      return;
    }

    if (_folderStructure.isEmpty) {
      _setError('기프티콘 이미지 폴더가 선택되지 않았습니다');
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      DiscordService discordService = DiscordService(
        botToken: _botToken!,
        serverId: _serverId!,
        logChannelId: _logChannelId!,
        dmLogChannelId: _dmLogChannelId!,
      );
      
      int successCount = 0;
      int failCount = 0;

      for (GifticonData data in _gifticonData) {
        try {
          // 사용자 ID 찾기
          String? userId = await discordService.findUserIdByUsername(data.username);
          if (userId == null) {
            debugPrint('${data.username} 사용자를 찾을 수 없습니다');
            await discordService.sendLogMessage(data.username, data.gifticonType, false, 
                errorMessage: '사용자를 찾을 수 없음');
            failCount++;
            continue;
          }

          // 해당 타입의 이미지 파일 찾기
          List<String>? imageFiles = _folderStructure[data.gifticonType];
          if (imageFiles == null || imageFiles.isEmpty) {
            debugPrint('${data.gifticonType} 타입의 이미지를 찾을 수 없습니다');
            await discordService.sendLogMessage(data.username, data.gifticonType, false, 
                errorMessage: '이미지 파일 없음');
            failCount++;
            continue;
          }

          // 사용되지 않은 이미지 찾기
          String? availableImage;
          for (String imagePath in imageFiles) {
            bool isUsed = await FileService.isGifticonUsed(imagePath);
            if (!isUsed) {
              availableImage = imagePath;
              break;
            }
          }

          if (availableImage == null) {
            debugPrint('${data.gifticonType} 타입의 사용 가능한 이미지가 없습니다');
            await discordService.sendLogMessage(data.username, data.gifticonType, false, 
                errorMessage: '사용 가능한 이미지 없음');
            failCount++;
            continue;
          }

          // 메시지 생성
          String message = _createMessage(data);

          // DM 전송
          bool sent = await discordService.sendDirectMessage(
            userId,
            message,
            imagePath: availableImage,
          );

          if (sent) {
            // 발송 완료 폴더로 이동
            String newPath = await FileService.moveGifticonToSentFolder(
              availableImage,
              data.username,
              data.gifticonType,
            );

            // 발송 기록 저장
            SentGifticon sentGifticon = SentGifticon(
              originalFilename: availableImage,
              username: data.username,
              gifticonType: data.gifticonType,
              sentAt: DateTime.now(),
              sentFilename: newPath,
            );

            await FileService.saveSentGifticon(sentGifticon);
            
            // 로그 채널에 성공 메시지 전송
            await discordService.sendLogMessage(data.username, data.gifticonType, true);
            
            successCount++;
          } else {
            await discordService.sendLogMessage(data.username, data.gifticonType, false, 
                errorMessage: 'DM 전송 실패');
            failCount++;
          }
        } catch (e) {
          debugPrint('${data.username}에게 발송 실패: $e');
          await discordService.sendLogMessage(data.username, data.gifticonType, false, 
              errorMessage: e.toString());
          failCount++;
        }
      }

      // 발송 내역 새로고침
      await loadSentGifticons();

      if (failCount > 0) {
        _setError('$successCount개 성공, $failCount개 실패');
      } else {
        _clearError();
      }
    } catch (e) {
      _setError('발송 중 오류 발생: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 발송 내역 로드
  Future<void> loadSentGifticons() async {
    try {
      _sentGifticons = await FileService.getSentGifticons();
      notifyListeners();
    } catch (e) {
      debugPrint('발송 내역 로드 실패: $e');
    }
  }

  // 메시지 생성
  String _createMessage(GifticonData data) {
    StringBuffer message = StringBuffer();
    message.writeln('🎉 **기프티콘 당첨을 축하합니다!** 🎉');
    message.writeln();
    message.writeln('**받으신 기프티콘:** ${data.gifticonType}');
    message.writeln();
    message.writeln('기프티콘을 잘 활용해 주세요! 😊');
    
    return message.toString();
  }

  // 데이터 초기화
  void clearData() {
    _gifticonData.clear();
    _folderStructure.clear();
    _selectedFolderPath = null;
    notifyListeners();
  }

  // 에러 메시지 설정
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  // 에러 메시지 초기화
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // 로딩 상태 설정
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
