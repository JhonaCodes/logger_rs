import 'package:logger_rs/logger_rs.dart';

void main() {
  // Simple message
  Log.i('Simple message');

  // Map with nested objects
  Log.d({
    'key': 'value',
    'number': 42,
    'nested': {'a': 1, 'b': 2},
  });

  // List
  Log.i([1, 2, 3, 'four', {'five': 5}]);

  // Warning with complex object
  Log.w({
    'user': 'john',
    'permissions': ['read', 'write'],
    'metadata': {'created': '2024-01-01'},
  });
}
