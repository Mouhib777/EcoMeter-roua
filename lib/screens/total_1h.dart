import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import 'package:roua_benamor/constant/constant.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class Total1h extends StatefulWidget {
  @override
  _Total1hState createState() => _Total1hState();
}

class _Total1hState extends State<Total1h> {
  List<List<dynamic>> sheetData = [];

  @override
  void initState() {
    super.initState();
    fetchDataFromGoogleSheets();
  }

  Future<List<DataPoint>> fetchDataFromGoogleSheets() async {
    final response = await http.get(Uri.parse(url2GoogleSheet));

    if (response.statusCode == 200) {
      final csvData = response.body;
      final List<List<dynamic>> rowsAsListOfValues =
          CsvToListConverter().convert(csvData);

      final List<DataPoint> data = [];

      double sum = 0;
      int count = 0;

      for (int i = 0; i < rowsAsListOfValues.length; i++) {
        final row = rowsAsListOfValues[i];

        final timeFormatter = DateFormat('hh:mm:ss');
        final timestamp = timeFormatter.parse(row[1].toString());
        final value = double.parse(row[2].toString().replaceAll(',', '.'));

        sum += value;
        count++;

        if (count == 59) {
          final average = sum / count;
          data.add(DataPoint(timestamp, average));

          sum = 0;
          count = 0;
        }
      }

      return data;
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
      body: FutureBuilder<List<DataPoint>>(
        future: fetchDataFromGoogleSheets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching data'));
          } else if (snapshot.hasData) {
            return buildChart(snapshot.data!);
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
    );
  }

  Widget buildChart(List<DataPoint> data) {
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
            markerSettings: MarkerSettings(
              isVisible: true,
            ),
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
