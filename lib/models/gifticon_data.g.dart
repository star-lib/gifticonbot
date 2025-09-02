// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gifticon_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GifticonData _$GifticonDataFromJson(Map<String, dynamic> json) => GifticonData(
  username: json['username'] as String,
  gifticonType: json['gifticonType'] as String,
);

Map<String, dynamic> _$GifticonDataToJson(GifticonData instance) =>
    <String, dynamic>{
      'username': instance.username,
      'gifticonType': instance.gifticonType,
    };

GifticonConfig _$GifticonConfigFromJson(Map<String, dynamic> json) =>
    GifticonConfig(
      botToken: json['botToken'] as String,
      serverId: json['serverId'] as String,
      logChannelId: json['logChannelId'] as String,
      dmLogChannelId: json['dmLogChannelId'] as String,
      customMessage: json['customMessage'] as String?,
      sendAsEmbed: json['sendAsEmbed'] as bool? ?? true,
      embedColor: json['embedColor'] as String?,
    );

Map<String, dynamic> _$GifticonConfigToJson(GifticonConfig instance) =>
    <String, dynamic>{
      'botToken': instance.botToken,
      'serverId': instance.serverId,
      'logChannelId': instance.logChannelId,
      'dmLogChannelId': instance.dmLogChannelId,
      'customMessage': instance.customMessage,
      'sendAsEmbed': instance.sendAsEmbed,
      'embedColor': instance.embedColor,
    };

SentGifticon _$SentGifticonFromJson(Map<String, dynamic> json) => SentGifticon(
  originalFilename: json['originalFilename'] as String,
  username: json['username'] as String,
  gifticonType: json['gifticonType'] as String,
  sentAt: DateTime.parse(json['sentAt'] as String),
  sentFilename: json['sentFilename'] as String,
);

Map<String, dynamic> _$SentGifticonToJson(SentGifticon instance) =>
    <String, dynamic>{
      'originalFilename': instance.originalFilename,
      'username': instance.username,
      'gifticonType': instance.gifticonType,
      'sentAt': instance.sentAt.toIso8601String(),
      'sentFilename': instance.sentFilename,
    };
