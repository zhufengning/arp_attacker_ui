import "dart:convert";
import "dart:io";

import "package:fluent_ui/fluent_ui.dart";
import "package:shared_preferences/shared_preferences.dart";

import "main.dart";

enum FilterType { Tcp, Http, Ftp, Udp, Icmp, Arp, Tcpdump, Bpf }

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
  FilterType filterType = FilterType.Tcp;
  TextEditingController filterController = TextEditingController();
  bool peth = false,
      pip = true,
      ptcp = true,
      pudp = true,
      picmp = true,
      parp = true;
  final defaultTcpdump =
      "tcp port 80 and (((ip[2:2] - ((ip[0]&0xf)<<2)) - ((tcp[12]&0xf0)>>2)) != 0)";
  late String defaultBpf,
      tcpFilter,
      httpFilter,
      ftpFilter,
      udpFilter,
      icmpFilter,
      arpFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      prefs = await SharedPreferences.getInstance();
      defaultBpf = await tcpDumpCompile(defaultTcpdump);
      tcpFilter = await tcpDumpCompile("tcp");
      httpFilter = await tcpDumpCompile("tcp port http");
      ftpFilter = await tcpDumpCompile("port ftp or ftp-data");
      udpFilter = await tcpDumpCompile("udp");
      icmpFilter = await tcpDumpCompile("icmp");
      arpFilter = await tcpDumpCompile("arp");
    });
  }

  static Future<String> tcpDumpCompile(String filter) async {
    var args = ["-ddd", filter];
    var tcpDumpProcess =
        await Process.run("tcpdump", args, stdoutEncoding: utf8);
    return tcpDumpProcess.stdout;
  }

  void startOrStop() async {
    if (isStarted) {
      print("kill process");
      process!.kill(ProcessSignal.sigint);
      process = null;
    } else {
      print("start process");
      String filter = switch (filterType) {
        FilterType.Tcp => tcpFilter,
        FilterType.Http => httpFilter,
        FilterType.Ftp => ftpFilter,
        FilterType.Udp => udpFilter,
        FilterType.Icmp => icmpFilter,
        FilterType.Arp => arpFilter,
        FilterType.Tcpdump => await tcpDumpCompile(filterController.text),
        FilterType.Bpf => filterController.text,
      };
      outputs.clear();
      errors.clear();
      print(" ${widget.selectedDevice}, ${widget.pcapPath}");
      var args = ["-i", widget.selectedDevice, "--filter", filter, "--full"];

      if (peth) {
        args.add("--peth");
      }
      if (pip) {
        args.add("--pip");
      }

      if (parp) {
        args.add("--parp");
      }
      if (picmp) {
        args.add("--picmp");
      }
      if (ptcp) {
        args.add("--ptcp");
      }
      if (pudp) {
        args.add("--pudp");
      }

      process = await Process.start(widget.pcapPath, args);
      process?.stderr.transform(const Utf8Decoder()).forEach((e) {
        errors.text += e;
      });
      process?.stdout.transform(const Utf8Decoder()).forEach((e) {
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
        padding: const EdgeInsets.all(splitSize),
        children: [
          const Text("显示"),
          Row(children: [
            Checkbox(
                checked: peth,
                onChanged: (v) {
                  setState(() {
                    peth = v ?? false;
                  });
                }),
            const SizedBox(width: splitSize),
            const Text("数据链路层"),
            const SizedBox(width: splitSize),
            Checkbox(
                checked: pip,
                onChanged: (v) {
                  setState(() {
                    pip = v ?? false;
                    parp = v ?? false;
                    picmp = v ?? false;
                  });
                }),
            const SizedBox(width: splitSize),
            const Text("网络层"),
            const SizedBox(width: splitSize),
            Checkbox(
                checked: ptcp,
                onChanged: (v) {
                  setState(() {
                    ptcp = v ?? false;
                    pudp = v ?? false;
                  });
                }),
            const SizedBox(width: splitSize),
            const Text("传输层"),
          ]),
          const SizedBox(height: splitSize),
          const Text("过滤器类型"),
          const SizedBox(height: splitSize),
          Row(
            children: [
              RadioButton(
                  checked: filterType == FilterType.Tcp,
                  onChanged: (v) {
                    if (v) {
                      setState(() {
                        filterType = FilterType.Tcp;
                      });
                    }
                  },
                  content: const Text("TCP")),
              const SizedBox(width: splitSize),
              RadioButton(
                  checked: filterType == FilterType.Http,
                  onChanged: (v) {
                    if (v) {
                      setState(() {
                        filterType = FilterType.Http;
                      });
                    }
                  },
                  content: const Text("HTTP")),
              const SizedBox(width: splitSize),
              RadioButton(
                  checked: filterType == FilterType.Ftp,
                  onChanged: (v) {
                    if (v) {
                      setState(() {
                        filterType = FilterType.Ftp;
                      });
                    }
                  },
                  content: const Text("FTP")),
            ],
          ),
          const SizedBox(height: splitSize),
          RadioButton(
              checked: filterType == FilterType.Udp,
              onChanged: (v) {
                if (v) {
                  setState(() {
                    filterType = FilterType.Udp;
                  });
                }
              },
              content: const Text("UDP")),
          const SizedBox(height: splitSize),
          RadioButton(
              checked: filterType == FilterType.Icmp,
              onChanged: (v) {
                if (v) {
                  setState(() {
                    filterType = FilterType.Icmp;
                  });
                }
              },
              content: const Text("ICMP")),
          const SizedBox(height: splitSize),
          RadioButton(
              checked: filterType == FilterType.Arp,
              onChanged: (v) {
                if (v) {
                  setState(() {
                    filterType = FilterType.Arp;
                  });
                }
              },
              content: const Text("ARP")),
          const SizedBox(height: splitSize),
          Row(children: [
            RadioButton(
                checked: filterType == FilterType.Tcpdump,
                onChanged: (v) {
                  if (v) {
                    setState(() {
                      filterType = FilterType.Tcpdump;
                      filterController.text = defaultTcpdump;
                    });
                  }
                },
                content: const Text("tcpdump表达式")),
            const SizedBox(width: splitSize),
            RadioButton(
                checked: filterType == FilterType.Bpf,
                onChanged: (v) {
                  if (v) {
                    setState(() {
                      filterType = FilterType.Bpf;
                      filterController.text = defaultBpf;
                    });
                  }
                },
                content: const Text("BPF字节码")),
          ]),
          const SizedBox(height: splitSize),
          Visibility(
            visible: filterType == FilterType.Tcpdump ||
                filterType == FilterType.Bpf,
            child: InfoLabel(
                label: "过滤器输入",
                child: TextFormBox(
                  maxLines: 10,
                  controller: filterController,
                )),
          ),
          const SizedBox(height: splitSize),
          Button(
            onPressed: startOrStop,
            child: Text(isStarted ? "停止" : "开始"),
          ),
          const SizedBox(height: splitSize),
          InfoLabel(
              label: "输出",
              child: TextFormBox(
                controller: outputs,
                maxLines: 20,
                minLines: 20,
                readOnly: true,
                style: const TextStyle(fontFamily: "monospace"),
              )),
          const SizedBox(height: splitSize),
          InfoLabel(
              label: "错误",
              child: TextFormBox(
                controller: errors,
                maxLines: 10,
                minLines: 10,
                readOnly: true,
                style: const TextStyle(fontFamily: "monospace"),
              )),
          const SizedBox(height: splitSize),
        ],
      ),
    );
  }
}
