import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/gifticon_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _serverIdController = TextEditingController();
  final TextEditingController _logChannelIdController = TextEditingController();
  final TextEditingController _dmLogChannelIdController = TextEditingController();
  bool _obscureToken = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<GifticonProvider>();
      _tokenController.text = provider.botToken ?? '';
      _serverIdController.text = provider.serverId ?? '';
      _logChannelIdController.text = provider.logChannelId ?? '';
      _dmLogChannelIdController.text = provider.dmLogChannelId ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<GifticonProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildBotTokenSection(context, provider),
                const SizedBox(height: 20),
                _buildInstructionsSection(context),
                const SizedBox(height: 20),
                _buildAppInfoSection(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBotTokenSection(BuildContext context, GifticonProvider provider) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '디스코드 봇 설정',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _tokenController,
              obscureText: _obscureToken,
              decoration: InputDecoration(
                labelText: '봇 토큰',
                hintText: '봇 토큰을 입력하세요',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_obscureToken ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _obscureToken = !_obscureToken;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _serverIdController,
              decoration: const InputDecoration(
                labelText: '서버 ID',
                hintText: '디스코드 서버 ID를 입력하세요',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _logChannelIdController,
              decoration: const InputDecoration(
                labelText: '로그 채널 ID',
                hintText: '로그를 남길 채널 ID를 입력하세요',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _dmLogChannelIdController,
              decoration: const InputDecoration(
                labelText: 'DM 로그 채널 ID',
                hintText: 'DM 내용을 기록할 채널 ID를 입력하세요',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: provider.isLoading ? null : () {
                  provider.setBotConfig(
                    _tokenController.text.trim(),
                    _serverIdController.text.trim(),
                    _logChannelIdController.text.trim(),
                    _dmLogChannelIdController.text.trim(),
                  );
                },
                icon: provider.isLoading 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.link),
                label: const Text('봇 연결 확인'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5865F2),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsSection(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '사용 방법',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInstructionStep('1', '디스코드 봇 생성', 'Discord Developer Portal에서 봇을 생성하고 토큰을 복사하세요'),
            _buildInstructionStep('2', '봇 권한 설정', '봇에게 DM 전송, 서버 멤버 조회, 메시지 전송 권한을 부여하세요'),
            _buildInstructionStep('3', '서버/채널 ID 확인', '서버 ID, 로그 채널 ID, DM 로그 채널 ID를 확인하여 입력하세요'),
            _buildInstructionStep('4', 'CSV 파일 준비', '유저명, 기프티콘타입 두 컬럼으로 CSV 파일을 준비하세요'),
            _buildInstructionStep('5', '이미지 폴더 준비', '기프티콘 이미지를 타입별로 폴더에 정리하세요'),
            _buildInstructionStep('6', '발송 실행', '모든 설정이 완료되면 발송 버튼을 클릭하세요'),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionStep(String number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Color(0xFF5865F2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfoSection(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '앱 정보',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('버전'),
              subtitle: Text('1.0.0'),
            ),
            const ListTile(
              leading: Icon(Icons.developer_mode),
              title: Text('개발자'),
              subtitle: Text('별빛도서관 (Discord star_lib)'),
            ),
            const ListTile(
              leading: Icon(Icons.description),
              title: Text('라이선스'),
              subtitle: Text('개인 사용 제한 라이선스'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _serverIdController.dispose();
    _logChannelIdController.dispose();
    _dmLogChannelIdController.dispose();
    super.dispose();
  }
}
