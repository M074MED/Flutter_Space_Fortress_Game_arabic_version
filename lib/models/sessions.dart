class Sessions {
  int pits;
  
  String assigned_username;
  String? objectId;
  DateTime? created;
  DateTime? updated;

  Sessions({
    required this.pits,
    
    required this.assigned_username,
    this.objectId,
    this.created,
    this.updated,
  });

  Map<String, Object?> toJson() => {
        'pits': pits,
        
        'assigned_username': assigned_username,
        'created': created,
        'updated': updated,
        'objectId': objectId,
      };

  static Sessions fromJson(Map<dynamic, dynamic>? json) => Sessions(
        pits: json!['pits'] as int,
        
        assigned_username: json['assigned_username'] as String,
        objectId: json['objectId'] as String,
        created: json['created'] as DateTime,
        updated: json['updated'] as DateTime,
      );
}
