import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import 'package:roua_benamor/constant/constant.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class total_24h extends StatefulWidget {
  @override
  _total_24hState createState() => _total_24hState();
}

class _total_24hState extends State<total_24h> {
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

      final List<DataPoint> data =
          rowsAsListOfValues.skip(0).map<DataPoint>((row) {
        final dateFormatter = DateFormat('dd/MM/yyyy');
        final timestamp = dateFormatter.parse(row[0].toString());
        final value = double.parse(row[2].toString().replaceAll(',', '.'));
        return DataPoint(timestamp, value);
      }).toList();

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
          'Total Consumption Energy (24h)',
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
    return SfCartesianChart(
      zoomPanBehavior: ZoomPanBehavior(
        enablePanning: true,
        enableDoubleTapZooming: true,
        enablePinching: true,
        zoomMode: ZoomMode.x,
      ),
      primaryXAxis: CategoryAxis(),
      series: <ChartSeries<DataPoint, String>>[
        LineSeries<DataPoint, String>(
            dataSource: data,
            xValueMapper: (DataPoint point, _) =>
                DateFormat('dd/MM/yyyy').format(point.timestamp),
            yValueMapper: (DataPoint point, _) => point.value,
            color: secondaryColor),
      ],
    );
  }
}

class DataPoint {
  final DateTime timestamp;
  final double value;

  DataPoint(this.timestamp, this.value);
}
