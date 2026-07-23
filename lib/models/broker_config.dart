class BrokerConfig {
  final String host;
  final int port;
  final String clientId;
  final int keepAliveSeconds;
  final bool useAuth;
  final String username;
  final String password;

  BrokerConfig({
    required this.host,
    required this.port,
    required this.clientId,
    required this.keepAliveSeconds,
    required this.useAuth,
    this.username = '',
    this.password = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'host': host,
      'port': port,
      'clientId': clientId,
      'keepAliveSeconds': keepAliveSeconds,
      'useAuth': useAuth,
      'username': username,
      'password': password,
    };
  }

  factory BrokerConfig.fromMap(Map<String, dynamic> map) {
    return BrokerConfig(
      host: map['host'] as String? ?? '',
      port: map['port'] as int? ?? 1883,
      clientId: map['clientId'] as String? ?? 'flutter_smart_home',
      keepAliveSeconds: map['keepAliveSeconds'] as int? ?? 60,
      useAuth: map['useAuth'] as bool? ?? false,
      username: map['username'] as String? ?? '',
      password: map['password'] as String? ?? '',
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is BrokerConfig &&
            host == other.host &&
            port == other.port &&
            clientId == other.clientId &&
            keepAliveSeconds == other.keepAliveSeconds &&
            useAuth == other.useAuth &&
            username == other.username &&
            password == other.password;
  }

  @override
  int get hashCode => Object.hash(
        host,
        port,
        clientId,
        keepAliveSeconds,
        useAuth,
        username,
        password,
      );
}
