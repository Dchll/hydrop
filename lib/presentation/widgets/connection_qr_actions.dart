import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrop/application/mine/connection_qr_controller.dart';
import 'package:hydrop/application/mine/mine_page_state.dart';
import 'package:hydrop/core/feedback/transient_feedback.dart';
import 'package:hydrop/gen/l10n/app_localizations.dart';
import 'package:hydrop/presentation/widgets/hd_components.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

Future<void> showConnectionQrDialog(
  BuildContext context,
  MineOverviewState state,
) {
  final theme = Theme.of(context);
  final l10n = AppLocalizations.of(context);
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
          child: HdPanel(
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
                            l10n.myConnectionQr,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded),
                          tooltip: l10n.closeQr,
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
                        padding: const EdgeInsets.all(10),
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
                      l10n.qrAddressSummary(
                        state.displayName,
                        state.localAddresses.length,
                      ),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
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
  if (!ref.read(connectionQrScanSupportedProvider)) {
    await TransientFeedback.show(
      context,
      AppLocalizations.of(context).qrScanningUnsupported,
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

  await TransientFeedback.show(
    context,
    AppLocalizations.of(
      context,
    ).qrSavedDevice(result.displayName, result.addressCount),
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
    final l10n = AppLocalizations.of(context);
    final mediaQuery = MediaQuery.of(context);
    final maxHeight = mediaQuery.size.height * 0.88;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: HdPanel(
          padding: const EdgeInsets.all(10),
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
                          l10n.scanPeerQr,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                        tooltip: l10n.closeScanner,
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
    return AppLocalizations.of(context).unableToSaveQr;
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
