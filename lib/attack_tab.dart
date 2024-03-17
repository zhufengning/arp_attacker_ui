import 'package:arp_attacker_ui/messages/arp_interface.pb.dart';
import 'package:fluent_ui/fluent_ui.dart';

class AttackTab extends StatefulWidget {
  const AttackTab({super.key});

  @override
  State<AttackTab> createState() => _AttackTabState();
}

const splitSize = 8.0;

class _AttackTabState extends State<AttackTab> {
  List<String> networkDevices = ["eth0"];
  String selectedDevice = "eth0";
  String targetIp = '';
  String gateway = '';
  bool isStarted = false;

  @override
  void initState() {
    super.initState();
    InterfaceReq().sendSignalToRust(null);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final stream = InterfaceRes.rustSignalStream;
      var a = await stream.first;
      setState(() {
        networkDevices = a.message.interfaces;
        selectedDevice = networkDevices.first;
      });
    });
  }

  void startOrStop() {
    setState(() {
          isStarted = !isStarted;
          //print("isStarted: $isStarted");
          // if (isStarted) {
          //   AttackReq().sendSignalToRust(AttackReqData()
          //     ..interface = selectedDevice
          //     ..targetIp = targetIp
          //     ..gateway = gateway);
          // } else {
          //   AttackReq().sendSignalToRust(null);
          // }
        });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      content: ListView(
        padding: const EdgeInsets.all(splitSize),
        children: [
          InfoLabel(
              label: '选择网络接口',
              child: DropDownButton(
                title: Text(selectedDevice),
                items: networkDevices.map((device) {
                  return MenuFlyoutItem(
                    text: Text(device),
                    onPressed: () {
                      setState(() {
                        selectedDevice = device;
                      });
                    },
                  );
                }).toList(),
              )),
          const SizedBox(height: splitSize),
          TextBox(
            onChanged: (value) {
              setState(() {
                targetIp = value;
              });
            },
            placeholder: "目标IP",
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
          !isStarted
              ? FilledButton(onPressed: startOrStop, child: const Text("开始"))
              : Button(onPressed: startOrStop, child: const Text("停止"))
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
