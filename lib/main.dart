import 'dart:ui';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:fl_chart/fl_chart.dart';
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
                child: HeaderWidget(_headerHeight, true, Icons.login_rounded),
              ),
              SizedBox(
                height: 150,
                width: 150,
                child: Image.network('https://img.freepik.com/free-icon/sunset_318-375746.jpg'),
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
    await FirebaseDatabase
      .instance
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

      FirebaseDatabase
      .instance
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
      addedDataIndex: _chartData.length-1, removedDataIndex:0);
      });
  }

  void initState(){
    _chartData=getChartData();
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            //   Container(
            //     padding: const EdgeInsets.all(10),
            //     width: double.infinity,
            //     height: 400,
            //     child: LineChart(
            //       LineChartData(borderData: FlBorderData(show: false), lineBarsData: [
            //         LineChartBarData(spots: [
            //           const FlSpot(0, 148),
            //           const FlSpot(1, 150),
            //           const FlSpot(2, 151),
            //           const FlSpot(3, 157),
            //           const FlSpot(4, 142),
            //           const FlSpot(5, 143),
            //           const FlSpot(6, 147),
            //           const FlSpot(7, 155),
            //           const FlSpot(8, 149),
            //           const FlSpot(9, 148),
            //           const FlSpot(10, 150),
            //           const FlSpot(11, 151),
            //         ],
            //         isCurved: true,
            //         barWidth: 5,
            //         isStrokeCapRound: true,
            //         dotData: FlDotData(
            //           show: true,
            //         ),
            //         belowBarData: BarAreaData(
            //           show: true,
            //         ),
            //       )
            //     ]),
            //   ),
            // ),
            SfCartesianChart(series: <ChartSeries>[
              LineSeries<LiveData, int>(
                onRendererCreated: (ChartSeriesController controller){
                  _chartSeriesController = controller;
                },
                dataSource: _chartData,
                color: const Color.fromRGBO(192, 108, 132, 1),
                xValueMapper: (LiveData sales, _) => sales.time,
                yValueMapper: (LiveData sales, _) => sales.speed,

              )

            ],
            primaryXAxis: NumericAxis(
              majorGridLines: const MajorGridLines(width: 0),
              edgeLabelPlacement: EdgeLabelPlacement.shift,
              interval: 3,
              title: AxisTitle(text: 'x')
            ),
            primaryYAxis: NumericAxis(
              axisLine: const AxisLine(width: 0),
              majorTickLines: const MajorTickLines(size:0),
              title: AxisTitle(text: 'y'),
            ),
            ),
            ElevatedButton(
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

  int time=0;
  void updataDataSource(Timer timer){
    _chartData.add(LiveData(time++, (math.Random().nextInt(60)+30))); 
    _chartData.removeAt(0); 
    _chartSeriesController.updateDataSource(
      addedDataIndex: _chartData.length-1, removedDataIndex:0);
  }

  List<LiveData> getChartData() {
    return <LiveData>[
      LiveData(0, 42),
      LiveData(1, 47),
      LiveData(2, 43),
      LiveData(3, 49),
      LiveData(4, 54),
      LiveData(5, 41),
      LiveData(6, 58),
      LiveData(7, 51),
      LiveData(8, 98),
      LiveData(9, 41),
      LiveData(10, 53),
      LiveData(11, 72),
      LiveData(12, 86),
      LiveData(13, 52),
      LiveData(14, 94),
      LiveData(15, 92),
      LiveData(16, 86),
      LiveData(17, 72),
      LiveData(18, 94)
    ];
  }
}

class LiveData {
  LiveData(this.time, this.speed);
  final int time;
  final num speed;
}
