import 'dart:ui';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'dart:async';
import 'dart:math' as math;
import 'header_widget.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart' as geoloc;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hydrate D',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Hydrate D'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // const _MyHomePageState({super.key, required this.title});
  late List<FinalData> _chartData;

  @override
  void initState() {
    _chartData = getChartData();
    super.initState();
  }

  Widget build(BuildContext context) {
    const double _headerHeight = 75;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Hydration Check"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                height: _headerHeight,
                child: HeaderWidget(_headerHeight, true, Icons.login_rounded),
              ),
              SizedBox(
                height: 150,
                width: 150,
                child: Image.network(
                    'https://img.freepik.com/free-icon/sunset_318-375746.jpg'),
              ),
              // const SizedBox(
              //   height: 25,
              // ),
              SfCircularChart(
                legend: Legend(
                  isVisible: true,
                  position: LegendPosition.bottom,
                ),
                series: <CircularSeries>[
                  DoughnutSeries<FinalData, String>(
                    dataSource: _chartData,
                    pointColorMapper: (FinalData data, _) => data.color,
                    xValueMapper: (FinalData data, _) => data.label,
                    yValueMapper: (FinalData data, _) => data.value,
                    explode: true,
                    explodeAll: true,
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "Body statistics on your fingertips",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 25),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    fixedSize: const Size(250, 70),
                    side: const BorderSide(
                      width: 3,
                      color: Colors.white30,
                    ),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.all(20)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SecondRoute()),
                  );
                },
                child: const Text('Get Started'),
              ),
              const SizedBox(
                height: 30,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 24),
                    backgroundColor: const Color.fromARGB(255, 254, 24, 101),
                    foregroundColor: Colors.white,
                    fixedSize: const Size(250, 70),
                    side: const BorderSide(
                      width: 3,
                      color: Colors.white30,
                    ),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.all(20)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LiveTracking()),
                  );
                },
                child: const Text(' Start Live Tracking'),
              )
            ],
          ),
        ),
      ),
    );
  }

  List<FinalData> getChartData() {
    final List<FinalData> chartData = [
      FinalData('Hydration', 1, const Color.fromARGB(255, 0, 145, 255)),
      FinalData('Sunburn', 1, const Color.fromARGB(255, 255, 149, 0)),
      // FinalData('Vitamin-D', 1, const Color.fromARGB(255, 224, 243, 21)),
      FinalData(
        'Vitamin-D',
        1,
        const Color.fromARGB(255, 254, 24, 101),
      ),
    ];
    return chartData;
  }
}

class FinalData {
  FinalData(this.label, this.value, this.color);
  final String label;
  final int value;
  final Color color;
}

class SecondRoute extends StatefulWidget {
  SecondRoute({super.key});

  @override
  State<SecondRoute> createState() => _SecondRouteState();
}

class _SecondRouteState extends State<SecondRoute> {
  late List<LiveData> _chartData;
  late ChartSeriesController _chartSeriesController;

  void getLast10Data() async {
    await FirebaseDatabase.instance
        .ref("dataset")
        .limitToLast(10)
        .once()
        .then((event) {
      // print(event.snapshot.value);
      if (event.snapshot.value != null) {
        var dict = event.snapshot.value! as Map;
        List<LiveData> tempData = [];
        // print(dict);
        dict.forEach((key, value) {
          // print(value);
          var gsrData = value as Map;
          tempData.add(LiveData(time++, gsrData["gsrValue"]));
        });
        setState(() {
          _chartData = tempData;
          time = time;
        });
      }
    });

    FirebaseDatabase.instance
        .ref("dataset")
        .limitToLast(1)
        .onChildAdded
        .listen((event) {
      var dict = event.snapshot.value! as Map;
      print(dict);
      LiveData data = LiveData(time++, dict["gsrValue"]);
      _chartData.add(data);
      _chartData.removeAt(0);
      _chartSeriesController.updateDataSource(
          addedDataIndex: _chartData.length - 1, removedDataIndex: 0);
    });
  }

