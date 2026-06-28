import 'dart:convert';
import 'dart:typed_data';

import 'singbox_api_models.dart';

class ProtoWriter {
  final BytesBuilder _builder = BytesBuilder(copy: false);

  Uint8List takeBytes() => _builder.takeBytes();

  void stringField(int field, String value) {
    if (value.isEmpty) return;
    _tag(field, 2);
    final bytes = utf8.encode(value);
    _varint(bytes.length);
    _builder.add(bytes);
  }

  void int64Field(int field, int value) {
    if (value == 0) return;
    _tag(field, 0);
    _varint(value);
  }

  void bytesField(int field, Uint8List value) {
    if (value.isEmpty) return;
    _tag(field, 2);
    _varint(value.length);
    _builder.add(value);
  }

  void _tag(int field, int wireType) => _varint((field << 3) | wireType);

  void _varint(int value) {
    var current = value;
    while (current >= 0x80) {
      _builder.addByte((current & 0x7f) | 0x80);
      current >>= 7;
    }
    _builder.addByte(current);
  }
}

class ProtoReader {
  ProtoReader(Uint8List bytes) : _bytes = bytes;

  final Uint8List _bytes;
  int _offset = 0;

  bool get isDone => _offset >= _bytes.length;

  ProtoField next() {
    final tag = _varint();
    return ProtoField(
      number: tag >> 3,
      wireType: tag & 0x7,
      reader: this,
    );
  }

  int readVarint() => _varint();

  bool readBool() => _varint() != 0;

  String readString() => utf8.decode(readBytes());

  Uint8List readBytes() {
    final length = _varint();
    final start = _offset;
    _offset += length;
    return Uint8List.sublistView(_bytes, start, _offset);
  }

  void skip(int wireType) {
    switch (wireType) {
      case 0:
        _varint();
        break;
      case 1:
        _offset += 8;
        break;
      case 2:
        _offset += _varint();
        break;
      case 5:
        _offset += 4;
        break;
      default:
        throw FormatException('Unsupported protobuf wire type: $wireType');
    }
  }

  int _varint() {
    var shift = 0;
    var value = 0;
    while (true) {
      if (_offset >= _bytes.length) {
        throw const FormatException('Unexpected end of protobuf message');
      }
      final byte = _bytes[_offset++];
      value |= (byte & 0x7f) << shift;
      if ((byte & 0x80) == 0) {
        return value;
      }
      shift += 7;
    }
  }
}

class ProtoField {
  const ProtoField({
    required this.number,
    required this.wireType,
    required this.reader,
  });

  final int number;
  final int wireType;
  final ProtoReader reader;
}

Uint8List encodeEmpty() => Uint8List(0);

Uint8List encodeSubscribeStatusRequest(Duration interval) {
  final writer = ProtoWriter()..int64Field(1, interval.inMilliseconds);
  return writer.takeBytes();
}

Uint8List encodeSubscribeConnectionsRequest(Duration interval) {
  final writer = ProtoWriter()..int64Field(1, interval.inMilliseconds);
  return writer.takeBytes();
}

Uint8List encodeUrlTestRequest(String outboundTag) {
  final writer = ProtoWriter()..stringField(1, outboundTag);
  return writer.takeBytes();
}

Uint8List encodeSelectOutboundRequest(String groupTag, String outboundTag) {
  final writer = ProtoWriter()
    ..stringField(1, groupTag)
    ..stringField(2, outboundTag);
  return writer.takeBytes();
}

