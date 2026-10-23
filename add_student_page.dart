import 'package:flutter/material.dart';
import 'database_helper.dart';

class AddStudentPage extends StatefulWidget {
  const AddStudentPage({super.key});

  @override
  State<AddStudentPage> createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  StudentsDatabase sqlDb = StudentsDatabase();
  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController circleController = TextEditingController();
  TextEditingController initialMemorizedController = TextEditingController();
  TextEditingController initialRevisionController = TextEditingController();

  @override
  void initState() {
    dateController.text = DateTime.now().toString().split(' ')[0];
    super.initState();
  }

  void showCustomErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("تنبيه", style: TextStyle(color: Colors.red)),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("حسناً"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تسجيل طالب جديد في الحلقة"),
        backgroundColor: Colors.teal.shade300,
      ),
      body: Container(
        padding: const EdgeInsets.all(15),
        child: ListView(
          children: [
            const Icon(Icons.person_add, size: 70, color: Colors.teal),
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
              controller: dateController,
              decoration: const InputDecoration(
                labelText: "تاريخ الانضمام",
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
            const SizedBox(height: 15),
            TextField(
              controller: initialMemorizedController,
              decoration: const InputDecoration(
                labelText: "أين هو في الحفظ (المستوى الحالي عند التسجيل)",
                border: OutlineInputBorder(),
                filled: true,
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: initialRevisionController,
              decoration: const InputDecoration(
                labelText: "أين هو في المراجعة (المستوى الحالي عند التسجيل)",
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
                String studentName = nameController.text.trim();
                if (studentName.isNotEmpty &&
                    ageController.text.isNotEmpty &&
                    circleController.text.isNotEmpty) {
                  // التحقق من عدم وجود طالب بنفس الاسم مسبقاً
                  List existingStudent = await sqlDb.readData(
                    "SELECT * FROM Students WHERE name = '$studentName'",
                  );

                  if (existingStudent.isNotEmpty) {
                    if (!context.mounted) return;
                    showCustomErrorDialog(
                      context,
                      "هذا الطالب مسجل مسبقاً بنفس الاسم، لا يمكن تكراره.",
                    );
                  } else {
                    await sqlDb.insertData('''
                      INSERT INTO Students (name, age, join_date, circle_name, initial_memorized, initial_revision)
                      VALUES ("$studentName", "${ageController.text}", "${dateController.text}", "${circleController.text}", "${initialMemorizedController.text}", "${initialRevisionController.text}")
                    ''');
                    if (!context.mounted) return;
                    Navigator.of(context).pop(true);
                  }
                } else {
                  showCustomErrorDialog(
                    context,
                    "يرجى ملء الحقول الأساسية (اسم الطالب وعمره واسم الحلقة) على الأقل.",
                  );
                }
              },
              child: const Text(
                "حفظ بيانات الطالب الأساسية",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
