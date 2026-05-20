import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrop/application/mine/connection_qr_controller.dart';
import 'package:hydrop/application/mine/mine_page_state.dart';
import 'package:hydrop/presentation/widgets/hd_glass_components.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

Future<void> showConnectionQrDialog(
  BuildContext context,
  MineOverviewState state,
) {
  final theme = Theme.of(context);
  final mediaQuery = MediaQuery.of(context);
  final maxHeight = mediaQuery.size.height * 0.82;

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.28),
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: HdGlassPanel(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxHeight),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'My connection QR',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded),
                          tooltip: 'Close QR',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: QrImageView(
                          data: state.connectionQrPayload,
                          version: QrVersions.auto,
                          size: 240,
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${state.displayName} · ${state.localAddresses.length} addresses',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'The QR contains device ID, TCP port and local network addresses.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.66,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

Future<ConnectionQrSaveResult?> scanConnectionQr(
  BuildContext context,
  WidgetRef ref,
) async {
  final messenger = ScaffoldMessenger.of(context);

  if (!ref.read(connectionQrScanSupportedProvider)) {
    messenger.showSnackBar(
      const SnackBar(
        content: Text(
          'QR scanning is supported on Android, iOS, macOS and web. Windows is not supported.',
        ),
      ),
    );
    return null;
  }

  final result = await showModalBottomSheet<ConnectionQrSaveResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.28),
    builder: (context) => const ConnectionQrScannerDialog(),
  );
  if (result == null || !context.mounted) {
    return result;
  }

  messenger.showSnackBar(
    SnackBar(
      content: Text(
        'Saved ${result.displayName} with ${result.addressCount} addresses.',
      ),
    ),
  );
  return result;
}

class ConnectionQrScannerDialog extends ConsumerStatefulWidget {
  const ConnectionQrScannerDialog({super.key});

  @override
  ConsumerState<ConnectionQrScannerDialog> createState() =>
      _ConnectionQrScannerDialogState();
}

class _ConnectionQrScannerDialogState
    extends ConsumerState<ConnectionQrScannerDialog> {
  late final MobileScannerController _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
  );

  bool _isHandling = false;
  String? _errorMessage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final maxHeight = mediaQuery.size.height * 0.88;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: HdGlassPanel(
          padding: const EdgeInsets.all(18),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Scan peer QR',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                        tooltip: 'Close scanner',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          MobileScanner(
                            controller: _controller,
                            onDetect: _handleDetect,
                          ),
                          const _ScannerFrame(),
                          if (_isHandling)
                            ColoredBox(
                              color: Colors.black.withValues(alpha: 0.38),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    'Point the camera at another Hydrop device QR code.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.66,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleDetect(BarcodeCapture capture) {
    if (_isHandling) {
      return;
    }

    String? rawValue;
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue?.trim();
      if (value != null && value.isNotEmpty) {
        rawValue = value;
        break;
      }
    }

    if (rawValue == null) {
      return;
    }

    unawaited(_saveScannedValue(rawValue));
  }

  Future<void> _saveScannedValue(String rawValue) async {
    setState(() {
      _isHandling = true;
      _errorMessage = null;
    });
    await _controller.stop();

    try {
      final result = await ref
          .read(connectionQrControllerProvider)
          .saveScannedPayload(rawValue);
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(result);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isHandling = false;
        _errorMessage = _formatScanError(error);
      });
      try {
        await _controller.start();
      } catch (_) {
        // Permission or platform camera failures are already surfaced by scanner.
      }
    }
  }

  String _formatScanError(Object error) {
    if (error is FormatException) {
      return error.message;
    }
    if (error is StateError) {
      return error.message;
    }
    return 'Unable to save this QR code.';
  }
}

class _ScannerFrame extends StatelessWidget {
  const _ScannerFrame();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white, width: 3),
          ),
        ),
      ),
    );
  }
}
