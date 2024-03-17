import 'package:arp_attacker_ui/attack_tab.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import './messages/generated.dart';
import 'package:fluent_ui/fluent_ui.dart';

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

class _Navi1State extends State<Navi1> {
  int topIndex = 0;
  List<NavigationPaneItem> items = [
    PaneItem(
      icon: const Icon(FontAwesomeIcons.gun),
      title: const Text('攻击'),
      body: const AttackTab(),
    )
  ];
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

