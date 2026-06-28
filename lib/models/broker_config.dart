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
}