SingboxApiStatus decodeStatus(Uint8List bytes) {
  final reader = ProtoReader(bytes);
  var memory = 0;
  var goroutines = 0;
  var connectionsIn = 0;
  var connectionsOut = 0;
  var trafficAvailable = false;
  var uplink = 0;
  var downlink = 0;
  var uplinkTotal = 0;
  var downlinkTotal = 0;
  while (!reader.isDone) {
    final field = reader.next();
    switch (field.number) {
      case 1:
        memory = reader.readVarint();
        break;
      case 2:
        goroutines = reader.readVarint();
        break;
      case 3:
        connectionsIn = reader.readVarint();
        break;
      case 4:
        connectionsOut = reader.readVarint();
        break;
      case 5:
        trafficAvailable = reader.readBool();
        break;
      case 6:
        uplink = reader.readVarint();
        break;
      case 7:
        downlink = reader.readVarint();
        break;
      case 8:
        uplinkTotal = reader.readVarint();
        break;
      case 9:
        downlinkTotal = reader.readVarint();
        break;
      default:
        reader.skip(field.wireType);
    }
  }
  return SingboxApiStatus(
    memory: memory,
    goroutines: goroutines,
    connectionsIn: connectionsIn,
    connectionsOut: connectionsOut,
    trafficAvailable: trafficAvailable,
    uplink: uplink,
    downlink: downlink,
    uplinkTotal: uplinkTotal,
    downlinkTotal: downlinkTotal,
  );
}

List<SingboxApiGroup> decodeGroups(Uint8List bytes) {
  final reader = ProtoReader(bytes);
  final groups = <SingboxApiGroup>[];
  while (!reader.isDone) {
    final field = reader.next();
    if (field.number == 1) {
      groups.add(_decodeGroup(reader.readBytes()));
    } else {
      reader.skip(field.wireType);
    }
  }
  return groups;
}

List<SingboxApiGroupItem> decodeOutboundList(Uint8List bytes) {
  final reader = ProtoReader(bytes);
  final outbounds = <SingboxApiGroupItem>[];
  while (!reader.isDone) {
    final field = reader.next();
    if (field.number == 1) {
      outbounds.add(_decodeGroupItem(reader.readBytes()));
    } else {
      reader.skip(field.wireType);
    }
  }
  return outbounds;
}

SingboxApiConnectionEvents decodeConnectionEvents(Uint8List bytes) {
  final reader = ProtoReader(bytes);
  final events = <SingboxApiConnectionEvent>[];
  var reset = false;
  while (!reader.isDone) {
    final field = reader.next();
    switch (field.number) {
      case 1:
        events.add(_decodeConnectionEvent(reader.readBytes()));
        break;
      case 2:
        reset = reader.readBool();
        break;
      default:
        reader.skip(field.wireType);
    }
  }
  return SingboxApiConnectionEvents(events: events, reset: reset);
}

SingboxApiGroup _decodeGroup(Uint8List bytes) {
  final reader = ProtoReader(bytes);
  var tag = '';
  var type = '';
  var selectable = false;
  var selected = '';
  var isExpand = false;
  final items = <SingboxApiGroupItem>[];
  while (!reader.isDone) {
    final field = reader.next();
    switch (field.number) {
      case 1:
        tag = reader.readString();
        break;
      case 2:
        type = reader.readString();
        break;
      case 3:
        selectable = reader.readBool();
        break;
      case 4:
        selected = reader.readString();
        break;
      case 5:
        isExpand = reader.readBool();
        break;
      case 6:
        items.add(_decodeGroupItem(reader.readBytes()));
        break;
      default:
        reader.skip(field.wireType);
    }
  }
  return SingboxApiGroup(
    tag: tag,
    type: type,
    selectable: selectable,
    selected: selected,
    isExpand: isExpand,
    items: items,
  );
}

SingboxApiGroupItem _decodeGroupItem(Uint8List bytes) {
  final reader = ProtoReader(bytes);
  var tag = '';
  var type = '';
  var urlTestTime = 0;
  var urlTestDelay = 0;
  while (!reader.isDone) {
    final field = reader.next();
    switch (field.number) {
      case 1:
        tag = reader.readString();
        break;
      case 2:
        type = reader.readString();
        break;
      case 3:
        urlTestTime = reader.readVarint();
        break;
      case 4:
        urlTestDelay = reader.readVarint();
        break;
      default:
        reader.skip(field.wireType);
    }
  }
  return SingboxApiGroupItem(
    tag: tag,
    type: type,
    urlTestTime: urlTestTime,
    urlTestDelay: urlTestDelay,
  );
}

