import 'package:flutter/material.dart';
import 'database_helper.dart';

class AddDailyRecordPage extends StatefulWidget {
  final int studentId;
  final String studentName;

  const AddDailyRecordPage({
    super.key,
    required this.studentId,
    required this.studentName,
  });

  @override
  State<AddDailyRecordPage> createState() => _AddDailyRecordPageState();
}

class _AddDailyRecordPageState extends State<AddDailyRecordPage> {
  StudentsDatabase sqlDb = StudentsDatabase();
  TextEditingController memorizedController = TextEditingController();
  TextEditingController revisionController = TextEditingController();
  TextEditingController notesController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  @override
  void initState() {
    dateController.text = DateTime.now().toString().split(' ')[0];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("تسجيل يومي: ${widget.studentName}"),
        backgroundColor: Colors.amber.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ListView(
          children: [
            const Icon(Icons.book, size: 70, color: Colors.amber),
            const SizedBox(height: 20),
            TextField(
              controller: dateController,
              decoration: const InputDecoration(
                labelText: "تاريخ اليوم",
                border: OutlineInputBorder(),
                filled: true,
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: memorizedController,
              decoration: const InputDecoration(
                labelText: "حفظ اليوم (الجديد)",
                border: OutlineInputBorder(),
                filled: true,
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: revisionController,
              decoration: const InputDecoration(
                labelText: "مراجعة اليوم",
                border: OutlineInputBorder(),
                filled: true,
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: "ملاحظات أو التقدم",
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
                if (memorizedController.text.isNotEmpty ||
                    revisionController.text.isNotEmpty) {
                  await sqlDb.insertData('''
                    INSERT INTO DailyRecords (student_id, date, memorized, revision, notes)
                    VALUES (${widget.studentId}, "${dateController.text}", "${memorizedController.text}", "${revisionController.text}", "${notesController.text}")
                  ''');
                  Navigator.of(context).pop(true);
                }
              },
              child: const Text(
                "حفظ السجل اليومي",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
