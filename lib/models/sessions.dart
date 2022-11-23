class Sessions {
  int playerPoints;
  int velocityScore;
  int controlScore;
  int playerShots;
  int shipDamageByFortress;
  int fortressDestruction;
  int shipDamageByMine;
  int fortressHitByMissile;
  int bonusTaken;
  double fireAverage;
  double foeMineLoadAndPlayerActTimesDiffAverage;
  double friendlyMineLoadAndPlayerActTimesDiffAverage;
  double totalPlayerDistance;
  String assigned_username;
  String? objectId;
  DateTime? created;
  DateTime? updated;

  Sessions({
    required this.playerPoints,
    required this.velocityScore,
    required this.controlScore,
    required this.playerShots,
    required this.shipDamageByFortress,
    required this.fortressDestruction,
    required this.shipDamageByMine,
    required this.fortressHitByMissile,
    required this.bonusTaken,
    required this.fireAverage,
    required this.foeMineLoadAndPlayerActTimesDiffAverage,
    required this.friendlyMineLoadAndPlayerActTimesDiffAverage,
    required this.totalPlayerDistance,
    required this.assigned_username,
    this.objectId,
    this.created,
    this.updated,
  });

  Map<String, Object?> toJson() => {
        'playerPoints': playerPoints,
        'velocityScore': velocityScore,
        'controlScore': controlScore,
        'playerShots': playerShots,
        'shipDamageByFortress': shipDamageByFortress,
        'fortressDestruction': fortressDestruction,
        'shipDamageByMine': shipDamageByMine,
        'fortressHitByMissile': fortressHitByMissile,
        'bonusTaken': bonusTaken,
        'fireAverage': fireAverage,
        'foeMineLoadAndPlayerActTimesDiffAverage': foeMineLoadAndPlayerActTimesDiffAverage,
        'friendlyMineLoadAndPlayerActTimesDiffAverage': friendlyMineLoadAndPlayerActTimesDiffAverage,
        'totalPlayerDistance': totalPlayerDistance,
        'assigned_username': assigned_username,
        'created': created,
        'updated': updated,
        'objectId': objectId,
      };

  static Sessions fromJson(Map<dynamic, dynamic>? json) => Sessions(
        playerPoints: json!['playerPoints'] as int,
        velocityScore: json['velocityScore'] as int,
        controlScore: json['controlScore'] as int,
        playerShots: json['playerShots'] as int,
        shipDamageByFortress: json['shipDamageByFortress'] as int,
        fortressDestruction: json['fortressDestruction'] as int,
        shipDamageByMine: json['shipDamageByMine'] as int,
        fortressHitByMissile: json['fortressHitByMissile'] as int,
        bonusTaken: json['bonusTaken'] as int,
        fireAverage: json['fireAverage'] as double,
        foeMineLoadAndPlayerActTimesDiffAverage: json['foeMineLoadAndPlayerActTimesDiffAverage'] as double, 
        friendlyMineLoadAndPlayerActTimesDiffAverage: json['friendlyMineLoadAndPlayerActTimesDiffAverage'] as double, 
        totalPlayerDistance: json['totalPlayerDistance'] as double, 
        assigned_username: json['assigned_username'] as String,
        objectId: json['objectId'] as String,
        created: json['created'] as DateTime,
        updated: json['updated'] as DateTime,
      );
}
