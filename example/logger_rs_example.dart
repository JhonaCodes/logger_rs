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
  String toString() => 'Product(name: $name, price: \$$price, inStock: $inStock)';
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