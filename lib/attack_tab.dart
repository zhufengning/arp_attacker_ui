import 'dart:convert';
import 'dart:io';

import 'package:arp_attacker_ui/messages/arp_interface.pb.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';

class AttackTab extends StatefulWidget {
  final String interface, attackerPath;
  const AttackTab(this.interface, this.attackerPath, {super.key});

  @override
  State<AttackTab> createState() => _AttackTabState();
}

class _AttackTabState extends State<AttackTab> {
  String targetIp = '';
  String gateway = '';
  bool isStarted = false;
  SharedPreferences? prefs;
  Process? process;
  TextEditingController outputs = TextEditingController();
  TextEditingController errors = TextEditingController();
  ScrollController outputsScrollController = ScrollController();
  ScrollController errorsScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    InterfaceReq().sendSignalToRust(null);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      prefs = await SharedPreferences.getInstance();
    });
  }

  void startOrStop() async {
    if (isStarted) {
      print("kill process");
      process!.kill();
      process = null;
    } else {
      print("start process");
      outputs.clear();
      errors.clear();
      var args = [
        "-i",
        widget.interface,
      ];
      if (targetIp.isNotEmpty) {
        args.addAll(["-t", targetIp]);
      }
      args.add(gateway);
      process = await Process.start(widget.attackerPath, args);

      process?.stderr.transform(Utf8Decoder()).forEach((e) {
        errors.text += e;
        errorsScrollController
            .jumpTo(errorsScrollController.position.maxScrollExtent - 14);
      });
      process?.stdout.transform(Utf8Decoder()).forEach((e) {
        outputs.text += e;
        outputsScrollController
            .jumpTo(outputsScrollController.position.maxScrollExtent - 14);
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
        padding: const EdgeInsets.all(splitSize),
        children: [
          Text('当前选择的网络接口是: ${widget.interface}'),
          const SizedBox(height: splitSize),
          Text('attacker路径: ${widget.attackerPath}'),
          const SizedBox(height: splitSize),
          TextBox(
            onChanged: (value) {
              setState(() {
                targetIp = value;
              });
            },
            placeholder: "目标IP或Mac或留空",
          ),
          const SizedBox(height: splitSize),
          TextBox(
            onChanged: (value) {
              setState(() {
                gateway = value;
              });
            },
            placeholder: "网关IP",
          ),
          const SizedBox(height: splitSize),
          (!isStarted
              ? FilledButton(onPressed: startOrStop, child: const Text("开始"))
              : Button(onPressed: startOrStop, child: const Text("停止"))),
          const SizedBox(height: splitSize),
          InfoLabel(
              label: "输出",
              child: TextFormBox(
                controller: outputs,
                scrollController: outputsScrollController,
                minLines: 6,
                maxLines: 6,
                style: const TextStyle(fontFamily: "monospace"),
              )),
          InfoLabel(
              label: "错误",
              child: TextFormBox(
                controller: errors,
                minLines: 6,
                maxLines: 6,
                style: const TextStyle(fontFamily: "monospace"),
              )),
        ],
      ),
    );
  }
}

// Map<String, String> optionContent = {
//   'Option 1': 'Content 1',
//   'Option 2': 'Content 2',
//   'Option 3': 'Content 3',
// };

// class Tab2 extends StatefulWidget {
//   @override
//   _Tab2State createState() => _Tab2State();
// }

// class _Tab2State extends State<Tab2> {
//   String selectedOption = optionContent.keys.first;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           // TODO: Implement start/stop functionality
//         },
//         child: Icon(Icons.play_arrow),
//       ),
//       body: ListView(
//         padding: EdgeInsets.all(16.0),
//         children: [
//           Text('Select Option'),
//           DropdownButton<String>(
//             value: selectedOption,
//             onChanged: (value) {
//               setState(() {
//                 selectedOption = value!;
//               });
//             },
//             items: optionContent.keys.map((option) {
//               return DropdownMenuItem<String>(
//                 value: option,
//                 child: Text(option),
//               );
//             }).toList(),
//           ),
//           SizedBox(height: 16.0),
//           Text(optionContent[selectedOption] ?? ''),
//           SizedBox(height: 16.0),
//           TextField(
//             onChanged: (value) {
//               setState(() {
//                 // TODO: Update the content based on the selected option
//               });
//             },
//             decoration: InputDecoration(
//               labelText: 'Input',
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
