import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import 'package:roua_benamor/constant/constant.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class total_1h extends StatefulWidget {
  @override
  _total_1hState createState() => _total_1hState();
}

class _total_1hState extends State<total_1h> {
  List<List<dynamic>> sheetData = [];
  List<DataPoint> displayedData = [];

  @override
  void initState() {
    super.initState();
    fetchDataFromGoogleSheets();
  }

  Future<void> fetchDataFromGoogleSheets() async {
    final response = await http.get(Uri.parse(url2GoogleSheet));

    if (response.statusCode == 200) {
      final csvData = response.body;
      final List<List<dynamic>> rowsAsListOfValues =
          CsvToListConverter().convert(csvData);

      final List<DataPoint> data = rowsAsListOfValues.map<DataPoint>((row) {
        final timeFormatter = DateFormat('hh:mm:ss');
        final timestamp = timeFormatter.parse(row[1].toString());
        final value = double.parse(row[2]
            .toString()
            .replaceAll(',', '.')); // Replace comma with period
        return DataPoint(timestamp, value);
      }).toList();

      setState(() {
        sheetData = rowsAsListOfValues;
        displayedData = data.sublist(data.length - 60);
      });
    } else {
      throw Exception('Failed to fetch data from Google Sheets');
    }
  }

  void updateDisplayedData(int startIndex) {
    setState(() {
      displayedData =
          sheetData.sublist(startIndex, startIndex + 60).map<DataPoint>((row) {
        final timeFormatter = DateFormat('hh:mm:ss');
        final timestamp = timeFormatter.parse(row[1].toString());
        final value = double.parse(row[2]
            .toString()
            .replaceAll(',', '.')); // Replace comma with period
        return DataPoint(timestamp, value);
      }).toList();
    });
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
      body: Column(
        children: [
          Container(
            height: 400,
            child: SfCartesianChart(
              primaryXAxis: DateTimeAxis(
                dateFormat: DateFormat.Hms(),
                intervalType: DateTimeIntervalType.minutes,
              ),
              series: <ChartSeries<DataPoint, DateTime>>[
                LineSeries<DataPoint, DateTime>(
                  dataSource: displayedData,
                  xValueMapper: (DataPoint point, _) => point.timestamp,
                  yValueMapper: (DataPoint point, _) => point.value,
                  color: secondaryColor,
                ),
              ],
            ),
          ),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (scrollNotification is ScrollUpdateNotification) {
                  final pixels = scrollNotification.metrics.pixels;
                  final itemExtent = 60.0; // Height of each row in the chart

                  final startIndex = (pixels / itemExtent).floor();
                  updateDisplayedData(startIndex);
                }
                return false;
              },
              child: ListView.builder(
                itemCount: sheetData.length,
                itemExtent: 60.0, // Height of each row in the chart
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                        sheetData[index][1].toString()), // Display timestamp
                    subtitle:
                        Text(sheetData[index][2].toString()), // Display value
                  );
                },
              ),
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
