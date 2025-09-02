import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/gifticon_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GifticonProvider>().loadSentGifticons();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<GifticonProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // 헤더
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[200]!),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.history, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Text(
                      '발송 내역',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '총 ${provider.sentGifticons.length}건',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              // 발송 내역 리스트
              Expanded(
                child: provider.sentGifticons.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        itemCount: provider.sentGifticons.length,
                        itemBuilder: (context, index) {
                          final sentGifticon = provider.sentGifticons[index];
                          return _buildHistoryItem(sentGifticon);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '발송 내역이 없습니다',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '기프티콘을 발송하면 여기에 기록됩니다',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(dynamic sentGifticon) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green[100],
          child: Icon(
            Icons.check_circle,
            color: Colors.green[600],
          ),
        ),
        title: Text(
          sentGifticon.username,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('타입: ${sentGifticon.gifticonType}'),
            Text(
              '발송시간: ${_formatDateTime(sentGifticon.sentAt)}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () => _showDetailDialog(sentGifticon),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showDetailDialog(dynamic sentGifticon) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('발송 상세 정보'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('사용자명', sentGifticon.username),
            _buildDetailRow('기프티콘 타입', sentGifticon.gifticonType),
            _buildDetailRow('발송 시간', _formatDateTime(sentGifticon.sentAt)),
            _buildDetailRow('원본 파일', sentGifticon.originalFilename.split('/').last),
            _buildDetailRow('저장 파일', sentGifticon.sentFilename.split('/').last),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
