import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/gifticon_provider.dart';
import 'settings_screen.dart';
import 'send_screen.dart';
import 'history_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const SendScreen(),
    const HistoryScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '기프티콘 발송기',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF5865F2), // Discord 색상
        elevation: 0,
        centerTitle: true,
        actions: [
          Consumer<GifticonProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: Icon(
                  provider.isConnected ? Icons.check_circle : Icons.error,
                  color: provider.isConnected ? Colors.green : Colors.red,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        provider.isConnected 
                          ? '디스코드 봇 연결됨' 
                          : '디스코드 봇 연결 필요',
                      ),
                      backgroundColor: provider.isConnected 
                        ? Colors.green 
                        : Colors.red,
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF5865F2),
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.send),
              label: '발송',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: '발송내역',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: '설정',
            ),
          ],
        ),
      ),
    );
  }
}
