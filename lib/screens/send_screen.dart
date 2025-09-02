import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/gifticon_provider.dart';

class SendScreen extends StatelessWidget {
  const SendScreen({super.key});

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
                // 상태 카드
                _buildStatusCard(context, provider),
                
                const SizedBox(height: 20),
                
                // 파일 로드 섹션
                _buildFileLoadSection(context, provider),
                
                const SizedBox(height: 20),
                
                // 폴더 선택 섹션
                _buildFolderSection(context, provider),
                
                const SizedBox(height: 20),
                
                // 데이터 미리보기
                if (provider.gifticonData.isNotEmpty)
                  _buildDataPreview(context, provider),
                
                const SizedBox(height: 20),
                
                // 발송 버튼
                _buildSendButton(context, provider),
                
                const SizedBox(height: 20),
                
                // 에러 메시지
                if (provider.errorMessage != null)
                  _buildErrorMessage(context, provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, GifticonProvider provider) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                const Text(
                  '현재 상태',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStatusRow(
              '봇 연결',
              provider.isConnected ? '연결됨' : '연결 안됨',
              provider.isConnected ? Colors.green : Colors.red,
            ),
            _buildStatusRow(
              '기프티콘 데이터',
              '${provider.gifticonData.length}개',
              provider.gifticonData.isNotEmpty ? Colors.green : Colors.grey,
            ),
            _buildStatusRow(
              '이미지 폴더',
              provider.folderStructure.isNotEmpty 
                ? '${provider.folderStructure.length}개 타입' 
                : '선택 안됨',
              provider.folderStructure.isNotEmpty ? Colors.green : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileLoadSection(BuildContext context, GifticonProvider provider) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '기프티콘 데이터 파일',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'CSV 파일을 선택하세요.\n'
              'CSV 형식: 사용자명, 기프티콘타입',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: provider.isLoading ? null : provider.loadGifticonDataFromCSV,
                icon: const Icon(Icons.table_chart),
                label: const Text('CSV 파일 선택'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
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

  Widget _buildFolderSection(BuildContext context, GifticonProvider provider) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '기프티콘 이미지 폴더',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '기프티콘 이미지들이 타입별로 폴더에 정리된 경로를 선택하세요.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: provider.isLoading ? null : provider.selectAndAnalyzeGifticonFolder,
              icon: const Icon(Icons.folder_open),
              label: const Text('폴더 선택'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            if (provider.selectedFolderPath != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '선택된 폴더:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      provider.selectedFolderPath!,
                      style: const TextStyle(fontSize: 12),
                    ),
                    if (provider.folderStructure.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Text(
                        '발견된 타입:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: provider.folderStructure.keys.map((type) {
                          int count = provider.folderStructure[type]!.length;
                          return Chip(
                            label: Text('$type ($count개)'),
                            backgroundColor: Colors.blue[100],
                            labelStyle: const TextStyle(fontSize: 12),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDataPreview(BuildContext context, GifticonProvider provider) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '데이터 미리보기',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                itemCount: provider.gifticonData.length,
                itemBuilder: (context, index) {
                  final data = provider.gifticonData[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue[100],
                      child: Text(
                        data.username.isNotEmpty ? data.username[0].toUpperCase() : '?',
                        style: TextStyle(
                          color: Colors.blue[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(data.username),
                    subtitle: Text(data.gifticonType),
                    trailing: Icon(
                      Icons.card_giftcard,
                      color: Colors.orange,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSendButton(BuildContext context, GifticonProvider provider) {
    bool canSend = provider.isConnected && 
                   provider.gifticonData.isNotEmpty && 
                   provider.folderStructure.isNotEmpty &&
                   !provider.isLoading;

    return ElevatedButton.icon(
      onPressed: canSend ? provider.sendGifticons : null,
      icon: provider.isLoading 
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : const Icon(Icons.send),
      label: Text(
        provider.isLoading ? '발송 중...' : '기프티콘 발송하기',
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: canSend ? Colors.green : Colors.grey,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildErrorMessage(BuildContext context, GifticonProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        border: Border.all(color: Colors.red[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              provider.errorMessage!,
              style: TextStyle(
                color: Colors.red[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
