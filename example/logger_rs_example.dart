import 'dart:async';

import 'package:logger_rs/logger_rs.dart';

void main() {
  // Basic logging examples
  basicLogging();

  // Object logging
  objectLogging();

  // Error handling
  errorHandling();

  // Async error handling
  asyncErrorHandling();

  // Performance demonstration
  performanceDemo();

  // Real-world example
  realWorldExample();

  // Tag logging for AI analysis (NEW!)
  tagLoggingDemo();
}

void basicLogging() {
  print('\n==== Basic Logging Examples ====\n');

  // Trace - Most verbose, for detailed debugging
  Log.t('Entering main function');

  // Debug - Development information
  Log.d('Initializing application components');

  // Info - General information
  Log.i('Application started successfully');

  // Warning - Potentially harmful situations
  Log.w('Configuration file not found, using defaults');

  // Error - Error events
  Log.e('Failed to connect to database');

  // Critical/Fatal - System failures
  Log.f('Critical: Out of memory');
}

void objectLogging() {
  print('\n==== Object Logging Examples ====\n');

  // Logging maps
  final user = {
    'id': 123,
    'name': 'John Doe',
    'email': 'john@example.com',
    'roles': ['admin', 'user']
  };
  Log.i(user);

  // Logging lists
  final items = ['apple', 'banana', 'orange', 42, true];
  Log.d(items);

  // Logging custom objects
  final product = Product('Laptop', 999.99, inStock: true);
  Log.i(product);
}

void errorHandling() {
  print('\n==== Error Handling Examples ====\n');

  try {
    // Simulate an error
    throw FormatException('Invalid JSON format');
  } catch (e, stackTrace) {
    Log.e('Failed to parse JSON', error: e, stackTrace: stackTrace);
  }

  try {
    // Another error example
    // This will throw an IntegerDivisionByZeroException
    10 ~/ 0; // Division by zero
  } catch (e) {
    Log.e('Mathematical operation failed', error: e);
  }
}

void asyncErrorHandling() async {
  print('\n==== Async Error Handling ====\n');

  try {
    await fetchDataFromServer();
  } catch (e, stackTrace) {
    Log.e('Network request failed', error: e, stackTrace: stackTrace);
  }
}

Future<void> fetchDataFromServer() async {
  Log.d('Starting network request...');

  // Simulate network delay
  await Future.delayed(Duration(milliseconds: 100));

  // Simulate network error
  throw Exception('Connection timeout');
}

void performanceDemo() {
  print('\n==== Performance Demo ====\n');

  final stopwatch = Stopwatch()..start();

  // Log 50 messages rapidly
  for (int i = 0; i < 50; i++) {
    Log.d('Performance test message #$i');
  }

  stopwatch.stop();
  Log.i('Logged 50 messages in ${stopwatch.elapsedMilliseconds}ms');
}

void realWorldExample() {
  print('\n==== Real World Example ====\n');

  // Simulating a typical application flow
  final app = Application();
  app.initialize();
  app.processRequest();
  app.shutdown();
}

// Sample classes for demonstration
class Product {
  final String name;
  final double price;
  final bool inStock;

  Product(this.name, this.price, {required this.inStock});

  @override
  String toString() =>
      'Product(name: $name, price: \$$price, inStock: $inStock)';
}

class Application {
  void initialize() {
    Log.i('Initializing application...');
    Log.d('Loading configuration');
    Log.d('Connecting to database');
    Log.i('Application initialized successfully');
  }

  void processRequest() {
    Log.t('Processing incoming request');

    try {
      // Simulate processing
      Log.d('Validating request data');
      Log.d('Executing business logic');

      // Simulate a warning condition
      Log.w('Response time exceeded threshold');

      Log.i('Request processed successfully');
    } catch (e) {
      Log.e('Request processing failed', error: e);
    }
  }

  void shutdown() {
    Log.i('Shutting down application...');
    Log.d('Closing database connections');
    Log.d('Cleaning up resources');
    Log.i('Application shut down gracefully');
  }
}

