import 'dart:async';
import 'package:signalr_netcore/signalr_client.dart';
import 'api_client.dart';
import 'app_logger.dart';

/// Singleton that manages the SignalR connection for real-time chat.
/// - onMessage: stream of incoming MessageResponse maps (for chat screen)
/// - onNotification: stream of chatRoomIds (for badge count in shell)
class SignalRService {
  SignalRService._();
  static final SignalRService instance = SignalRService._();

  HubConnection? _connection;

  final _messageCtrl = StreamController<Map<String, dynamic>>.broadcast();
  final _notifCtrl = StreamController<String>.broadcast();
  final _shopStatusCtrl = StreamController<Map<String, dynamic>>.broadcast();

  /// Incoming messages — used by ChatScreen to display new messages instantly
  Stream<Map<String, dynamic>> get onMessage => _messageCtrl.stream;

  /// Incoming notification (chatRoomId) — used by shell to refresh badge count
  Stream<String> get onNotification => _notifCtrl.stream;

  /// Shop status change pushed by admin — used by ShopShell and ShopMyStoreScreen
  Stream<Map<String, dynamic>> get onShopStatusChanged => _shopStatusCtrl.stream;

  bool get isConnected =>
      _connection?.state == HubConnectionState.Connected;

  Future<void> connect() async {
    AppLogger.info('[SignalR] connect called — isConnected=$isConnected state=${_connection?.state}');
    if (isConnected) return;

    final token = await ApiClient.getToken();
    if (token == null) {
      AppLogger.warning('[SignalR] connect aborted — no token');
      return;
    }

    _connection = HubConnectionBuilder()
        .withUrl(
          '${ApiClient.baseUrl}/hubs/chat',
          options: HttpConnectionOptions(
            accessTokenFactory: () async => token,
          ),
        )
        .withAutomaticReconnect()
        .build();

    _connection!.on('ReceiveMessage', (args) {
      if (args == null || args.isEmpty) return;
      final raw = args[0];
      if (raw is Map<String, dynamic>) {
        _messageCtrl.add(raw);
      }
    });

    _connection!.on('NewMessageNotification', (args) {
      if (args == null || args.isEmpty) return;
      _notifCtrl.add(args[0].toString());
    });

    _connection!.on('ShopStatusChanged', (args) {
      if (args == null || args.isEmpty) return;
      final raw = args[0];
      if (raw is Map<String, dynamic>) {
        _shopStatusCtrl.add(raw);
      }
    });

    try {
      await _connection!.start();
      AppLogger.info('[SignalR] connect SUCCESS — state=${_connection!.state}');
    } catch (e) {
      AppLogger.error('[SignalR] connect FAILED', error: e);
    }
  }

  Future<void> joinRoom(String roomId) async {
    if (!isConnected) return;
    try {
      await _connection!.invoke('JoinRoom', args: [roomId]);
    } catch (_) {}
  }

  Future<void> leaveRoom(String roomId) async {
    if (!isConnected) return;
    try {
      await _connection!.invoke('LeaveRoom', args: [roomId]);
    } catch (_) {}
  }

  Future<void> disconnect() async {
    await _connection?.stop();
    _connection = null;
  }
}
