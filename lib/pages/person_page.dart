import 'package:backup_restore/db.dart';
import 'package:flutter/material.dart';

class PersonPage extends StatefulWidget {
  const PersonPage({super.key});

  @override
  State<PersonPage> createState() => _PersonPageState();
}

class _PersonPageState extends State<PersonPage> {
  String _name = "";
  int _age = 0;
  bool isValidate = true;

  save() async {
    if (_name.isEmpty) {
      setState(() {
        isValidate = false;
      });
      return;
    }

    await DB.save({"name": _name, "age": _age});
    setState(() {
      isValidate = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Seus dados"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Seu nome",
                ),
                onChanged: (name) => setState(() {
                  _name = name.trim();
                  isValidate = _name.isNotEmpty ? true : false;
                }),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Sua idade",
                ),
                onChanged: (age) => setState(() {
                  _age = int.parse(age);
                }),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                save();
                if (isValidate) {
                  Navigator.of(context).pop(true);
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check),
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    child: const Text("Salvar"),
                  )
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 10),
              child: Visibility(
                visible: !isValidate,
                child: const Text(
                  "Informe o nome.",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
