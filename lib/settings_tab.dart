import 'package:arp_attacker_ui/main.dart';
import 'package:arp_attacker_ui/messages/arp_interface.pb.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsTab extends StatefulWidget {
  final void Function() callback;
  const SettingsTab(this.callback, {super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  List<String> networkDevices = [errorInterface];
  String selectedDevice = errorInterface;
  String targetIp = '';
  String gateway = '';
  bool isStarted = false;
  SharedPreferences? prefs;
  var arpAttackerPathTxt = TextEditingController(text: defaultArpAttackerPath);

  Future<void> initData() async {
    prefs = await SharedPreferences.getInstance();
    var ap = prefs?.getString(apPref) ?? defaultArpAttackerPath;
    InterfaceReq(execPath: ap).sendSignalToRust(null);
    final stream = InterfaceRes.rustSignalStream;
    arpAttackerPathTxt.text = ap;
    stream.first
        .then((a) {
          setState(() {
            networkDevices = a.message.interfaces;
            selectedDevice =
                prefs?.getString("selectedDevice") ?? a.message.interfaces[0];
            widget.callback();
          });
        })
        .timeout(Duration(seconds: 1))
        .catchError((e) {
          showDialog<String>(
            context: context,
            builder: (context) => ContentDialog(
              title: const Text('错误'),
              content: const Text(
                '可能是attacker路径错误',
              ),
              actions: [
                Button(
                  child: const Text('已阅'),
                  onPressed: () {
                    Navigator.pop(context, 'Ok');
                    // Delete file here
                  },
                ),
              ],
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await initData();
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
                    onPressed: () async {
                      await prefs?.setString('selectedDevice', device);
                      setState(() {
                        selectedDevice = device;
                        widget.callback();
                      });
                    },
                  );
                }).toList(),
              )),
          const SizedBox(height: splitSize),
          InfoLabel(
              label: "arp-attacker路径",
              child: TextFormBox(
                  controller: arpAttackerPathTxt,
                  placeholder: "路径",
                  onChanged: (value) {
                    widget.callback();
                  })),
          Button(
              child: const Text("保存"),
              onPressed: () async {
                if (arpAttackerPathTxt.text == "") {
                  arpAttackerPathTxt.text = defaultArpAttackerPath;
                }
                print(arpAttackerPathTxt.text);
                await prefs?.setString(apPref, arpAttackerPathTxt.text);
                await initData();
                widget.callback();
              })
        ],
      ),
    );
  }
}
