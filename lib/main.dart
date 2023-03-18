import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:fl_chart/fl_chart.dart';

import 'header_widget.dart';

void main() {
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
                    MaterialPageRoute(builder: (context) => const SecondRoute()),
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


class SecondRoute extends StatelessWidget {
  const SecondRoute({super.key});

  @override
  Widget build(BuildContext context) {

    // final List<SalesData> chartData = [
    //   SalesData(2010, 35),
    //   SalesData(2011, 28),
    //   SalesData(2012, 34),
    //   SalesData(2013, 32),
    //   SalesData(2014, 40)
    // ];

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Graph'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // SfCartesianChart(
              //   primaryXAxis: DateTimeAxis(),
              //   series: <ChartSeries>[
              //     LineSeries<SalesData, double>(
              //         dataSource: chartData,
              //         xValueMapper: (SalesData sales, _) => sales.year,
              //         yValueMapper: (SalesData sales, _) => sales.sales
              //     )
              //   ]
              // ),
              Container(
                padding: const EdgeInsets.all(10),
                width: double.infinity,
                height: 300,
                child: LineChart(
                  LineChartData(borderData: FlBorderData(show: false), lineBarsData: [
                    LineChartBarData(spots: [
                      const FlSpot(0, 148),
                      const FlSpot(1, 150),
                      const FlSpot(2, 151),
                      const FlSpot(3, 157),
                      const FlSpot(4, 142),
                      const FlSpot(5, 143),
                      const FlSpot(6, 147),
                      const FlSpot(7, 155),
                      const FlSpot(8, 149),
                      const FlSpot(9, 148),
                      const FlSpot(10, 150),
                      const FlSpot(11, 151),
                    ])
                  ]),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Go back!'),
              )
            ]
          ),
        ),
      ),
    );
  }
}

class SalesData {
  SalesData(this.year, this.sales);
  final double year;
  final double sales;
}