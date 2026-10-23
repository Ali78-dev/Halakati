import 'package:flutter/material.dart';
import 'database_helper.dart';

class StudentHistoryPage extends StatefulWidget {
  final Map student;

  const StudentHistoryPage({super.key, required this.student});

  @override
  State<StudentHistoryPage> createState() => _StudentHistoryPageState();
}

class _StudentHistoryPageState extends State<StudentHistoryPage> {
  StudentsDatabase sqlDb = StudentsDatabase();
  List dailyRecords = [];
  bool isLoading = true;

  Future getRecords() async {
    List response = await sqlDb.readData(
      "SELECT * FROM DailyRecords WHERE student_id = ${widget.student['id']} ORDER BY id DESC",
    );
    dailyRecords.clear();
    dailyRecords.addAll(response);
    isLoading = false;
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    getRecords();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("سجل الطالب: ${widget.student['name']}"),
        backgroundColor: Colors.teal.shade300,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // بطاقة بيانات الطالب الأساسية
            Card(
              color: Colors.teal.shade50,
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "العمر: ${widget.student['age']} | الحلقة: ${widget.student['circle_name']}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text("تاريخ الانضمام: ${widget.student['join_date']}"),
                    Text(
                      "المستوى الأولي (حفظ): ${widget.student['initial_memorized']}",
                    ),
                    Text(
                      "المستوى الأولي (مراجعة): ${widget.student['initial_revision']}",
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 20, thickness: 2),
            const Text(
              "سجل الحفظ والمراجعة اليومي:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : dailyRecords.isEmpty
                  ? const Center(
                      child: Text("لا توجد سجلات يومية مسجلة حتى الآن"),
                    )
                  : ListView.builder(
                      itemCount: dailyRecords.length,
                      itemBuilder: (context, i) {
                        return Card(
                          child: ListTile(
                            title: Text("التاريخ: ${dailyRecords[i]['date']}"),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("الحفظ: ${dailyRecords[i]['memorized']}"),
                                Text(
                                  "المراجعة: ${dailyRecords[i]['revision']}",
                                ),
                                if (dailyRecords[i]['notes'] != "")
                                  Text(
                                    "ملاحظات: ${dailyRecords[i]['notes']}",
                                    style: const TextStyle(color: Colors.green),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
