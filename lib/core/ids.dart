import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// New random UUID (v4) for records and operations created on this device.
String newId() => _uuid.v4();
