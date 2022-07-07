import 'dart:io';
import 'dart:convert';
import 'package:battery_info/battery_info_plugin.dart';
import 'package:battery_info/model/android_battery_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'logic/bloc/battery_block_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  runApp(MyApp(
    batteryDetails: BatteryInfoPlugin(),
  ));
}

class MyApp extends StatelessWidget {
  final BatteryInfoPlugin? batteryDetails;
  const MyApp({Key? key, @required this.batteryDetails}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<BatteryBlockBloc>(
            create: (batteryBlocContext) =>
                BatteryBlockBloc(batteryDetails: batteryDetails),
          )
        ],
        child: MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: MyHomePage(title: 'homepage')));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> {
  final pdf = pw.Document();
  final myController = TextEditingController();
  final numController = TextEditingController();
  List<Map> list = [];
  dynamic prefs;
  int number = 0;
  var textfield = '';
  int _counter = 0;
  String retrivedData = '';
  @override
  void initState() {
    super.initState();
    // Start listening to changes.
    myController.addListener(_printLatestValue);
    numController.addListener(_savenum);
  }
 // number text field controller
  void _savenum() {
    number = int.parse(numController.text);
  }
// name textfield controller
  void _printLatestValue() {
    textfield = myController.text;
  }
// creating data base and adding data
  void createdB() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'demo.db');
    Database database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      // When creating the db, create the table
      await db.execute(
          'CREATE TABLE Test (id INTEGER PRIMARY KEY, name TEXT, num Integer)');
    });
    await database.transaction((txn) async {
      int id1 = await txn.rawInsert(
          'INSERT INTO Test(name, num) VALUES(?, ?)', [textfield, number]);
    });
    list = await database.rawQuery('SELECT * FROM Test');

  }
//saving data to pdf and opening the file
  savePdf() async {
    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
              child: pw.Column(children: [
            pw.Text(list[0]['name']),
            pw.Text(list[0]['num'].toString())
          ])); // Center
        })); //
    print(list[1]['num']);
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/example.pdf");
    await file.writeAsBytes(await pdf.save());
    OpenFile.open('/data/user/0/com.example.batterybloc/cache/example.pdf');
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }
  //Store data in shared Preferences
  void storeInSharedPref() async {
    prefs = await SharedPreferences.getInstance();

// Save an integer value to 'counter' key.
    await prefs.setString('db', list[0]['name']);
  }
  //Get data from shared preferences
  void retrivedata() {
    setState(() {
      retrivedData = prefs.getString('db');
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(retrivedData),
            TextField(
              controller: myController,
              decoration: InputDecoration(hintText: 'Enter Name'),
            ),
            TextField(
              controller: numController,
              decoration: InputDecoration(hintText: 'Enter number'),
            ),
            ElevatedButton(onPressed: createdB, child: Text('Store in Db')),
            ElevatedButton(onPressed: savePdf, child: Text('Print pdf')),
            ElevatedButton(
                onPressed: storeInSharedPref,
                child: Text('Store Data in sharedPrefs')),
            ElevatedButton(onPressed: retrivedata, child: Text('retrive data')),
            BlocBuilder<BatteryBlockBloc, BatteryBlockState>(
              bloc: context.read<BatteryBlockBloc>()..add(GetHealth()),
              builder: (context, state) {
                return Column(children: <Widget>[
                  Text(state.health),
                  Text(state.batteryLevel.toString()),
                  IconButton(
                    icon: const Icon(Icons.report),
                    color: Colors.black,
                    onPressed: () {},
                  ),
                ]);
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), 
    );
  }
}
