class SwipeModel {
  final String fromId;
  final String toId;
  final String direction; // "right" or "left"
  final int timestamp;

  SwipeModel({
    required this.fromId,
    required this.toId,
    required this.direction,
    int? timestamp,
  }) : timestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch;

  Map<String, dynamic> toMap() => {
        'fromId': fromId,
        'toId': toId,
        'direction': direction,
        'timestamp': timestamp,
      };
}