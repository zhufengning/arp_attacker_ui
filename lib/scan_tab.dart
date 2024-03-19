import 'dart:convert';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';

import 'main.dart';

class ScanTab extends StatefulWidget {
  final String attackerPath, networkInterface;

  const ScanTab(this.attackerPath, this.networkInterface, {super.key});

  @override
  State<ScanTab> createState() => _ScanTabState();
}

class _ScanTabState extends State<ScanTab> {
  String targetNetwork = "10.0.2.0/24";
  bool isStarted = false;
  Process? process;
  TextEditingController outputs = TextEditingController();

  void startOrStop() async {
    if (isStarted) {
      process!.kill();
      process = null;
    } else {
      process = await Process.start(widget.attackerPath,
          ["--scan", targetNetwork, "-i", widget.networkInterface]);
      process!.stdout.transform(Utf8Decoder()).forEach((e) {
        outputs.text += e;
      });
    }
    setState(() {
      isStarted = !isStarted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      content: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          InfoLabel(
            label: "网段",
            child: TextFormBox(
              initialValue: targetNetwork,
              onChanged: (value) {
                targetNetwork = value;
              },
            ),
          ),
          const SizedBox(height: splitSize),
          Button(
            child: Text(isStarted ? "停止" : "开始"),
            onPressed: startOrStop,
          ),
          const SizedBox(height: splitSize),
          TextFormBox(controller: outputs, readOnly: true, maxLines: 20),
        ],
      ),
    );
  }
}
