import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:http/http.dart' as http;



void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  final groupTokens = [
    "bramsdockercomposecirclejerk"
  ];

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
        primarySwatch: Colors.orange,
      ),
      home: Scaffold(
        body: Column(
          children: <Widget>[
            Expanded(child: MarketOverview(interval: Duration(minutes: 2), rate: Duration(seconds: 1))),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                children: groupTokens.map((token) => GroupCard(xToken: token)).toList(),
              ),
            )
          ],
        )
      )
    );
  }
}


class GroupCard extends StatefulWidget {

  final String xToken;

  const GroupCard({Key key, this.xToken}) : super(key: key);

  @override
  _GroupCardState createState() => _GroupCardState();
}

class _GroupCardState extends State<GroupCard> {

  String name;
  int balance = 0;
  int stockValue = 0;
  int totalValue = 0;

  int lastBalance = 0;

  dynamic info;

  @override
  void initState() {
    print("Updating info for: ${widget.xToken}");
    startUpdateLoop(widget.xToken);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: info == null ? 0 : info["stonk_count"] > 0 ? 16 : 0,
      child: Column(
        children: <Widget>[
          Text(info == null ? "?" : info["name"], style: TextStyle(fontSize: 24)),
          Text("\$${info['total_value']}.00", style: TextStyle(fontSize: 38, color: 100000 > balance ? Colors.red : Colors.green)),
          Text("Balance"),
          Text("\$${info['balance']}.00"),
          Text("In stocks"),
          Text("\$${info['stonk_value']}.00")
        ],
      ),
    );
  }

  void startUpdateLoop(String xToken) async {
    do {
      await Future.delayed(Duration(seconds: 1), () => updateInfo(xToken));
    } while (true);
  }

  void updateInfo(String xToken) async {
    var url = "http://srv.ruslan.dk:3001/api/v1/account";

    try {
      var response = await http.get(url, headers: {
        "X-Token" : xToken
      });
      var i = jsonDecode(response.body);
      setState(() {
        info = i;
      });
    } on Exception catch (e) {
      print(e);
    }
  }
}




class MarketOverview extends StatelessWidget {
  final Duration interval;
  final Duration rate;

  const MarketOverview({Key key, this.interval, this.rate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Expanded(child: StonksMarketChart(animate: true, interval: interval, rate: rate))
            ],
          ),
        ),
        elevation: 16,
      ),
    );
  }
}

class StonksMarketChart extends StatefulWidget {
  
  final bool animate;
  final Duration interval;
  final Duration rate;

  const StonksMarketChart({Key key, this.animate, @required this.interval, @required this.rate}) : super(key: key);

  @override
  _StonksMarketChartState createState() => _StonksMarketChartState();
}

class _StonksMarketChartState extends State<StonksMarketChart> {
  int lastPrice = 0, currentPrice = 0;

  charts.Series<StonksRecord, DateTime> records;

  @override 
  void initState() {
    startUpdateLoop();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // Headline
        headline(),

        // Updating chart
        Expanded(
          child: charts.TimeSeriesChart(
            records == null ? [] : [records],
            animate: widget.animate,
            dateTimeFactory: const charts.LocalDateTimeFactory()
            ),
        )
      ],
    );
  }

  Widget headline() {
    var difference = currentPrice - lastPrice;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text("RUSLAN Stonks - Ligma Inc.        ", style: Theme.of(context).textTheme.headline),
        Text("\$${currentPrice}.00", style: TextStyle(
          fontSize: 48, 
          color: difference > 0 ? Colors.green : Colors.red
        )),
        difference > 0 ? Icon(Icons.arrow_drop_up, color: Colors.green) : Icon(Icons.arrow_drop_down, color: Colors.red)
      ],
    );
  }

  void startUpdateLoop() async {
    do {
      await Future.delayed(widget.rate, () => updateRecords());
    } while (true);
  }

  void updateRecords() async {
    var to = DateTime.now();
    var from = to.subtract(widget.interval);

    var url = "http://srv.ruslan.dk:3001/api/v1/market?from=${from.toIso8601String()}&to=${to.toIso8601String()}";
    var marketData = List<StonksRecord>();
    try {
      var response = await http.get(url, headers: {"X-Token" : "bramsdockercomposecirclejerk"});
      jsonDecode(response.body).forEach((o) => marketData.add(StonksRecord(
        time:  DateTime.parse(o["recorded"]),
        price: o["price"]
      )));
      
      setState(() {
        if (records != null && records.data.length > 0)
          lastPrice = records.data.last.price;

        records = charts.Series<StonksRecord, DateTime>(
          id: 'Records',
          colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
          domainFn: (StonksRecord records, _) => records.time,
          measureFn: (StonksRecord records, _) => records.price,
          measureLowerBoundFn: (StonksRecord records, _) => 0,
          data: marketData
        );

        if (records != null && records.data.length > 0)
          currentPrice = records.data.last.price;
      });
      
    } on Exception catch (e) {
      print(e);
      setState(() {
        records = charts.Series<StonksRecord, DateTime>(
          id: 'Records',
          colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
          domainFn: (StonksRecord records, _) => records.time,
          measureFn: (StonksRecord records, _) => records.price,
          data: []
        );
      });
    }
  }
}

class StonksRecord {
  final DateTime time;
  final int price;

  StonksRecord({this.time, this.price});
}