  void initState() {
    _chartData = getChartData();
    // Timer.periodic(const Duration(seconds: 1) , updataDataSource);
    super.initState();
    getLast10Data();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Graph'),
        ),
        body: DecoratedBox(
          decoration: const BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.fitHeight,
              invertColors: true,
              image: NetworkImage(
                  "https://whatgives365.files.wordpress.com/2010/10/water-rippling.jpg"),
            ),
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: SfCartesianChart(
                  series: <ChartSeries>[
                    LineSeries<LiveData, int>(
                        onRendererCreated: (ChartSeriesController controller) {
                          _chartSeriesController = controller;
                        },
                        dataSource: _chartData,
                        color: const Color.fromARGB(255, 38, 206, 83),
                        xValueMapper: (LiveData sales, _) => sales.time,
                        yValueMapper: (LiveData sales, _) => sales.speed,
                        width: 4)
                  ],
                  primaryXAxis: NumericAxis(
                      axisLine: const AxisLine(width: 3),
                      edgeLabelPlacement: EdgeLabelPlacement.shift,
                      interval: 1,
                      title: AxisTitle(text: 'Time')),
                  primaryYAxis: NumericAxis(
                    axisLine: const AxisLine(width: 3),
                    majorTickLines: const MajorTickLines(size: 0),
                    edgeLabelPlacement: EdgeLabelPlacement.shift,
                    title: AxisTitle(text: 'GSR Value'),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 22),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red,
                  fixedSize: const Size(312, 80),
                  side: const BorderSide(
                    width: 3,
                    color: Colors.red,
                    // strokeAlign: BorderSide.strokeAlignCenter
                  ),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.all(20)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ThirdRoute()),
                );
              },
              child: const Text(
                'View your body statistics',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            ElevatedButton(
              // style: ElevatedButton.styleFrom(
              //   textStyle: const TextStyle(fontSize: 15),
              // fixedSize: const Size(150, 70)
              // ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Go back!'),
            )
          ]),
        ),
      ),
    );
  }

  int time = 0;
  void updataDataSource(Timer timer) {
    _chartData.add(LiveData(time++, (math.Random().nextInt(60) + 30)));
    _chartData.removeAt(0);
    _chartSeriesController.updateDataSource(
        addedDataIndex: _chartData.length - 1, removedDataIndex: 0);
  }

  List<LiveData> getChartData() {
    return <LiveData>[
      LiveData(0, 220),
      LiveData(1, 220),
      LiveData(2, 220),
      LiveData(3, 220),
      LiveData(4, 220),
      LiveData(5, 220),
      LiveData(6, 220),
      LiveData(7, 220),
      LiveData(8, 220),
      LiveData(9, 220),
      // LiveData(10, 53),
      // LiveData(11, 72),
      // LiveData(12, 86),
      // LiveData(13, 52),
      // LiveData(14, 94),
      // LiveData(15, 92),
      // LiveData(16, 86),
      // LiveData(17, 72),
      // LiveData(18, 215)
    ];
  }
}

class LiveData {
  LiveData(this.time, this.speed);
  final int time;
  final num speed;
}

class ThirdRoute extends StatefulWidget {
  ThirdRoute({super.key});

  @override
  State<ThirdRoute> createState() => _ThirdRouteState();
}

class _ThirdRouteState extends State<ThirdRoute> {
  String stat = "no data";
  String nextStage = "no data";
  int nextStage_int = 10;
  double currUv = 0.0;
  double time_diff = 0.0;
  double vit_d = 0.0;
  int vit_d_int = 0;
  int rTime = -1;

// vit_d = 600 * time_diff / rTime

