import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import 'package:roua_benamor/constant/constant.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class total_1h_AVG extends StatefulWidget {
  @override
  _total_1h_AVGState createState() => _total_1h_AVGState();
}

class _total_1h_AVGState extends State<total_1h_AVG> {
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
      final int rowCount = rowsAsListOfValues.length;
      final int startIndex = rowCount > 700 ? rowCount - 800 : 0;

      final List<List<dynamic>> last700Rows =
          rowsAsListOfValues.sublist(startIndex);
      final int chunkSize = 60;
      final int chunkCount = (last700Rows.length / chunkSize).ceil();

      for (int i = 0; i < chunkCount; i++) {
        final int startIndex = i * chunkSize;
        final int endIndex = (startIndex + chunkSize) < last700Rows.length
            ? (startIndex + chunkSize)
            : last700Rows.length;

        final List<DataPoint> chunkData =
            last700Rows.sublist(startIndex, endIndex).map<DataPoint>((row) {
          final timeFormatter = DateFormat('HH:mm:ss');
          final timestamp = timeFormatter.parse(row[1].toString());
          final value = double.parse(row[2].toString().replaceAll(',', '.'));
          return DataPoint(timestamp, value);
        }).toList();

        final double chunkAverage = calculateAverage(chunkData);
        final DataPoint averageDataPoint =
            DataPoint(chunkData.last.timestamp, chunkAverage);
        data.add(averageDataPoint);
      }

      return data;
    } else {
      throw Exception('Failed to fetch data from Google Sheets');
    }
  }

  double calculateAverage(List<DataPoint> data) {
    if (data.isEmpty) {
      return 0.0;
    }

    double sum = 0.0;
    for (final dataPoint in data) {
      sum += dataPoint.value;
    }

    return sum / data.length;
  }

  List<DataPoint> findPeaks(List<DataPoint> data) {
    final List<DataPoint> peaks = [];

    if (data.length >= 3) {
      for (int i = 1; i < data.length - 1; i++) {
        if (data[i].value > data[i - 1].value &&
            data[i].value > data[i + 1].value) {
          peaks.add(data[i]);
        }
      }
    }

    return peaks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Average per hour',
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
    final List<DataPoint> peaks = findPeaks(data);
    final DateTimeAxis primaryXAxis = DateTimeAxis(
      dateFormat: DateFormat.Hms(),
      intervalType: DateTimeIntervalType.minutes,
    );

    return Container(
      width: MediaQuery.of(context).size.width,
      child: RotatedBox(
        quarterTurns: 1,
        child: SfCartesianChart(
          primaryXAxis: primaryXAxis,
          series: <ChartSeries>[
            LineSeries<DataPoint, DateTime>(
              dataSource: data,
              xValueMapper: (DataPoint point, _) => point.timestamp,
              yValueMapper: (DataPoint point, _) => point.value,
              color: secondaryColor,
            ),
            ScatterSeries<DataPoint, DateTime>(
              dataSource: peaks,
              xValueMapper: (DataPoint point, _) => point.timestamp,
              yValueMapper: (DataPoint point, _) => point.value,
              color: primaryColor,
              markerSettings: MarkerSettings(
                isVisible: true,
                color: primaryColor,
                shape: DataMarkerType.circle,
                borderWidth: 1,
                borderColor: primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DataPoint {
  final DateTime timestamp;
  final double value;

  DataPoint(this.timestamp, this.value);
}
