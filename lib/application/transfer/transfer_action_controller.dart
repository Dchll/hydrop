import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrop/application/transfer/file_transfer_coordinator.dart';

final transferActionControllerProvider = Provider<TransferActionController>((
  ref,
) {
  return TransferActionController(
    fileTransferCoordinator: ref.watch(fileTransferCoordinatorProvider),
  );
});

class TransferActionController {
  const TransferActionController({
    required FileTransferCoordinator fileTransferCoordinator,
  }) : _fileTransferCoordinator = fileTransferCoordinator;

  final FileTransferCoordinator _fileTransferCoordinator;

  Future<void> pauseTransfer(String attachmentId) {
    return _fileTransferCoordinator.pauseTransfer(attachmentId);
  }

  Future<void> cancelTransfer(String attachmentId) {
    return _fileTransferCoordinator.cancelTransfer(attachmentId);
  }
}