  void setBurnStatus() {
    double temp_vd = 0;
    if (stat.toLowerCase() == "no dehydration") {
      if (currUv == 0) {
        rTime = -1;
      } else if (currUv <= 2) {
        rTime = 3600;
      } else if (currUv <= 5) {
        rTime = 2700;
      } else if (currUv <= 7) {
        rTime = 1800;
      } else if (currUv <= 10) {
        rTime = 1200;
      } else {
        rTime = 660;
      }
      if (rTime == -1) {
        temp_vd = 0;
      } else {
        temp_vd = 600 * time_diff! / rTime;
      }
      nextStage = "Some Dehydration";
      nextStage_int = 10;
    } else if (stat.toLowerCase() == "some dehydration") {
      if (currUv == 0) {
        rTime = -1;
      } else if (currUv <= 2) {
        rTime = 2700;
      } else if (currUv <= 5) {
        rTime = 2040;
      } else if (currUv <= 7) {
        rTime = 1350;
      } else if (currUv <= 10) {
        rTime = 900;
      } else {
        rTime = 660;
      }
      if (rTime == -1) {
        temp_vd = 0;
      } else {
        temp_vd = 600 * time_diff! / rTime;
      }
      nextStage = "Severe Dehydration";
      nextStage_int = 25;
    } else if (stat.toLowerCase() == "severe dehydration") {
      if (currUv == 0) {
        rTime = -1;
      } else if (currUv <= 2) {
        rTime = 1800;
      } else if (currUv <= 5) {
        rTime = 1350;
      } else if (currUv <= 7) {
        rTime = 900;
      } else if (currUv <= 10) {
        rTime = 750;
      } else {
        rTime = 660;
      }
      if (rTime == -1) {
        temp_vd = 0;
      } else {
        temp_vd = 600 * time_diff! / rTime;
      }
      nextStage = "Compenstated";
      nextStage_int = 50;
    } else if (stat.toLowerCase() == "compenstated") {
      if (currUv == 0) {
        rTime = -1;
      } else if (currUv <= 2) {
        rTime = 1350;
      } else if (currUv <= 5) {
        rTime = 1012;
      } else if (currUv <= 7) {
        rTime = 700;
      } else if (currUv <= 10) {
        rTime = 680;
      } else {
        rTime = 660;
      }
      if (rTime == -1) {
        temp_vd = 0;
      } else {
        temp_vd = 600 * time_diff! / rTime;
      }
      nextStage = "Deompenstated";
      nextStage_int = 75;
    }
    setState(() {
      print(temp_vd);

      vit_d = temp_vd;
      print("vitamin");
      print(vit_d);
      vit_d_int = vit_d.toInt();
    });
  }

  void fetchGsr() async {
    // await Future.delayed(const Duration(seconds: 2));
    try {
      final response = await http
          .get(
            Uri.http(
              "192.168.234.133:5000",
              "getGsrResult",
            ),
          )
          .timeout(const Duration(seconds: 20));
      log("${response.statusCode}");
      Map<String, dynamic> resTemp = json.decode(response.body);
      Map<String, String> temp =
          resTemp.map(((key, value) => MapEntry(key, value.toString())));
      log(temp.toString());

      setState(() {
        // print(temp);
        // _isLoading = false;
        stat = temp["status"]!;
        time_diff = double.parse(temp["delta"]!);
        setBurnStatus();
        // currUv = double.parse(temp["uv"]!);
      });
    } catch (e, stackTrace) {
      print(e);
      print(stackTrace.toString());
      setState(() {
        // _isLoading = false;
        // stat = "Unexpected error";
        // stat = "Dehydrated";
        stat = "Server not responding";
      });
    }
  }

  Future<geoloc.Position> _determinePosition() async {
    bool serviceEnabled;
    geoloc.LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await geoloc.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await geoloc.Geolocator.requestPermission();
    }

    permission = await geoloc.Geolocator.checkPermission();
    if (permission == geoloc.LocationPermission.denied) {
      permission = await geoloc.Geolocator.requestPermission();
      if (permission == geoloc.LocationPermission.denied) {
        permission = await geoloc.Geolocator.requestPermission();
        if (permission == geoloc.LocationPermission.denied) {
          return Future.error('Location permissions are denied');
        } else if (permission == geoloc.LocationPermission.deniedForever) {
          return Future.error("'Location permissions are permanently denied");
        } else {
          // return Future.("GPS Location service is granted");
        }
      }
    }

    if (permission == geoloc.LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await geoloc.Geolocator.getCurrentPosition();
  }

