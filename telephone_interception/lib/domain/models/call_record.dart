import 'call_category.dart';
import 'call_action.dart';

class CallRecord {
  const CallRecord({
    required this.number,
    required this.category,
    required this.action,
    required this.reason,
    required this.timestamp,
  });

  final String number;
  final CallCategory category;
  final CallAction action;
  final String reason;
  final DateTime timestamp;

  bool get blocked => action == CallAction.block;
  bool get silenced => action == CallAction.silence;
}
