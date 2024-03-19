import "dart:convert";
import "dart:io";

import "package:fluent_ui/fluent_ui.dart";
import "package:shared_preferences/shared_preferences.dart";

import "main.dart";

class PcapTab extends StatefulWidget {
  final String pcapPath;
  final String selectedDevice;
  const PcapTab(this.pcapPath, this.selectedDevice, {super.key});
  @override
  State<PcapTab> createState() => _PcapTabState();
}

class _PcapTabState extends State<PcapTab> {
  bool isStarted = false;
  Process? process;
  TextEditingController outputs = TextEditingController();
  TextEditingController errors = TextEditingController();
  ScrollController outputsScrollController = ScrollController();
  ScrollController errorsScrollController = ScrollController();
  SharedPreferences? prefs;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      prefs = await SharedPreferences.getInstance();
    });
  }

  void startOrStop() async {
    if (isStarted) {
      print("kill process");
      process!.kill(ProcessSignal.sigint);
      process = null;
    } else {
      print("start process");
      outputs.clear();
      errors.clear();
      print(" ${widget.selectedDevice}, ${widget.pcapPath}");
      var args = ["-i", widget.selectedDevice, "-a"];
      process = await Process.start(widget.pcapPath, args);
      process?.stderr.transform(Utf8Decoder()).forEach((e) {
        errors.text += e;
      });
      process?.stdout.transform(Utf8Decoder()).forEach((e) {
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
        children: [
          Button(
            onPressed: startOrStop,
            child: Text(isStarted ? "停止" : "开始"),
          ),
          TextFormBox(
            controller: outputs,
            maxLines: 10,
            minLines: 20,
            readOnly: true,
          ),
          TextFormBox(
            controller: errors,
            maxLines: 10,
            minLines: 10,
            readOnly: true,
          ),
        ],
      ),
    );
  }
}