  void fetchUvIndex() async {
    // await Future.delayed(const Duration(seconds: 2));
    try {
      final location = await _determinePosition();
      log("LAT: ${location.latitude}, LONG: ${location.longitude}");
      final response = await http
          .get(
            Uri.http(
              "192.168.234.133:5000",
              "getUVindex",
              {
                "lat": location.latitude.toString(),
                "lng": location.longitude.toString()
              },
            ),
          )
          .timeout(const Duration(seconds: 20));
      log("${response.statusCode}");
      Map<String, dynamic> resTemp = json.decode(response.body);
      Map<String, String> temp =
          resTemp.map(((key, value) => MapEntry(key, value.toString())));
      log(temp.toString());

      setState(() {
        // _isLoading = false;
        // stat = temp["status"]!;
        currUv = double.parse(temp["uv"]!);
        // currUv = double.parse(temp["uv_max"]!);
        setBurnStatus();
      });
    } catch (e, stackTrace) {
      print(e);
      print(stackTrace.toString());
      // setState(() {
      // _isLoading = false;
      // stat = "Unexpected error";
      // stat = "Dehydrated";
      // stat = "Server not responding";
      // });
    }
  }

  @override
  void initState() {
    // log(widget.uname);
    setBurnStatus();
    fetchGsr();
    fetchUvIndex();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const double headerHeight = 75;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Body Statistics'),
        ),
        body: Center(
          child:
              // ignore: prefer_const_literals_to_create_immutables
              Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            const SizedBox(
              height: headerHeight,
              child: HeaderWidget(headerHeight, true, Icons.login_rounded),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "Your Dehydration Status :",
              style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueAccent),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 10,
                shadowColor: Colors.red,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: SizedBox(
                    width: 300,
                    child: StepProgressIndicator(
                      totalSteps: 100,
                      currentStep: nextStage_int, //10,25,50,75,90
                      size: 25,
                      padding: 0,
                      selectedColor: const Color.fromARGB(255, 255, 133, 133),
                      unselectedColor: Colors.grey,
                      roundedEdges: const Radius.circular(10),
                      selectedGradientColor: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color.fromARGB(255, 255, 133, 133),
                          Color.fromARGB(255, 223, 63, 51)
                        ],
                      ),
                      unselectedGradientColor: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.grey, Colors.grey],
                      ),
                    )),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              stat,
              style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueAccent),
            ),
            const SizedBox(
              height: 20,
            ),
            const Divider(
              color: Colors.grey,
              height: 20,
              thickness: 1,
            ),
            const Text(
              "Sunburn Prediction",
              style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(219, 255, 119, 0)),
            ),
            const Divider(
              color: Colors.grey,
              height: 20,
              thickness: 1,
            ),
            Container(
              // height: 230,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          "Curent UV Index: $currUv",
                          style: const TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          ((rTime == -1 || nextStage == "no data")
                              ? "Based on the current UV Index you will not get sun burned."
                              : "Based on the current UV Index and your dehydration status, you are likely to get First Degree sunburn in $rTime seconds (~${(rTime)~/60} minutes)."),
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(
                          height: 20,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              color: Colors.grey,
              height: 10,
              thickness: 1,
            ),
            const Text(
              "Vitamin-D Intake",
              style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(219, 255, 119, 0)),
            ),
            const Divider(
              color: Colors.grey,
              height: 20,
              thickness: 1,
            ),
            SizedBox(
              height: 230,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Text(
                          "Required Amount Per Day :",
                          style: TextStyle(fontSize: 15),
                        ),
                        const Text(
                          "600 IU",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        SizedBox(
                          child: Card(
                            elevation: 5,
                            shadowColor:
                                const Color.fromARGB(255, 254, 24, 101),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100)),
                            child: CircularStepProgressIndicator(
                              totalSteps: 600,
                              currentStep: vit_d_int <= 0 ? 0 : vit_d_int,
                              // stepSize: 10,
                              selectedColor:
                                  const Color.fromARGB(255, 254, 24, 101),
                              unselectedColor: Colors.grey,
                              padding: 0,
                              width: 150,
                              height: 150,
                              selectedStepSize: 15,
                              stepSize: 15,
                              child: Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                    // color: Colors.lightBlueAccent,
                                    borderRadius: BorderRadius.circular(100)),
                                alignment: Alignment.center,
                                child: Text(
                                  "$vit_d_int",
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const VerticalDivider(
                    color: Colors.grey,
                    thickness: 2,
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      // ignore: prefer_const_literals_to_create_immutables
                      children: [
                        const Text(
                          "Permissible Amount Per Day :",
                          style: TextStyle(fontSize: 15),
                        ),
                        const Text(
                          "4000 IU",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        SizedBox(
                          child: Card(
                            elevation: 5,
                            shadowColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100)),
                            child: CircularStepProgressIndicator(
                              totalSteps: 4000,
                              currentStep: vit_d_int <= 0 ? 0 : vit_d_int,
                              // stepSize: 10,
                              selectedColor: Colors.orange,
                              unselectedColor: Colors.grey,
                              padding: 0,
                              width: 150,
                              height: 150,
                              selectedStepSize: 15,
                              stepSize: 15,
                              child: Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                    // color: Colors.lightBlueAccent,
                                    borderRadius: BorderRadius.circular(100)),
                                alignment: Alignment.center,
                                child: Text(
                                  "$vit_d_int",
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              color: Colors.grey,
              height: 10,
              thickness: 1,
            ),
          ]),
        ),
      ),
    );
  }
}

