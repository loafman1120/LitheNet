part of 'proxy_repository.dart';

extension _SingboxApiBindings on SingboxProxyRepository {
  void _startApiClient() {
    _stopApiClient();
    final client = SingboxApiClient(endpoint: _apiEndpoint);
    _apiClient = client;
    _statusSubscription = client.subscribeStatus().listen(
          _handleApiStatus,
          onError: _handleApiError,
        );
    _connectionsSubscription = client.subscribeConnections().listen(
          _handleConnectionEvents,
          onError: _handleApiError,
        );
    _groupsSubscription = client.subscribeGroups().listen(
      (groups) {
        _apiGroups = groups;
        _notifyRepositoryListeners();
      },
      onError: _handleApiError,
    );
    _outboundsSubscription = client.subscribeOutbounds().listen(
      (outbounds) {
        _apiOutbounds = outbounds;
        _notifyRepositoryListeners();
      },
      onError: _handleApiError,
    );
  }

  void _restartApiClient() {
    if (!running) {
      return;
    }
    _startApiClient();
  }

  void _stopApiClient() {
    _statusSubscription?.cancel();
    _statusSubscription = null;
    _connectionsSubscription?.cancel();
    _connectionsSubscription = null;
    _groupsSubscription?.cancel();
    _groupsSubscription = null;
    _outboundsSubscription?.cancel();
    _outboundsSubscription = null;
    _apiClient?.close();
    _apiClient = null;
    _stopMockTraffic();
  }

  void _handleApiStatus(SingboxApiStatus status) {
    _stopMockTraffic();
    _traffic = TrafficSnapshot(
      uploadBytes: status.uplinkTotal,
      downloadBytes: status.downlinkTotal,
      activeConnections: status.connectionsIn + status.connectionsOut,
    );
    _notifyRepositoryListeners();
  }

  void _handleConnectionEvents(Object event) {
    if (event is! SingboxApiConnectionEvents) {
      return;
    }
    if (event.reset) {
      _connections.clear();
    }
    for (final connectionEvent in event.events) {
      final connection = connectionEvent.connection;
      if (connectionEvent.type == 2) {
        _connections.remove(connectionEvent.id);
      } else if (connection != null) {
        _connections[connection.id] = connection;
      }
    }
    _notifyRepositoryListeners();
  }

  void _handleApiError(Object error) {
    _appendLog(LogLevel.warning, 'api', error.toString());
    if (_traffic == TrafficSnapshot.zero && _trafficTimer == null) {
      _startMockTraffic();
    }
    _notifyRepositoryListeners();
  }

  void _startMockTraffic() {
    _trafficTimer?.cancel();
    _trafficTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _traffic = _traffic.copyWith(
        uploadBytes: _traffic.uploadBytes + 48 * 1024,
        downloadBytes: _traffic.downloadBytes + 192 * 1024,
        activeConnections: 4,
      );
      _notifyRepositoryListeners();
    });
  }

  void _stopMockTraffic() {
    _trafficTimer?.cancel();
    _trafficTimer = null;
    _traffic = _traffic.copyWith(activeConnections: 0);
  }
}
