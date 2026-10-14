import 'dart:convert';
import 'dart:io';

import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver(
  responseDataCallback: (data) async {
    final output =
        Platform.environment['ZENTOAST_BENCHMARK_OUTPUT'] ??
        '../benchmark/results/local.json';
    await File(output).writeAsString(
      '${const JsonEncoder.withIndent('  ').convert(data?['zentoast'])}\n',
    );
  },
);
