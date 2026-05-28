import 'package:equatable/equatable.dart';

class PushNotificationModel extends Equatable {
  const PushNotificationModel({
    required this.title,
    required this.body,
    this.data = const {},
    this.imageUrl,
    this.notificationId,
    this.channelId,
  });

  final String title;
  final String body;
  final Map<String, dynamic> data;
  final String? imageUrl;
  final String? notificationId;
  final String? channelId;

  factory PushNotificationModel.fromMap(Map<String, dynamic> map) {
    return PushNotificationModel(
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      data: Map<String, dynamic>.from(map['data'] as Map? ?? {}),
      imageUrl: map['imageUrl'] as String?,
      notificationId: map['notificationId'] as String?,
      channelId: map['channelId'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'body': body,
        'data': data,
        'imageUrl': imageUrl,
        'notificationId': notificationId,
        'channelId': channelId,
      };

  @override
  List<Object?> get props => [
        title,
        body,
        data,
        imageUrl,
        notificationId,
        channelId,
      ];
}
