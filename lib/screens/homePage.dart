import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import 'package:roua_benamor/constant/constant.dart';
import 'package:roua_benamor/screens/login.dart';
import 'package:roua_benamor/screens/total_1h.dart';
import 'package:roua_benamor/screens/total_24h.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<List<dynamic>> data = [];

  @override
  void initState() {
    super.initState();
    getUser_Data();
    fetchDataFromSheet();
  }

  Future<void> fetchDataFromSheet() async {
    final url = urlGoogleSheet;

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final csvData = response.body;
      final List<List<dynamic>> parsedData =
          CsvToListConverter().convert(csvData);
      setState(() {
        data = parsedData;
      });
    }
  }

  var message;
  var message_display;
  @override
  var user_data;

  Future<DocumentSnapshot> getUser_Data() async {
    final User? user1 = FirebaseAuth.instance.currentUser;
    String? _uid = user1!.uid;
    var result1 =
        await FirebaseFirestore.instance.collection('users').doc(_uid).get();
    setState(() {
      user_data = result1;
    });
    return result1;
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      message = data.last[2].toString();
    });
    if (message == 'TRUE') {
      setState(() {
        message_display =
            'Attention: Smart energy meter failure! Data = 0. Please investigate and resolve.';
      });
    } else if (message == 'FALSE') {
      setState(() {
        message_display = 'Great News for you';
      });
    }
    return Scaffold(
        floatingActionButton: SpeedDial(
          label: Text(
            "Charts",
            style: GoogleFonts.montserratAlternates(),
          ),
          elevation: 6.0,
          backgroundColor: Color(0xffa2061b),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
          ),
          animatedIcon: AnimatedIcons.menu_close,
          children: [
            SpeedDialChild(
              labelStyle: GoogleFonts.montserrat(),
              child: Icon(Icons.add_chart),
              label: 'Per Day (24h)',
              onTap: () {
                user_data?["verifié"] == "oui"
                    ? Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Total24h()))
                    : EasyLoading.showError("You don't have the access");
              },
            ),
            SpeedDialChild(
              labelStyle: GoogleFonts.montserrat(),
              child: Icon(Icons.add_chart_outlined),
              label: 'Per Hour (1h)',
              onTap: () {
                user_data?["verifié"] == "oui"
                    ? Navigator.push(context,
                        MaterialPageRoute(builder: (context) => total_1h()))
                    : EasyLoading.showError("You don't have the access");
              },
            ),
            SpeedDialChild(
              labelStyle: GoogleFonts.montserrat(),
              child: Icon(Icons.add_chart),
              label: 'AVG per hour',
              onTap: () {
                user_data?["verifié"] == "oui"
                    ? Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Total24h()))
                    : EasyLoading.showError("You don't have the access");
              },
            ),
          ],
        ),
        appBar: AppBar(
          title: Text(
            'Eco-SEE',
            style: GoogleFonts.montserrat(letterSpacing: 2),
          ),
          centerTitle: true,
          leading: IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).push(PageRouteBuilder(
                    transitionDuration: Duration.zero,
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        LoginScreen()));
              },
              icon: Icon(Icons.logout)),
        ),
        body: user_data?["verifié"] == "oui"
            ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Instant Data',
                      style: GoogleFonts.montserrat(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: secondaryColor),
                    ),
                    SizedBox(height: 16.0),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Last Date',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(
                                    data.isNotEmpty
                                        ? data.last[0].toString()
                                        : '',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    data.isNotEmpty
                                        ? data.last[1].toString()
                                        : '',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 16.0),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Alert',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(
                                    message_display,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 14,
                                      color: message == 'TRUE'
                                          ? Colors.red
                                          : Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Current',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(
                                    data.isNotEmpty
                                        ? data.last[3].toString() + ' A'
                                        : '',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 16.0),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Energy',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(
                                    data.isNotEmpty
                                        ? data.last[4].toString() + ' KW'
                                        : '',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Voltage',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(
                                    data.isNotEmpty
                                        ? data.last[5].toString() + ' V'
                                        : '',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 16.0),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Power',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(
                                    data.isNotEmpty
                                        ? data.last[6].toString() + ' W'
                                        : '',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          'All Data',
                          style: GoogleFonts.montserrat(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: secondaryColor,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          data.length.toString(),
                          style: GoogleFonts.montserratAlternates(
                              fontSize: 14, color: Colors.grey),
                        )
                      ],
                    ),
                    SizedBox(height: 8.0),
                    Expanded(
                      child: ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          final rowData = data.isNotEmpty ? data.last : [];
                          String time = '';
                          String alerte = '';
                          String current = '';
                          String energy = '';
                          String voltage = '';
                          String power = '';

                          if (rowData.length >= 2) {
                            time = rowData[1].toString();
                          }

                          if (rowData.length >= 3) {
                            alerte = rowData[2].toString();
                          }

                          if (rowData.length >= 4) {
                            current = rowData[3].toString();
                          }

                          if (rowData.length >= 5) {
                            energy = rowData[4].toString();
                          }

                          if (rowData.length >= 6) {
                            voltage = rowData[5].toString();
                          }

                          if (rowData.length >= 7) {
                            power = rowData[6].toString();
                          }

                          return ListTile(
                            title: Text(
                              'Time: $time',
                              style: GoogleFonts.montserrat(),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Alerte: $alerte',
                                  style: GoogleFonts.montserrat(),
                                ),
                                Text(
                                  'Current: $current',
                                  style: GoogleFonts.montserrat(),
                                ),
                                Text(
                                  'Energy: $energy',
                                  style: GoogleFonts.montserrat(),
                                ),
                                Text(
                                  'Voltage: $voltage',
                                  style: GoogleFonts.montserrat(),
                                ),
                                Text(
                                  'Power: $power',
                                  style: GoogleFonts.montserrat(),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              )
            : Center(
                child: Text(
                  "You are not verified, contact the support",
                  style: GoogleFonts.montserrat(
                      color: Color(0xffa2061b), fontWeight: FontWeight.w500),
                ),
              ));
  }
}