class LiveTracking extends StatefulWidget {
  const LiveTracking({super.key});

  @override
  State<LiveTracking> createState() => _LiveTrackingState();
}

class _LiveTrackingState extends State<LiveTracking> {
  String _buttonText = "Start";
  String _stopwatchText = "00:00:00";
  final _stopWatch = Stopwatch();
  final _timeout = const Duration(seconds: 1);

  late List<LiveData> _chartData;
  late ChartSeriesController _chartSeriesController;

  @override
  void initState() {
    _chartData = getChartData();
    // Timer.periodic(const Duration(seconds: 1) , updataDataSource);
    super.initState();
    getLast10Data();
  }

  void getLast10Data() async {
    await FirebaseDatabase.instance
        .ref("dataset")
        .limitToLast(10)
        .once()
        .then((event) {
      // print(event.snapshot.value);
      if (event.snapshot.value != null) {
        var dict = event.snapshot.value! as Map;
        List<LiveData> tempData = [];
        // print(dict);
        dict.forEach((key, value) {
          // print(value);
          var gsrData = value as Map;
          tempData.add(LiveData(time++, gsrData["gsrValue"]));
        });
        setState(() {
          _chartData = tempData;
          time = time;
        });
      }
    });

    FirebaseDatabase.instance
        .ref("dataset")
        .limitToLast(1)
        .onChildAdded
        .listen((event) {
      var dict = event.snapshot.value! as Map;
      print(dict);
      LiveData data = LiveData(time++, dict["gsrValue"]);
      _chartData.add(data);
      _chartData.removeAt(0);
      _chartSeriesController.updateDataSource(
          addedDataIndex: _chartData.length - 1, removedDataIndex: 0);
    });
  }

  void _startTimeout() {
    /*Timer(_timeout, _handleTimeout);*/
    Timer(_timeout, () {
      if (_stopWatch.isRunning) {
        _startTimeout();
      }
      setState(() {
        _setStopwatchText();
      });
    });
  }