SingboxApiConnectionEvent _decodeConnectionEvent(Uint8List bytes) {
  final reader = ProtoReader(bytes);
  var type = 0;
  var id = '';
  SingboxApiConnection? connection;
  var uplinkDelta = 0;
  var downlinkDelta = 0;
  var closedAt = 0;
  while (!reader.isDone) {
    final field = reader.next();
    switch (field.number) {
      case 1:
        type = reader.readVarint();
        break;
      case 2:
        id = reader.readString();
        break;
      case 3:
        connection = _decodeConnection(reader.readBytes());
        break;
      case 4:
        uplinkDelta = reader.readVarint();
        break;
      case 5:
        downlinkDelta = reader.readVarint();
        break;
      case 6:
        closedAt = _normalizeUnixSeconds(reader.readVarint());
        break;
      default:
        reader.skip(field.wireType);
    }
  }
  return SingboxApiConnectionEvent(
    type: type,
    id: id,
    connection: connection,
    uplinkDelta: uplinkDelta,
    downlinkDelta: downlinkDelta,
    closedAt: closedAt,
  );
}

SingboxApiConnection _decodeConnection(Uint8List bytes) {
  final reader = ProtoReader(bytes);
  var id = '';
  var inbound = '';
  var inboundType = '';
  var network = '';
  var source = '';
  var destination = '';
  var domain = '';
  var protocol = '';
  var fromOutbound = '';
  var createdAt = 0;
  var closedAt = 0;
  var uplink = 0;
  var downlink = 0;
  var uplinkTotal = 0;
  var downlinkTotal = 0;
  var rule = '';
  var outbound = '';
  var outboundType = '';
  final chainList = <String>[];
  while (!reader.isDone) {
    final field = reader.next();
    switch (field.number) {
      case 1:
        id = reader.readString();
        break;
      case 2:
        inbound = reader.readString();
        break;
      case 3:
        inboundType = reader.readString();
        break;
      case 5:
        network = reader.readString();
        break;
      case 6:
        source = reader.readString();
        break;
      case 7:
        destination = reader.readString();
        break;
      case 8:
        domain = reader.readString();
        break;
      case 9:
        protocol = reader.readString();
        break;
      case 11:
        fromOutbound = reader.readString();
        break;
      case 12:
        createdAt = _normalizeUnixSeconds(reader.readVarint());
        break;
      case 13:
        closedAt = _normalizeUnixSeconds(reader.readVarint());
        break;
      case 14:
        uplink = reader.readVarint();
        break;
      case 15:
        downlink = reader.readVarint();
        break;
      case 16:
        uplinkTotal = reader.readVarint();
        break;
      case 17:
        downlinkTotal = reader.readVarint();
        break;
      case 18:
        rule = reader.readString();
        break;
      case 19:
        outbound = reader.readString();
        break;
      case 20:
        outboundType = reader.readString();
        break;
      case 21:
        chainList.add(reader.readString());
        break;
      default:
        reader.skip(field.wireType);
    }
  }
  return SingboxApiConnection(
    id: id,
    inbound: inbound,
    inboundType: inboundType,
    network: network,
    source: source,
    destination: destination,
    domain: domain,
    protocol: protocol,
    fromOutbound: fromOutbound,
    createdAt: createdAt,
    closedAt: closedAt,
    uplink: uplink,
    downlink: downlink,
    uplinkTotal: uplinkTotal,
    downlinkTotal: downlinkTotal,
    rule: rule,
    outbound: outbound,
    outboundType: outboundType,
    chainList: chainList,
  );
}

int _normalizeUnixSeconds(int timestamp) {
  if (timestamp <= 0) return 0;
  if (timestamp >= 1000000000000000000) {
    return timestamp ~/ 1000000000;
  }
  if (timestamp >= 1000000000000000) {
    return timestamp ~/ 1000000;
  }
  if (timestamp >= 1000000000000) {
    return timestamp ~/ 1000;
  }
  return timestamp;
}
