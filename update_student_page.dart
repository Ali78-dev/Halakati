import 'package:flutter/material.dart';
import 'database_helper.dart';

class UpdateStudentPage extends StatefulWidget {
  final int id;
  final String name;
  final String age;
  final String circleName;

  const UpdateStudentPage({
    super.key,
    required this.id,
    required this.name,
    required this.age,
    required this.circleName,
  });

  @override
  State<UpdateStudentPage> createState() => _UpdateStudentPageState();
}

class _UpdateStudentPageState extends State<UpdateStudentPage> {
  StudentsDatabase sqlDb = StudentsDatabase();
  late TextEditingController nameController;
  late TextEditingController ageController;
  late TextEditingController circleController;

  @override
  void initState() {
    nameController = TextEditingController(text: widget.name);
    ageController = TextEditingController(text: widget.age);
    circleController = TextEditingController(text: widget.circleName);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تعديل بيانات الطالب الأساسية"),
        backgroundColor: Colors.teal.shade300,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ListView(
          children: [
            const Icon(Icons.edit_note, size: 70, color: Colors.teal),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "اسم الطالب",
                border: OutlineInputBorder(),
                filled: true,
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "العمر",
                border: OutlineInputBorder(),
                filled: true,
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: circleController,
              decoration: const InputDecoration(
                labelText: "اسم الحلقة",
                border: OutlineInputBorder(),
                filled: true,
              ),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.all(15),
              ),
              onPressed: () async {
                int response = await sqlDb.updateData('''
                  UPDATE Students SET 
                  name = "${nameController.text}",
                  age = "${ageController.text}",
                  circle_name = "${circleController.text}"
                  WHERE id = ${widget.id}
                ''');
                if (response > 0) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text(
                "حفظ التعديلات",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
