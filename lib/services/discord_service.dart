import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DiscordService {
  static const String _baseUrl = 'https://discord.com/api/v10';
  
  final String botToken;
  final String serverId;
  final String logChannelId;
  final String dmLogChannelId;
  
  DiscordService({
    required this.botToken,
    required this.serverId,
    required this.logChannelId,
    required this.dmLogChannelId,
  });
  
  /// 서버 멤버 목록에서 사용자 ID를 찾습니다
  Future<String?> findUserIdByUsername(String username) async {
    try {
      Map<String, String> headers = {
        'Authorization': 'Bot $botToken',
      };
      
      // 서버 멤버 목록 조회 (최대 1000명)
      http.Response response = await http.get(
        Uri.parse('$_baseUrl/guilds/$serverId/members?limit=1000'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        List<dynamic> members = json.decode(response.body);
        
        for (var member in members) {
          String memberUsername = member['user']['username'] ?? '';
          String memberDisplayName = member['nick'] ?? memberUsername;
          
          // 사용자명 또는 닉네임이 일치하는지 확인
          if (memberUsername.toLowerCase() == username.toLowerCase() ||
              memberDisplayName.toLowerCase() == username.toLowerCase()) {
            return member['user']['id'];
          }
        }
      }
      
      return null; // 사용자를 찾지 못함
    } catch (e) {
      throw Exception('사용자 ID 찾기 실패: $e');
    }
  }
  
  /// DM을 전송합니다
  Future<bool> sendDirectMessage(String userId, String message, {String? imagePath}) async {
    try {
      // DM 채널 생성
      String dmChannelId = await _createDMChannel(userId);
      
      // 메시지 전송
      Map<String, String> headers = {
        'Authorization': 'Bot $botToken',
        'Content-Type': 'application/json',
      };
      
      Map<String, dynamic> payload = {
        'content': message,
      };
      
      // 이미지가 있는 경우 멀티파트 요청으로 전송
      if (imagePath != null && await File(imagePath).exists()) {
        return await _sendMessageWithImage(dmChannelId, message, imagePath, headers);
      } else {
        return await _sendTextMessage(dmChannelId, payload, headers);
      }
    } catch (e) {
      throw Exception('DM 전송 실패: $e');
    }
  }
  
  /// DM 채널을 생성합니다
  Future<String> _createDMChannel(String userId) async {
    try {
      Map<String, String> headers = {
        'Authorization': 'Bot $botToken',
        'Content-Type': 'application/json',
      };
      
      Map<String, dynamic> payload = {
        'recipient_id': userId,
      };
      
      http.Response response = await http.post(
        Uri.parse('$_baseUrl/users/@me/channels'),
        headers: headers,
        body: json.encode(payload),
      );
      
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        return data['id'];
      } else {
        throw Exception('DM 채널 생성 실패: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('DM 채널 생성 실패: $e');
    }
  }
  
  /// 텍스트 메시지를 전송합니다
  Future<bool> _sendTextMessage(String channelId, Map<String, dynamic> payload, Map<String, String> headers) async {
    try {
      http.Response response = await http.post(
        Uri.parse('$_baseUrl/channels/$channelId/messages'),
        headers: headers,
        body: json.encode(payload),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('텍스트 메시지 전송 실패: $e');
    }
  }
  
  /// 이미지와 함께 메시지를 전송합니다
  Future<bool> _sendMessageWithImage(String channelId, String message, String imagePath, Map<String, String> headers) async {
    try {
      File imageFile = File(imagePath);
      List<int> imageBytes = await imageFile.readAsBytes();
      
      // 멀티파트 요청 생성
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/channels/$channelId/messages'),
      );
      
      request.headers.addAll({
        'Authorization': 'Bot $botToken',
      });
      
      request.fields['content'] = message;
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: imagePath.split('/').last,
        ),
      );
      
      http.StreamedResponse response = await request.send();
      
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('이미지 메시지 전송 실패: $e');
    }
  }
  
  /// 임베드 메시지를 전송합니다
  Future<bool> sendEmbedMessage(String userId, String title, String description, {String? imagePath, String? color}) async {
    try {
      String dmChannelId = await _createDMChannel(userId);
      
      Map<String, String> headers = {
        'Authorization': 'Bot $botToken',
        'Content-Type': 'application/json',
      };
      
      Map<String, dynamic> embed = {
        'title': title,
        'description': description,
        'color': _parseColor(color),
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      Map<String, dynamic> payload = {
        'embeds': [embed],
      };
      
      // 이미지가 있는 경우
      if (imagePath != null && await File(imagePath).exists()) {
        return await _sendMessageWithImage(dmChannelId, '', imagePath, headers);
      } else {
        return await _sendTextMessage(dmChannelId, payload, headers);
      }
    } catch (e) {
      throw Exception('임베드 메시지 전송 실패: $e');
    }
  }
  
  /// 색상 문자열을 정수로 변환합니다
  int _parseColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) {
      return 0x00ff00; // 기본 녹색
    }
    
    // #RRGGBB 형식 처리
    if (colorString.startsWith('#')) {
      String hex = colorString.substring(1);
      return int.parse(hex, radix: 16);
    }
    
    // 기본 색상들
    switch (colorString.toLowerCase()) {
      case 'red':
        return 0xff0000;
      case 'green':
        return 0x00ff00;
      case 'blue':
        return 0x0000ff;
      case 'yellow':
        return 0xffff00;
      case 'purple':
        return 0x800080;
      case 'orange':
        return 0xffa500;
      default:
        return 0x00ff00;
    }
  }
  
  /// 봇 토큰을 검증합니다
  Future<bool> validateBotToken() async {
    try {
      Map<String, String> headers = {
        'Authorization': 'Bot $botToken',
      };
      
      http.Response response = await http.get(
        Uri.parse('$_baseUrl/users/@me'),
        headers: headers,
      );
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  /// 봇 정보를 가져옵니다
  Future<Map<String, dynamic>?> getBotInfo() async {
    try {
      Map<String, String> headers = {
        'Authorization': 'Bot $botToken',
      };
      
      http.Response response = await http.get(
        Uri.parse('$_baseUrl/users/@me'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  /// 로그 채널에 발송 로그를 전송합니다
  Future<bool> sendLogMessage(String username, String gifticonType, bool success, {String? errorMessage}) async {
    try {
      Map<String, String> headers = {
        'Authorization': 'Bot $botToken',
        'Content-Type': 'application/json',
      };
      
      String status = success ? '✅ 성공' : '❌ 실패';
      String message = '**기프티콘 발송 로그**\n'
          '👤 사용자: $username\n'
          '🎁 기프티콘: $gifticonType\n'
          '📊 상태: $status\n'
          '⏰ 시간: ${DateTime.now().toString().substring(0, 19)}';
      
      if (!success && errorMessage != null) {
        message += '\n❌ 오류: $errorMessage';
      }
      
      Map<String, dynamic> payload = {
        'content': message,
      };
      
      http.Response response = await http.post(
        Uri.parse('$_baseUrl/channels/$logChannelId/messages'),
        headers: headers,
        body: json.encode(payload),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  /// 서버 정보를 가져옵니다
  Future<Map<String, dynamic>?> getServerInfo() async {
    try {
      Map<String, String> headers = {
        'Authorization': 'Bot $botToken',
      };
      
      http.Response response = await http.get(
        Uri.parse('$_baseUrl/guilds/$serverId'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  /// 채널 정보를 가져옵니다
  Future<Map<String, dynamic>?> getChannelInfo() async {
    try {
      Map<String, String> headers = {
        'Authorization': 'Bot $botToken',
      };
      
      http.Response response = await http.get(
        Uri.parse('$_baseUrl/channels/$logChannelId'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  /// DM 로그 채널 정보를 가져옵니다
  Future<Map<String, dynamic>?> getDmLogChannelInfo() async {
    try {
      Map<String, String> headers = {
        'Authorization': 'Bot $botToken',
      };
      
      http.Response response = await http.get(
        Uri.parse('$_baseUrl/channels/$dmLogChannelId'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  /// DM 로그 채널에 사용자 DM 내용을 기록합니다
  Future<bool> logDmMessage(String username, String userId, String message, {List<String>? attachments}) async {
    try {
      Map<String, String> headers = {
        'Authorization': 'Bot $botToken',
        'Content-Type': 'application/json',
      };
      
      String logMessage = '**DM 수신 로그**\n'
          '👤 사용자: $username (ID: $userId)\n'
          '💬 메시지: $message\n'
          '⏰ 시간: ${DateTime.now().toString().substring(0, 19)}';
      
      if (attachments != null && attachments.isNotEmpty) {
        logMessage += '\n📎 첨부파일: ${attachments.join(', ')}';
      }
      
      Map<String, dynamic> payload = {
        'content': logMessage,
      };
      
      http.Response response = await http.post(
        Uri.parse('$_baseUrl/channels/$dmLogChannelId/messages'),
        headers: headers,
        body: json.encode(payload),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  /// 웹훅을 통해 DM 메시지를 수신합니다 (실제 구현에서는 웹훅 서버가 필요)
  Future<void> setupDmWebhook() async {
    // 실제 구현에서는 웹훅 서버를 구축하여 DM 메시지를 수신해야 합니다
    // 이는 별도의 서버 애플리케이션이 필요하므로, 여기서는 기본 구조만 제공합니다
    print('DM 웹훅 설정이 필요합니다. 별도의 웹훅 서버를 구축하세요.');
  }
}
