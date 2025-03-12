class BlockedApp {
  final String packageName;
  final String appName;
  final bool isBlocked;

  BlockedApp({
    required this.packageName,
    required this.appName,
    this.isBlocked = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'packageName': packageName,
      'appName': appName,
      'isBlocked': isBlocked ? 1 : 0,
    };
  }

  factory BlockedApp.fromMap(Map<String, dynamic> map) {
    return BlockedApp(
      packageName: map['packageName'],
      appName: map['appName'],
      isBlocked: map['isBlocked'] == 1,
    );
  }
} 