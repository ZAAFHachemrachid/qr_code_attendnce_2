import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_code_attendnce_2/feature-student/screens/qr_scan_screen.dart';
import '../test_helpers/test_data.dart';
import '../test_config.dart';
import '../mocks/mock_providers.dart';

// Mock mobile scanner controller
class MockMobileScannerController extends Mock
    implements MobileScannerController {
  void Function(BarcodeCapture)? _onDetect;

  @override
  set onDetect(void Function(BarcodeCapture)? value) {
    _onDetect = value;
  }

  void simulateScan(String qrData) {
    if (_onDetect != null) {
      final barcode = Barcode(
        rawValue: qrData,
        format: BarcodeFormat.qrCode,
        displayValue: qrData,
      );
      _onDetect!(BarcodeCapture(barcodes: [barcode], image: null));
    }
  }
}

void main() {
  late ProviderContainer container;
  late MockMobileScannerController mockScannerController;

  setUp(() {
    mockScannerController = MockMobileScannerController();
    container = ProviderContainer(overrides: getTestOverrides());
    setupTestConfig();

    // Mock scanner controller methods
    when(() => mockScannerController.start()).thenAnswer((_) async {
      return null;
    });
    when(() => mockScannerController.stop()).thenAnswer((_) async {});
    when(() => mockScannerController.dispose()).thenAnswer((_) => {});
    when(
      () => mockScannerController.toggleTorch(),
    ).thenAnswer((_) async => true);
  });

  testWidgets('shows camera preview and scanning overlay', (tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: QRScanScreen()),
      ),
    );

    expect(find.byType(MobileScanner), findsOneWidget);
    expect(
      find.text(
        'Position the QR code within the frame to mark your attendance',
      ),
      findsOneWidget,
    );
  });

  testWidgets('handles valid QR code scan', (tester) async {
    container.mockSignIn(success: true);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: QRScanScreen()),
      ),
    );

    // Simulate valid QR code scan
    mockScannerController.simulateScan(TestData.validQrCode);
    await tester.pumpAndSettle();

    // Verify success message
    expect(find.text('Attendance marked successfully'), findsOneWidget);
  });

  testWidgets('handles expired QR code', (tester) async {
    container.mockSignIn(
      success: false,
      errorMessage: TestData.expiredQrCodeError,
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: QRScanScreen()),
      ),
    );

    // Simulate expired QR code scan
    mockScannerController.simulateScan(TestData.expiredQrCode);
    await tester.pumpAndSettle();

    // Verify error message
    expect(find.text('Error: ${TestData.expiredQrCodeError}'), findsOneWidget);
  });

  testWidgets('handles already marked attendance', (tester) async {
    container.mockSignIn(
      success: false,
      errorMessage: TestData.alreadyMarkedError,
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: QRScanScreen()),
      ),
    );

    // Simulate QR code scan for already marked attendance
    mockScannerController.simulateScan(TestData.validQrCode);
    await tester.pumpAndSettle();

    // Verify error message
    expect(find.text('Error: ${TestData.alreadyMarkedError}'), findsOneWidget);
  });

  testWidgets('handles invalid QR code', (tester) async {
    container.mockSignIn(
      success: false,
      errorMessage: TestData.invalidQrCodeError,
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: QRScanScreen()),
      ),
    );

    // Simulate invalid QR code scan
    mockScannerController.simulateScan(TestData.invalidQrCode);
    await tester.pumpAndSettle();

    // Verify error message
    expect(find.text('Error: ${TestData.invalidQrCodeError}'), findsOneWidget);
  });

  testWidgets('allows toggling flash', (tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: QRScanScreen()),
      ),
    );

    // Find and tap flash button
    await tester.tap(find.byIcon(Icons.flash_on));
    await tester.pumpAndSettle();

    // Verify torch was toggled
    verify(() => mockScannerController.toggleTorch()).called(1);
  });
}
