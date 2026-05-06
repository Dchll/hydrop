import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrop/data/local/database.dart';
import 'package:hydrop/data/local/database_providers.dart';

@RoutePage()
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: SafeArea(child: Row(children: [Text("Home")])),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Builder(
              builder: (context) {
                final db = ref.watch(appDataBaseProvider);
                final deviceItems = db.select(db.deviceItems).get();
                return FutureBuilder(
                  future: deviceItems,
                  builder: (context, asyncSnapshot) {
                    if (asyncSnapshot.hasData) {
                      return ListView.builder(
                        itemCount: asyncSnapshot.data?.length ?? 0,
                        itemBuilder: (context, index) {
                          final deviceItem = asyncSnapshot.data?[index];
                          return Container(
                            decoration: BoxDecoration(color: Colors.grey),
                            child: Row(
                              children: [
                                Text(deviceItem?.name ?? ''),
                                Text(deviceItem?.info ?? ''),
                                Text(deviceItem?.id.toString() ?? ''),
                              ],
                            ),
                          );
                        },
                      );
                    }
                    if (asyncSnapshot.hasError) {
                      return Text(asyncSnapshot.error.toString());
                    }
                    return CircularProgressIndicator();
                  },
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
                    onPressed: () {
                      final db = ref.read(appDataBaseProvider);
                      db
                          .into(db.deviceItems)
                          .insert(
                            DeviceItem(name: "test", info: "test", id: 0),
                          );
                    },
                    child: Text("add data"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
