import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrop/application/mine/connection_qr_controller.dart';
import 'package:hydrop/application/mine/mine_page_state.dart';
import 'package:hydrop/presentation/widgets/hd_glass_components.dart';
import 'package:hydrop/routes/app_router.gr.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

@RoutePage()
class MinePage extends ConsumerWidget {
  const MinePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(mineOverviewProvider);

    return HdPageScaffold(
      child: Column(
        children: [
          HdGlassHeader(
            title: 'Mine',
            subtitle: 'Device profile, local addresses and diagnostics',
            trailing: IconButton(
              onPressed: () => ref.invalidate(mineOverviewProvider),
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Refresh local info',
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: overview.when(
              data: (state) => _MineOverviewBody(state: state),
              error: (error, stackTrace) => HdGlassPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Unable to load local device information'),
                    const SizedBox(height: 12),
                    Text(error.toString()),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => ref.invalidate(mineOverviewProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              loading: () => const HdGlassPanel(
                child: SizedBox(
                  height: 220,
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          HdGlassDock(
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      context.navigateTo(const ChatRoute());
                    },
                    icon: const Icon(Icons.chat_bubble_outline_rounded),
                    label: const Text('Open chat'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MineOverviewBody extends StatelessWidget {
  const _MineOverviewBody({required this.state});

  final MineOverviewState state;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom + 110;

    return ListView(
      padding: EdgeInsets.only(bottom: bottomPadding),
      children: [
        HdGlassPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Device profile',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              _InfoRow(label: 'Display name', value: state.displayName),
              const SizedBox(height: 12),
              _InfoRow(label: 'Host name', value: state.hostName),
              const SizedBox(height: 12),
              _InfoRow(
                label: 'Device ID',
                value: state.deviceId,
                selectable: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        HdGlassPanel(child: _ConnectionQrPanel(state: state)),
        const SizedBox(height: 14),
        HdGlassPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Local available IP',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    '${state.localAddresses.length} found',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (state.localAddresses.isEmpty)
                Text(
                  'No local network addresses available right now.',
                  style: Theme.of(context).textTheme.bodyMedium,
                )
              else
                ...state.localAddresses.map(
                  (address) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _AddressTile(address: address),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ConnectionQrPanel extends StatelessWidget {
  const _ConnectionQrPanel({required this.state});

  final MineOverviewState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'QR connection',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Show your QR code for nearby devices, or scan a peer QR code to save its LAN addresses for direct connection.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => _showConnectionQrDialog(context, state),
                icon: const Icon(Icons.qr_code_2_rounded),
                label: const Text('My QR'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: () => _scanConnectionQr(context),
                icon: const Icon(Icons.qr_code_scanner_rounded),
                label: const Text('Scan QR'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

Future<void> _showConnectionQrDialog(
  BuildContext context,
  MineOverviewState state,
) {
  final theme = Theme.of(context);

  return showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('My connection QR'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                color: theme.colorScheme.onSurface.withValues(alpha: 0.66),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}

Future<void> _scanConnectionQr(BuildContext context) async {
  final messenger = ScaffoldMessenger.of(context);

  if (!_isConnectionQrScanSupported) {
    messenger.showSnackBar(
      const SnackBar(
        content: Text(
          'QR scanning is supported on Android, iOS, macOS and web. Windows is not supported.',
        ),
      ),
    );
    return;
  }

  final result = await showDialog<ConnectionQrSaveResult>(
    context: context,
    builder: (context) => const _ConnectionQrScannerDialog(),
  );
  if (result == null || !context.mounted) {
    return;
  }

  messenger.showSnackBar(
    SnackBar(
      content: Text(
        'Saved ${result.displayName} with ${result.addressCount} addresses.',
      ),
    ),
  );
}

bool get _isConnectionQrScanSupported {
  if (kIsWeb) {
    return true;
  }

  return switch (defaultTargetPlatform) {
    TargetPlatform.android ||
    TargetPlatform.iOS ||
    TargetPlatform.macOS => true,
    TargetPlatform.fuchsia ||
    TargetPlatform.linux ||
    TargetPlatform.windows => false,
  };
}

class _ConnectionQrScannerDialog extends ConsumerStatefulWidget {
  const _ConnectionQrScannerDialog();

  @override
  ConsumerState<_ConnectionQrScannerDialog> createState() =>
      _ConnectionQrScannerDialogState();
}

class _ConnectionQrScannerDialogState
    extends ConsumerState<_ConnectionQrScannerDialog> {
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

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: HdGlassPanel(
        padding: const EdgeInsets.all(18),
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
                        child: const Center(child: CircularProgressIndicator()),
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
                color: theme.colorScheme.onSurface.withValues(alpha: 0.66),
              ),
            ),
          ],
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.selectable = false,
  });

  final String label;
  final String value;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
      fontWeight: FontWeight.w600,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(height: 6),
        if (selectable)
          SelectableText(value, style: theme.textTheme.bodyLarge)
        else
          Text(value, style: theme.textTheme.bodyLarge),
      ],
    );
  }
}

class _AddressTile extends StatelessWidget {
  const _AddressTile({required this.address});

  final LocalNetworkAddressInfo address;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  address.interfaceName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  address.versionLabel,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SelectableText(address.address, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}