  void _handleTimeoutBak() {
    if (_stopWatch.isRunning) {
      _startTimeout();
    }
    setState(() {
      _setStopwatchText();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Data Tracking"),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    const double headerHeight = 75;
    return SafeArea(
      child: Scaffold(
        // backgroundColor:

        body: DecoratedBox(
          decoration: const BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.fitHeight,
              // invertColors: true,
              image: NetworkImage(
                  "https://whatgives365.files.wordpress.com/2010/10/water-rippling.jpg"),
            ),
          ),
          child:
              // ignore: prefer_const_literals_to_create_immutables
              Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            const SizedBox(
              height: headerHeight,
              child: HeaderWidget(headerHeight, true, Icons.login_rounded),
            ),
            const SizedBox(
              height: 30,
            ),
            Card(
              elevation: 10,
              shadowColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)),
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Text(
                  _stopwatchText,
                  style: const TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 50,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Card(
              // elevation: 10,
              // margin: EdgeInsets.all(10),
              // child: Padding(
              //   padding: EdgeInsets.all(10.0),
              //   child: Text(
              //     "Chart",
              //     style: TextStyle(fontSize: 150),
              //   ),
              // ),
              // TODO: Graph
              child: SfCartesianChart(
                series: <ChartSeries>[
                  LineSeries<LiveData, int>(
                      onRendererCreated: (ChartSeriesController controller) {
                        _chartSeriesController = controller;
                      },
                      dataSource: _chartData,
                      color: const Color.fromARGB(255, 38, 206, 83),
                      xValueMapper: (LiveData sales, _) => sales.time,
                      yValueMapper: (LiveData sales, _) => sales.speed,
                      width: 4)
                ],
                primaryXAxis: NumericAxis(
                    axisLine: const AxisLine(width: 3),
                    edgeLabelPlacement: EdgeLabelPlacement.shift,
                    interval: 1,
                    title: AxisTitle(text: 'Time')),
                primaryYAxis: NumericAxis(
                  axisLine: const AxisLine(width: 3),
                  majorTickLines: const MajorTickLines(size: 0),
                  edgeLabelPlacement: EdgeLabelPlacement.shift,
                  title: AxisTitle(text: 'GSR Value'),
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    textStyle: const TextStyle(fontSize: 30),
                    fixedSize: const Size(130, 60),
                    side: const BorderSide(
                      width: 3,
                      color: Colors.white30,
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: _startStopButtonPressed,
                  child: Text(_buttonText),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    textStyle: const TextStyle(fontSize: 30),
                    fixedSize: const Size(130, 60),
                    side: const BorderSide(
                      width: 3,
                      color: Colors.white30,
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: _resetButtonPressed,
                  child: const Text("Reset"),
                ),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 30),
                  backgroundColor: Colors.white24,
                  foregroundColor: Colors.white,
                  fixedSize: const Size(312, 80),
                  side: const BorderSide(
                    width: 2,
                    color: Colors.white,
                    // strokeAlign: BorderSide.strokeAlignCenter
                  ),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.all(20)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ThirdRoute()),
                );
              },
              child: const Text(
                'View Results',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  void _startStopButtonPressed() {
    setState(() {
      if (_stopWatch.isRunning) {
        _buttonText = "Start";
        _stopWatch.stop();
      } else {
        _buttonText = "Stop";
        _stopWatch.start();
        _startTimeout();
      }
    });
  }

  void _resetButtonPressed() {
    if (_stopWatch.isRunning) {
      _startStopButtonPressed();
    }
    setState(() {
      _stopWatch.reset();
      _setStopwatchText();
    });
  }

  void _setStopwatchText() {
    _stopwatchText =
        "${_stopWatch.elapsed.inHours.toString().padLeft(2, "0")}:${(_stopWatch.elapsed.inMinutes % 60).toString().padLeft(2, "0")}:${(_stopWatch.elapsed.inSeconds % 60).toString().padLeft(2, "0")}";
  }

  // Chart Funcs
  int time = 0;
  void updataDataSource(Timer timer) {
    _chartData.add(LiveData(time++, (math.Random().nextInt(60) + 30)));
    _chartData.removeAt(0);
    _chartSeriesController.updateDataSource(
        addedDataIndex: _chartData.length - 1, removedDataIndex: 0);
  }

  List<LiveData> getChartData() {
    return <LiveData>[
      LiveData(0, 220),
      LiveData(1, 220),
      LiveData(2, 220),
      LiveData(3, 220),
      LiveData(4, 220),
      LiveData(5, 220),
      LiveData(6, 220),
      LiveData(7, 220),
      LiveData(8, 220),
      LiveData(9, 220),
      // LiveData(10, 53),
      // LiveData(11, 72),
      // LiveData(12, 86),
      // LiveData(13, 52),
      // LiveData(14, 94),
      // LiveData(15, 92),
      // LiveData(16, 86),
      // LiveData(17, 72),
      // LiveData(18, 215)
    ];
  }
}
