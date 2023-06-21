import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import 'package:roua_benamor/constant/constant.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class total_1h extends StatefulWidget {
  @override
  _total_1hState createState() => _total_1hState();
}

class _total_1hState extends State<total_1h> {
  List<DataPoint> data = [];
  Timer? dataTimer;

  @override
  void initState() {
    super.initState();
    fetchDataFromGoogleSheets(); // Fetch data initially
    startDataTimer(); // Start the timer for periodic data fetching
  }

  @override
  void dispose() {
    dataTimer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  void startDataTimer() {
    const interval =
        Duration(seconds: 10); // Update interval (1 minute in this example)
    dataTimer = Timer.periodic(interval, (timer) {
      fetchDataFromGoogleSheets(); // Fetch data periodically
    });
  }

  Future<void> fetchDataFromGoogleSheets() async {
    final response = await http.get(Uri.parse(url2GoogleSheet));

    if (response.statusCode == 200) {
      final csvData = response.body;
      final List<List<dynamic>> rowsAsListOfValues =
          CsvToListConverter().convert(csvData);

      final List<DataPoint> fetchedData = rowsAsListOfValues
          .skip(rowsAsListOfValues.length - 1000)
          .map<DataPoint>((row) {
        final timeFormatter = DateFormat('hh:mm:ss');
        final timestamp = timeFormatter.parse(row[1].toString());
        final value = double.parse(row[2]
            .toString()
            .replaceAll(',', '.')); // Replace comma with period
        return DataPoint(timestamp, value);
      }).toList();

      setState(() {
        data = fetchedData; // Update the data and trigger a rebuild
      });
    } else {
      throw Exception('Failed to fetch data from Google Sheets');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Total Consumption Energy (1h)',
          style: GoogleFonts.montserrat(fontSize: 16),
        ),
      ),
      body: buildChart(),
    );
  }

  Widget buildChart() {
    if (data.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      child: SfCartesianChart(
        zoomPanBehavior: ZoomPanBehavior(
          enablePanning: true,
          enableDoubleTapZooming: true,
          enablePinching: true,
          zoomMode: ZoomMode.x,
        ),
        primaryXAxis: DateTimeAxis(
          dateFormat: DateFormat.Hms(),
          intervalType: DateTimeIntervalType.minutes,
        ),
        series: <ChartSeries<DataPoint, DateTime>>[
          LineSeries<DataPoint, DateTime>(
            dataSource: data,
            xValueMapper: (DataPoint point, _) => point.timestamp,
            yValueMapper: (DataPoint point, _) => point.value,
            color: secondaryColor,
          ),
        ],
      ),
    );
  }
}

class DataPoint {
  final DateTime timestamp;
  final double value;

  DataPoint(this.timestamp, this.value);
}
