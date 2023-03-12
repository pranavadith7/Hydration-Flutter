import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:syncfusion_flutter_charts/charts.dart';

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
  late List<FinalData> _chartData;
  @override
  void initState(){
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
              child: HeaderWidget(_headerHeight, true, Icons.login_rounded), //let's create a common header widget
            ),
              SfCircularChart(
                legend: Legend(
                  isVisible: true,
                  position: LegendPosition.bottom,
                ),
                series: <CircularSeries>[
                  DoughnutSeries<FinalData, String>(
                    dataSource: _chartData,
                    pointColorMapper: (FinalData data,_) => data.color,
                    xValueMapper: (FinalData data,_) => data.label,
                    yValueMapper: (FinalData data,_) => data.value,
                    explode: true,
                    explodeAll: true,
                  )
                ],
              ),
              const SizedBox(
                height: 50,
              ),
              const Text(
                "Body statistics on your fingertips",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 20),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  fixedSize: const Size(200, 60),
                  side: const BorderSide(
                    width:3, 
                    color:Colors.white30,
                  ),
                  elevation: 3, 
                  shape: RoundedRectangleBorder( 
                    borderRadius: BorderRadius.circular(20)
                  ),
                  padding: const EdgeInsets.all(20) 
                ),
                onPressed: () => print('pressed'),
                child: const Text('Get Started'),
              )
            ],
          ),
        ),
      ),
    );
  }
  List<FinalData> getChartData(){
    final List<FinalData> chartData = [
      FinalData('Hydration', 1, const Color.fromARGB(255, 0, 145, 255)),
      FinalData('Sunburn', 1, const Color.fromARGB(255, 255, 149, 0)),
      FinalData('Vitamin-D', 1, const Color.fromARGB(255, 224, 243, 21)),
    ];
    return chartData;
  }
}

class FinalData{
  FinalData(this.label, this.value, this.color);
  final String label;
  final int value;
  final Color color;
}