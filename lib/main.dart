import 'package:arp_attacker_ui/attack_tab.dart';
import 'package:arp_attacker_ui/settings_tab.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './messages/generated.dart';
import 'package:fluent_ui/fluent_ui.dart';

import 'scan_tab.dart';

const splitSize = 8.0;

void main() async {
  await initializeRust();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const FluentApp(
      title: 'ARP攻击UI',
      home: Navi1(),
    );
  }
}

class Navi1 extends StatefulWidget {
  const Navi1({super.key});

  @override
  State<Navi1> createState() => _Navi1State();
}

const errorInterface = "Not selected";
const defaultArpAttackerPath =
    "/home/zfn/repos/my/arp-attacker/target/debug/arp-attacker";
const apPref = "arpAttackerPath";

class _Navi1State extends State<Navi1> {
  int topIndex = 0;
  String selectedDevice = errorInterface;
  String arpAttackerPath = defaultArpAttackerPath;
  SharedPreferences? prefs;

  void updateSettings() {
    setState(() {
      selectedDevice = prefs?.getString("selectedDevice") ?? "Not selected";
      arpAttackerPath = prefs?.getString(apPref) ?? defaultArpAttackerPath;
      items[1] = PaneItem(
          icon: const Icon(FontAwesomeIcons.magnifyingGlass),
          title: const Text('扫描'),
          body: ScanTab(arpAttackerPath, selectedDevice));
      items[2] = PaneItem(
        icon: const Icon(FontAwesomeIcons.gun),
        title: const Text('攻击'),
        body: AttackTab(selectedDevice, arpAttackerPath),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      prefs = await SharedPreferences.getInstance();

      setState(() {
        selectedDevice = prefs?.getString("selectedDevice") ?? errorInterface;
        arpAttackerPath = prefs?.getString(apPref) ?? defaultArpAttackerPath;
        items = [
          PaneItem(
            icon: const Icon(FontAwesomeIcons.gear),
            title: const Text('设置'),
            body: SettingsTab(updateSettings),
          ),
          PaneItem(
            icon: const Icon(FontAwesomeIcons.magnifyingGlass),
            title: const Text('扫描'),
            body: ScanTab(arpAttackerPath, selectedDevice),
          ),
          PaneItem(
            icon: const Icon(FontAwesomeIcons.gun),
            title: const Text('攻击'),
            body: AttackTab(selectedDevice, arpAttackerPath),
          ),
        ];
      });
    });
  }

  List<NavigationPaneItem> items = [];
  @override
  Widget build(BuildContext context) {
    return NavigationView(
        appBar: const NavigationAppBar(
          title: Text('网络扫描与ARP攻击'),
          leading: Icon(FontAwesomeIcons.skull),
        ),
        pane: NavigationPane(
          header: const Text('菜单'),
          displayMode: PaneDisplayMode.compact,
          selected: topIndex,
          onChanged: (index) => setState(() => topIndex = index),
          items: items,
        ));
  }
}
