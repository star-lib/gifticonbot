import 'package:json_annotation/json_annotation.dart';

part 'gifticon_data.g.dart';

@JsonSerializable()
class GifticonData {
  final String username;
  final String gifticonType;

  GifticonData({
    required this.username,
    required this.gifticonType,
  });

  factory GifticonData.fromJson(Map<String, dynamic> json) =>
      _$GifticonDataFromJson(json);

  Map<String, dynamic> toJson() => _$GifticonDataToJson(this);

  @override
  String toString() {
    return 'GifticonData(username: $username, gifticonType: $gifticonType)';
  }
}

@JsonSerializable()
class GifticonConfig {
  final String botToken;
  final String serverId;
  final String logChannelId;
  final String dmLogChannelId;
  final String? customMessage;
  final bool sendAsEmbed;
  final String? embedColor;

  GifticonConfig({
    required this.botToken,
    required this.serverId,
    required this.logChannelId,
    required this.dmLogChannelId,
    this.customMessage,
    this.sendAsEmbed = true,
    this.embedColor,
  });

  factory GifticonConfig.fromJson(Map<String, dynamic> json) =>
      _$GifticonConfigFromJson(json);

  Map<String, dynamic> toJson() => _$GifticonConfigToJson(this);
}

@JsonSerializable()
class SentGifticon {
  final String originalFilename;
  final String username;
  final String gifticonType;
  final DateTime sentAt;
  final String sentFilename;

  SentGifticon({
    required this.originalFilename,
    required this.username,
    required this.gifticonType,
    required this.sentAt,
    required this.sentFilename,
  });

  factory SentGifticon.fromJson(Map<String, dynamic> json) =>
      _$SentGifticonFromJson(json);

  Map<String, dynamic> toJson() => _$SentGifticonToJson(this);
}
