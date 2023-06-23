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
        final dateFormatter = DateFormat('yyyy-MM-dd');
        final timeFormatter = DateFormat('hh:mm:ss');
        final date = row[0] != null
            ? dateFormatter.parse(row[0].toString())
            : DateTime.now(); // Provide a default date if it is null
        final timestamp = timeFormatter.parse(row[1].toString());
        final value = double.parse(row[2]
            .toString()
            .replaceAll(',', '.')); // Replace comma with period
        return DataPoint(date, timestamp, value);
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
        final dateFormatter = DateFormat('yyyy-MM-dd');
        final timeFormatter = DateFormat('hh:mm:ss');
        final date = row[0] != null
            ? dateFormatter.parse(row[0].toString())
            : DateTime.now(); // Provide a default date if it is null
        final timestamp = timeFormatter.parse(row[1].toString());
        final value = double.parse(row[2]
            .toString()
            .replaceAll(',', '.')); // Replace comma with period
        return DataPoint(date, timestamp, value);
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
                dateFormat: DateFormat('yyyy-MM-dd'),
                intervalType: DateTimeIntervalType.days,
              ),
              series: <ChartSeries<DataPoint, DateTime>>[
                LineSeries<DataPoint, DateTime>(
                  dataSource: displayedData,
                  xValueMapper: (DataPoint point, _) => point.date,
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
                itemCount: displayedData.length,
                itemExtent: 60.0, // Height of each row in the chart
                itemBuilder: (context, index) {
                  if (index == 0 ||
                      displayedData[index].date !=
                          displayedData[index - 1].date) {
                    // Display the date once per day
                    return ListTile(
                      title: Text(
                        DateFormat('yyyy-MM-dd')
                            .format(displayedData[index].date),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  } else {
                    // Display timestamp and value
                    return ListTile(
                      title: Text(displayedData[index].timestamp.toString()),
                      subtitle: Text(displayedData[index].value.toString()),
                    );
                  }
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
  final DateTime date;
  final DateTime timestamp;
  final double value;

  DataPoint(this.date, this.timestamp, this.value);
}
