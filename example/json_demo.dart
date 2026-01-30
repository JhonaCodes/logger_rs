import 'package:logger_rs/logger_rs.dart';

void main() {
  print('═══════════════════════════════════════════════════════════════');
  print('                    LOGGER RS - JSON DEMO                       ');
  print('═══════════════════════════════════════════════════════════════\n');

  // ══════════════════════════════════════════════════════════════════════
  // BASIC JSON LOGGING
  // ══════════════════════════════════════════════════════════════════════

  print('▸ Basic JSON Logging\n');

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

  // ══════════════════════════════════════════════════════════════════════
  // TAG LOGGING WITH JSON
  // ══════════════════════════════════════════════════════════════════════

  print('\n▸ Tag Logging with JSON (for AI analysis)\n');

  // Simulate an API call flow
  apiCallDemo();

  // Simulate a database operation
  databaseDemo();

  print('\n═══════════════════════════════════════════════════════════════');
  print('                         DEMO COMPLETE                          ');
  print('═══════════════════════════════════════════════════════════════\n');
}

/// Simulates an API call with tagged JSON logs
void apiCallDemo() {
  Log.tag('api', 'Starting API request');

  Log.tag('api', {
    'method': 'POST',
    'url': '/api/v1/users',
    'headers': {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ***',
    },
  });

  Log.tag('api', {
    'body': {
      'name': 'John Doe',
      'email': 'john@example.com',
    },
  });

  // Simulate response
  Log.tag('api', {
    'status': 201,
    'response': {
      'id': 'usr_123',
      'created': true,
    },
  }, level: Level.INFO);

  Log.tag('api', 'API request completed successfully', level: Level.INFO);

  // Export the API flow for analysis
  Log.export('api');
}

/// Simulates a database operation with error
void databaseDemo() {
  Log.tag('db', 'Starting database transaction');

  Log.tag('db', {
    'operation': 'INSERT',
    'table': 'orders',
    'data': {
      'user_id': 'usr_123',
      'items': ['item_1', 'item_2'],
      'total': 99.99,
    },
  });

  // Simulate a constraint violation
  Log.tag('db', {
    'error': 'UNIQUE_VIOLATION',
    'constraint': 'orders_user_id_unique',
    'detail': 'Key (user_id)=(usr_123) already exists',
  }, level: Level.SEVERE);

  Log.tag('db', 'Transaction rolled back', level: Level.WARNING);

  // Export only because there was an error
  Log.export('db', onlyOnError: true);
}
