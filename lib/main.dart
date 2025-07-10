import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:prime_app/launch_details.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _spaaceX = [];

  @override
  void initState() {
    super.initState();
    _apiCall();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SpaceX Launch Explore'), centerTitle: true),
      body: Center(
        child: _isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [CircularProgressIndicator(), Text('   Loading...')],
              )
            : _spaaceX.isEmpty
            ? Text('No data found!')
            : ListView.builder(
                itemCount: _spaaceX.length,
                itemBuilder: (_, i) {
                  final data = _spaaceX[i];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      margin: EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: data['success'] == true
                              ? Colors.green
                              : Colors.red,
                          child: Text(
                            data['success'] == true ? '✔' : '✖',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text("Title: Launch${data['name']}"),
                        subtitle: Text(" Date: ${data['date'] ?? 'N/A'}"),
                        trailing: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    LaunchDetails(body: data['details']),
                              ),
                            );
                          },
                          child: Text('See details...'),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Future<void> _apiCall() async {
    setState(() => _isLoading = true);

    try {
      var request = http.Request(
        'GET',
        Uri.parse('https://api.spacexdata.com/v4/launches'),
      );

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        List<dynamic> jsonData = jsonDecode(responseBody);

        List<Map<String, dynamic>> launchList = jsonData.map((launch) {
          return {
            'name': launch['name'],
            'success': launch['success'],
            'date': launch['date_utc'],
            'patchImage': launch['links']['patch']['small'],
            'fairings': launch['fairings'],
            'details': launch['details'] ?? 'No details available',
          };
        }).toList();

        setState(() {
          _isLoading = false;
          _spaaceX = launchList;
        });
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.reasonPhrase ?? 'Failed to load launches'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}
