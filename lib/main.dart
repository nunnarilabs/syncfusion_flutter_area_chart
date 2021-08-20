import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'sample_view.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late bool isCardView = false;
  late TooltipBehavior _tooltipBehavior;
  List<SalesData> chartData2 = [];
  List<SalesData> chartDataPi = [];

  Future loadSalesData() async {
    final String jsonString = await getJsonFromAssets();
    final dynamic jsonResponse = json.decode(jsonString);
    for (Map<String, dynamic> i in jsonResponse) {
      chartData2.add(SalesData.fromJson(i));
    }
  }

  Future<String> getJsonFromAssets() async {
    return await rootBundle.loadString('dapi.json');
  }

  Future loadSalesDataPI() async {
    final String jsonString = await getJsonFromAssetsPI();
    final dynamic jsonResponse = json.decode(jsonString);
    for (Map<String, dynamic> i in jsonResponse) {
      chartDataPi.add(SalesData.fromJson(i));
    }
  }

  Future<String> getJsonFromAssetsPI() async {
    return await rootBundle.loadString('propedium_iodide.json');
  }

  @override
  void initState() {
    _tooltipBehavior =
        TooltipBehavior(enable: true, header: '', canShowMarker: false);
    loadSalesData();
    loadSalesDataPI();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildStackedAreaChart();
  }

  /// Returns the cartesian stacked area chart.
  SfCartesianChart _buildStackedAreaChart() {
    return SfCartesianChart(
      title: ChartTitle(text: isCardView ? '' : 'Fluorescence SpectraViewer'),
      legend: Legend(
          isVisible: !isCardView, overflowMode: LegendItemOverflowMode.wrap),
      primaryXAxis: NumericAxis(
          majorGridLines: const MajorGridLines(width: 0),
          minimum: 300,
          maximum: 900),
      primaryYAxis: NumericAxis(
          axisLine: const AxisLine(width: 0),
          minimum: 0,
          maximum: 1,
          labelFormat: '{value}',
          majorTickLines: const MajorTickLines(size: 0)),
      series: _getAreaSeries(),
      tooltipBehavior: _tooltipBehavior,
      palette: <Color>[
        Color.fromRGBO(255, 120, 0, 0.8),
        Color.fromRGBO(0, 107, 255, 0.8)
      ],
    );
  }

  /// Returns the list of chart series which need to render
  /// on the stacked area chart.
  List<AreaSeries<SalesData, int>> _getAreaSeries() {
    return <AreaSeries<SalesData, int>>[
      AreaSeries<SalesData, int>(
          animationDuration: 2500,
          dataSource: chartDataPi,
          xValueMapper: (SalesData sales, _) => sales.emission as int,
          yValueMapper: (SalesData sales, _) => sales.intensity,
          name: 'Prpo'),
      AreaSeries<SalesData, int>(
          animationDuration: 2500,
          dataSource: chartData2,
          xValueMapper: (SalesData sales, _) => sales.emission as int,
          yValueMapper: (SalesData sales, _) => sales.intensity,
          name: 'DAPI')
    ];
  }
}

class SalesData {
  double emission;
  double intensity;

  SalesData(this.emission, this.intensity);

  factory SalesData.fromJson(Map<String, dynamic> parsedJson) {
    return SalesData(
      parsedJson['emission'],
      parsedJson['intensity'],
    );
  }
}