// ============================================================================
// TAG LOGGING DEMO - Export logs for AI analysis
// ============================================================================

void tagLoggingDemo() {
  print('\n==== Tag Logging for AI Analysis ====\n');
  print('Tags allow you to group logs across layers and export them for AI analysis.\n');

  // Demo 1: Authentication flow with error
  print('▸ Demo 1: Auth flow with error (will export)\n');
  simulateAuthFlow();

  // Demo 2: Successful flow (conditional export)
  print('\n▸ Demo 2: Checkout flow without errors (conditional export)\n');
  simulateSuccessFlow();

  // Demo 3: Multi-layer tracking
  print('\n▸ Demo 3: Order processing across layers\n');
  simulateOrderProcessing();

  print('\n════════════════════════════════════════════════════════════════');
  print('✅ Copy the Markdown between separators and paste into Claude!');
  print('════════════════════════════════════════════════════════════════\n');
}

/// Demo 1: Authentication flow with error - shows auto stack trace
void simulateAuthFlow() {
  // UI Layer
  Log.tag('auth', 'User pressed login button');
  Log.tag('auth', {'screen': 'LoginPage', 'action': 'submit'});

  // Controller Layer
  Log.tag('auth', 'Starting authentication process', level: Level.INFO);

  // Service Layer
  Log.tag('auth', 'Validating credentials');
  Log.tag('auth', {'email': 'user@example.com', 'hasPassword': true});

  // Repository Layer
  Log.tag('auth', 'Executing auth query', level: Level.FINE);

  // Simulate an error - stack trace is captured automatically!
  Log.tag(
    'auth',
    'Authentication failed: Invalid credentials',
    level: Level.SEVERE,
    error: Exception('401 Unauthorized'),
  );

  // Export to console
  Log.export('auth');
}

/// Demo 2: Successful checkout - shows conditional export
void simulateSuccessFlow() {
  Log.tag('checkout', 'User started checkout');
  Log.tag('checkout', {'cartId': 'cart_123', 'items': 3});
  Log.tag('checkout', 'Cart validated', level: Level.INFO);
  Log.tag('checkout', 'Payment processed', level: Level.INFO);
  Log.tag('checkout', {'orderId': 'ord_456', 'total': 99.99});
  Log.tag('checkout', 'Order completed successfully', level: Level.INFO);

  // Only export if there were errors (won't export - no errors!)
  Log.export('checkout', onlyOnError: true);

  print('   ✓ Checkout completed - no export needed (no errors)');
}

/// Demo 3: Order processing showing multi-layer tracking
void simulateOrderProcessing() {
  // UI Layer - User action
  Log.tag('order', 'User clicked "Place Order"');
  Log.tag('order', {
    'screen': 'CheckoutPage',
    'userId': 'usr_789',
    'timestamp': DateTime.now().toIso8601String(),
  });

  // Controller Layer - Orchestration
  Log.tag('order', 'OrderController: Processing order', level: Level.INFO);

  // Service Layer - Business logic
  Log.tag('order', 'InventoryService: Checking stock');
  Log.tag('order', {'productId': 'prod_001', 'quantity': 2, 'inStock': true});

  Log.tag('order', 'PaymentService: Processing payment');
  Log.tag('order', {
    'method': 'credit_card',
    'last4': '4242',
    'amount': 149.99,
  });

  // Simulate payment warning
  Log.tag(
    'order',
    'PaymentService: High-value transaction flagged for review',
    level: Level.WARNING,
  );

  // Repository Layer - Data persistence
  Log.tag('order', 'OrderRepository: Saving order to database');
  Log.tag('order', {
    'query': 'INSERT INTO orders (user_id, total, status) VALUES (?, ?, ?)',
    'params': ['usr_789', 149.99, 'pending'],
  });

  // Final status
  Log.tag('order', 'Order created successfully', level: Level.INFO);
  Log.tag('order', {'orderId': 'ord_999', 'status': 'confirmed'});

  // Export - will export because there's a WARNING
  Log.export('order', onlyOnError: true);
}
