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
              Container(
                height: _headerHeight,
                child: const HeaderWidget(
                    _headerHeight, true, Icons.login_rounded),
              ),
              SizedBox(
                height: 150,
                width: 150,
                child: Image.network(
                    'https://img.freepik.com/free-icon/sunset_318-375746.jpg'),
              ),
              const SizedBox(
                height: 25,
              ),
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
                height: 40,
              ),
              const Text(
                "Body statistics on your fingertips",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              const SizedBox(
                height: 50,
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
      FinalData('Vitamin-D', 1, const Color.fromARGB(255, 224, 243, 21)),
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
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            SfCartesianChart(
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
                  majorGridLines: const MajorGridLines(width: 0),
                  edgeLabelPlacement: EdgeLabelPlacement.shift,
                  interval: 3,
                  title: AxisTitle(text: 'Time')),
              primaryYAxis: NumericAxis(
                axisLine: const AxisLine(width: 0),
                majorTickLines: const MajorTickLines(size: 0),
                title: AxisTitle(text: 'GSR Value'),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 20),
                  backgroundColor: const Color.fromARGB(255, 0, 243, 0),
                  foregroundColor: Colors.black,
                  fixedSize: const Size(200, 100),
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
                  MaterialPageRoute(builder: (context) => ThirdRoute()),
                );
              },
              child: const Text(
                'View your body statistics',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            ElevatedButton(
              // style: ElevatedButton.styleFrom(
              //   textStyle: const TextStyle(fontSize: 15),
              //   fixedSize: const Size(150, 70)
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
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Body Statistics'),
        ),
        body: Center(
          child:
              // ignore: prefer_const_literals_to_create_immutables
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
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
            const SizedBox(
                width: 300,
                child: StepProgressIndicator(
                  totalSteps: 100,
                  currentStep: 80, //10,25,50,75,90
                  size: 25,
                  padding: 0,
                  selectedColor: Color.fromARGB(255, 255, 133, 133),
                  unselectedColor: Colors.grey,
                  roundedEdges: Radius.circular(10),
                  selectedGradientColor: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.fromARGB(255, 255, 133, 133),
                      Color.fromARGB(255, 223, 63, 51)
                    ],
                  ),
                  unselectedGradientColor: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.grey, Colors.grey],
                  ),
                )),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "{{Dehydration Status}}",
              style: TextStyle(
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
                      children: const [
                        Text(
                          "Curent UV Index : {{ UV }}",
                          style: TextStyle(fontSize: 20),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Based on the current UV Index and your dehydration status, you are likely to get {{ degree }} in {{ time }} seconds.",
                          style: TextStyle(fontSize: 15),
                        ),
                        SizedBox(
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
                      children: const [
                        Text(
                          "Required Amount Per Day :",
                          style: TextStyle(fontSize: 15),
                        ),
                        Text(
                          "600 IU",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        CircularStepProgressIndicator(
                          totalSteps: 600,
                          currentStep: 250,
                          // stepSize: 10,
                          selectedColor: Colors.greenAccent,
                          unselectedColor: Colors.grey,
                          padding: 0,
                          width: 150,
                          height: 150,
                          selectedStepSize: 10,
                          stepSize: 10,
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
                      children: const [
                        Text(
                          "Permissible Amount Per Day :",
                          style: TextStyle(fontSize: 15),
                        ),
                        Text(
                          "4000 IU",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        CircularStepProgressIndicator(
                          totalSteps: 4000,
                          currentStep: 2500,
                          // stepSize: 10,
                          selectedColor: Colors.greenAccent,
                          unselectedColor: Colors.grey,
                          padding: 0,
                          width: 150,
                          height: 150,
                          selectedStepSize: 10,
                          stepSize: 10,
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
