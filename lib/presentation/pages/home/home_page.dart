import 'dart:ui';

import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrop/data/repository/device_repository.dart';

@RoutePage()
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final padding = MediaQuery.paddingOf(context);
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Builder(
              builder: (context) {
                final devices = ref.watch(deviceListProvider);
                return devices.when(
                  data: (deviceItems) {
                    if (deviceItems.isNotEmpty) {
                      return ListView.builder(
                        padding: EdgeInsets.fromLTRB(
                          0,
                          50 + padding.top,
                          0,
                          50 + padding.bottom,
                        ),
                        itemCount: deviceItems.length,
                        itemBuilder: (context, index) {
                          final deviceItem = deviceItems[index];
                          return Container(
                            height: 80,
                            decoration: BoxDecoration(color: Colors.grey),
                            child: Row(
                              children: [
                                Text(deviceItem.displayName),
                                Text(deviceItem.deviceId),
                                Text(deviceItem.connectionStatus.name),
                                Text(deviceItem.id.toString()),
                              ],
                            ),
                          );
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                  error: (error, stackTrace) => Text(error.toString()),
                  loading: () => const CircularProgressIndicator(),
                );
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final uniqueId = DateTime.now().microsecondsSinceEpoch
                          .toString();
                      await ref
                          .read(deviceRepositoryProvider)
                          .saveDiscoveredDevice(
                            displayName: 'test',
                            deviceId: 'test-$uniqueId',
                          );
                    },
                    child: Text("add data"),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: SafeArea(
              child: SizedBox(
                height: 50,
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            border: .all(color: Colors.grey, width: 1),
                            color: Colors.white.withAlpha(128),
                          ),
                          padding: .all(8),
                          child: Text(
                            "Home",
                            style: TextStyle(fontSize: 24, fontWeight: .bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
