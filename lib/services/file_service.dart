import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import '../models/gifticon_data.dart';

class FileService {
  static const String _sentGifticonsFile = 'sent_gifticons.json';
  
  /// CSV 파일에서 기프티콘 데이터를 읽어옵니다
  static Future<List<GifticonData>> readGifticonDataFromCSV() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        File file = File(result.files.first.path!);
        String content = await file.readAsString();
        return _parseCSVContent(content);
      }
      return [];
    } catch (e) {
      throw Exception('CSV 파일 읽기 실패: $e');
    }
  }

  /// JSON 파일에서 기프티콘 데이터를 읽어옵니다
  static Future<List<GifticonData>> readGifticonDataFromJSON() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        File file = File(result.files.first.path!);
        String content = await file.readAsString();
        List<dynamic> jsonList = json.decode(content);
        return jsonList.map((json) => GifticonData.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('JSON 파일 읽기 실패: $e');
    }
  }

  /// CSV 내용을 파싱합니다
  static List<GifticonData> _parseCSVContent(String content) {
    List<GifticonData> gifticons = [];
    List<String> lines = content.split('\n');
    
    if (lines.isEmpty) return gifticons;
    
    // 헤더 라인 제거 (첫 번째 라인)
    List<String> dataLines = lines.skip(1).where((line) => line.trim().isNotEmpty).toList();
    
    for (String line in dataLines) {
      List<String> fields = _parseCSVLine(line);
      if (fields.length >= 2) {
        gifticons.add(GifticonData(
          username: fields[0].trim(),
          gifticonType: fields[1].trim(),
        ));
      }
    }
    
    return gifticons;
  }

  /// CSV 라인을 파싱합니다 (쉼표로 구분, 따옴표 처리)
  static List<String> _parseCSVLine(String line) {
    List<String> fields = [];
    String currentField = '';
    bool inQuotes = false;
    
    for (int i = 0; i < line.length; i++) {
      String char = line[i];
      
      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        fields.add(currentField);
        currentField = '';
      } else {
        currentField += char;
      }
    }
    
    fields.add(currentField);
    return fields;
  }

  /// 기프티콘 이미지 폴더를 선택합니다
  static Future<String?> selectGifticonFolder() async {
    try {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      return selectedDirectory;
    } catch (e) {
      throw Exception('폴더 선택 실패: $e');
    }
  }

  /// 기프티콘 이미지 폴더의 구조를 분석합니다
  static Future<Map<String, List<String>>> analyzeGifticonFolder(String folderPath) async {
    Map<String, List<String>> folderStructure = {};
    
    try {
      Directory directory = Directory(folderPath);
      if (!await directory.exists()) {
        throw Exception('폴더가 존재하지 않습니다: $folderPath');
      }

      List<FileSystemEntity> entities = directory.listSync();
      
      for (FileSystemEntity entity in entities) {
        if (entity is Directory) {
          String folderName = entity.path.split(Platform.pathSeparator).last;
          List<String> imageFiles = [];
          
          List<FileSystemEntity> files = entity.listSync();
          for (FileSystemEntity file in files) {
            if (file is File) {
              String extension = file.path.split('.').last.toLowerCase();
              if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) {
                imageFiles.add(file.path);
              }
            }
          }
          
          if (imageFiles.isNotEmpty) {
            folderStructure[folderName] = imageFiles;
          }
        }
      }
      
      return folderStructure;
    } catch (e) {
      throw Exception('폴더 분석 실패: $e');
    }
  }

  /// 발송된 기프티콘 기록을 저장합니다
  static Future<void> saveSentGifticon(SentGifticon sentGifticon) async {
    try {
      Directory appDir = await getApplicationDocumentsDirectory();
      File sentFile = File('${appDir.path}/$_sentGifticonsFile');
      
      List<SentGifticon> sentGifticons = await getSentGifticons();
      sentGifticons.add(sentGifticon);
      
      List<Map<String, dynamic>> jsonList = 
          sentGifticons.map((g) => g.toJson()).toList();
      
      await sentFile.writeAsString(json.encode(jsonList));
    } catch (e) {
      throw Exception('발송 기록 저장 실패: $e');
    }
  }

  /// 발송된 기프티콘 기록을 읽어옵니다
  static Future<List<SentGifticon>> getSentGifticons() async {
    try {
      Directory appDir = await getApplicationDocumentsDirectory();
      File sentFile = File('${appDir.path}/$_sentGifticonsFile');
      
      if (!await sentFile.exists()) {
        return [];
      }
      
      String content = await sentFile.readAsString();
      List<dynamic> jsonList = json.decode(content);
      
      return jsonList.map((json) => SentGifticon.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// 기프티콘 이미지를 발송 완료 폴더로 이동합니다
  static Future<String> moveGifticonToSentFolder(
    String originalPath,
    String username,
    String gifticonType,
  ) async {
    try {
      Directory appDir = await getApplicationDocumentsDirectory();
      Directory sentDir = Directory('${appDir.path}/sent_gifticons');
      
      if (!await sentDir.exists()) {
        await sentDir.create(recursive: true);
      }
      
      File originalFile = File(originalPath);
      String extension = originalPath.split('.').last;
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String newFilename = '${username}_${gifticonType}_$timestamp.$extension';
      String newPath = '${sentDir.path}/$newFilename';
      
      await originalFile.copy(newPath);
      
      return newPath;
    } catch (e) {
      throw Exception('파일 이동 실패: $e');
    }
  }

  /// 사용된 기프티콘인지 확인합니다
  static Future<bool> isGifticonUsed(String originalPath) async {
    try {
      List<SentGifticon> sentGifticons = await getSentGifticons();
      return sentGifticons.any((sent) => sent.originalFilename == originalPath);
    } catch (e) {
      return false;
    }
  }
}
