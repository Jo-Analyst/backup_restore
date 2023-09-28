import 'dart:io';

import 'package:backup_restore/db.dart';
import 'package:backup_restore/pages/person_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/hotmail.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          toolbarHeight: 80,
          titleTextStyle: TextStyle(fontSize: 20, color: Colors.black),
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Backup and Restore'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> persons = [];
  void _openScreenPerson() async {
    final confirmSave = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PersonPage(),
      ),
    );

    if (confirmSave == true) {
      load();
    }
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  load() async {
    persons = await DB.load();
    setState(() {});
  }

  Future<void> sendEmailWithAttachment(String backupFilePath) async {
    final smtpServer = hotmail(dotenv.get("EMAIL"), dotenv.get("PASSWORD"));
    final message = Message()
      ..from = Address(dotenv.get("EMAIL"), 'las')
      ..recipients.add('joalves3carvalho@gmail.com')
      ..subject = 'Backup do Banco de Dados'
      ..text = 'Anexo de backup do banco de dados'
      ..attachments.add(FileAttachment(File(backupFilePath)))
      ..html =
          '<div><h1>Anexo de backup do banco de dados</h1>Backup realizado pelo aplicativo App Kayke Barbearia no dia ${DateTime.now()}</div>';

    try {
      final sendReport = await send(message, smtpServer);
      print('E-mail enviado: ${sendReport.toString()}');
    } catch (e) {
      print('Erro ao enviar e-mail: $e');
    }
  }

  void backupDB() async {
    var status = await Permission.manageExternalStorage.status;
    if (!status.isGranted) {
      await Permission.manageExternalStorage.request();
    }

    var status1 = await Permission.storage.status;

    if (!status1.isGranted) {
      await Permission.storage.request();
    }

    try {
      File ourDbFile =
          File("/data/user/0/com.example.backup_restore/databases/teste.db");

      Directory? folderPathForDbFile = Directory('/storage/emulated/0/teste/');
      await folderPathForDbFile.create();
      await ourDbFile.copy("/storage/emulated/0/teste/teste.db");
      await sendEmailWithAttachment("/storage/emulated/0/teste/teste.db");
    } catch (e) {
      print(e.toString());
    }
  }

  void restoreDB() async {
    var status = await Permission.manageExternalStorage.status;

    if (!status.isGranted) {
      await Permission.manageExternalStorage.request();
    }

    var status1 = await Permission.storage.status;

    if (!status1.isGranted) {
      await Permission.storage.request();
    }

    try {
      File saveDBFile = File("/storage/emulated/0/teste/teste.db");

      await saveDBFile
          .copy("/data/user/0/com.example.backup_restore/databases/teste.db");
      load();
    } catch (e) {
      print(e.toString());
    }
  }

  void deleteDB() async {
    try {
      deleteDatabase(
          "/data/user/0/com.example.backup_restore/databases/teste.db");
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2 - 20,
                  child: ElevatedButton(
                    onPressed: () => backupDB(),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.backup),
                        SizedBox(width: 5),
                        Text("Backup")
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2 - 20,
                  child: ElevatedButton(
                    onPressed: () {
                      restoreDB();
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.restore),
                        SizedBox(width: 5),
                        Text("Restore")
                      ],
                    ),
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () async {
                deleteDB();
                load();
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete),
                  SizedBox(width: 5),
                  Text("Delete DB")
                ],
              ),
            ),
            const Divider(),
            SizedBox(
              height: MediaQuery.of(context).size.height - 230,
              child: ListView.separated(
                shrinkWrap: true,
                separatorBuilder: (_, __) => const Divider(
                  height: 4,
                ),
                itemCount: persons.length,
                itemBuilder: (_, i) {
                  var person = persons[i];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            person["name"],
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            const Text(
                              "Idade: ",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "${person["age"].toString().padLeft(2, "0")} anos",
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openScreenPerson,
        child: const Icon(Icons.add),
      ),
    );
  }
}
