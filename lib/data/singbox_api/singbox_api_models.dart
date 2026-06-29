import 'package:flutter/foundation.dart';

@immutable
class SingboxApiEndpoint {
  const SingboxApiEndpoint({
    this.host = '127.0.0.1',
    this.port = 0,
    this.secret = '',
    this.dashboardEnabled = false,
  });

  final String host;
  final int port;
  final String secret;
  final bool dashboardEnabled;

  Uri get uri => Uri(scheme: 'http', host: host, port: port);
}

@immutable
class SingboxApiStatus {
  const SingboxApiStatus({
    required this.memory,
    required this.goroutines,
    required this.connectionsIn,
    required this.connectionsOut,
    required this.trafficAvailable,
    required this.uplink,
    required this.downlink,
    required this.uplinkTotal,
    required this.downlinkTotal,
  });

  final int memory;
  final int goroutines;
  final int connectionsIn;
  final int connectionsOut;
  final bool trafficAvailable;
  final int uplink;
  final int downlink;
  final int uplinkTotal;
  final int downlinkTotal;
}

@immutable
class SingboxApiGroup {
  const SingboxApiGroup({
    required this.tag,
    required this.type,
    required this.selectable,
    required this.selected,
    required this.isExpand,
    required this.items,
  });

  final String tag;
  final String type;
  final bool selectable;
  final String selected;
  final bool isExpand;
  final List<SingboxApiGroupItem> items;
}

@immutable
class SingboxApiGroupItem {
  const SingboxApiGroupItem({
    required this.tag,
    required this.type,
    required this.urlTestTime,
    required this.urlTestDelay,
  });

  final String tag;
  final String type;
  final int urlTestTime;
  final int urlTestDelay;
}

@immutable
class SingboxApiConnectionEvent {
  const SingboxApiConnectionEvent({
    required this.type,
    required this.id,
    required this.connection,
    required this.uplinkDelta,
    required this.downlinkDelta,
    required this.closedAt,
  });

  final int type;
  final String id;
  final SingboxApiConnection? connection;
  final int uplinkDelta;
  final int downlinkDelta;
  final int closedAt;
}

@immutable
class SingboxApiConnectionEvents {
  const SingboxApiConnectionEvents({
    required this.events,
    required this.reset,
  });

  final List<SingboxApiConnectionEvent> events;
  final bool reset;
}

@immutable
class SingboxApiConnection {
  const SingboxApiConnection({
    required this.id,
    required this.inbound,
    required this.inboundType,
    required this.network,
    required this.source,
    required this.destination,
    required this.domain,
    required this.protocol,
    required this.fromOutbound,
    required this.createdAt,
    required this.closedAt,
    required this.uplink,
    required this.downlink,
    required this.uplinkTotal,
    required this.downlinkTotal,
    required this.rule,
    required this.outbound,
    required this.outboundType,
    required this.chainList,
  });

  final String id;
  final String inbound;
  final String inboundType;
  final String network;
  final String source;
  final String destination;
  final String domain;
  final String protocol;
  final String fromOutbound;
  final int createdAt;
  final int closedAt;
  final int uplink;
  final int downlink;
  final int uplinkTotal;
  final int downlinkTotal;
  final String rule;
  final String outbound;
  final String outboundType;
  final List<String> chainList;
}
