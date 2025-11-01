class MessageModel {
  final String id;
  final String senderId;
  final String text;
  final String? mediaUrl;
  final int timestamp;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    this.mediaUrl,
    int? timestamp,
  }) : timestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch;

  Map<String, dynamic> toMap() => {
        'senderId': senderId,
        'text': text,
        'mediaUrl': mediaUrl,
        'timestamp': timestamp,
      };
}