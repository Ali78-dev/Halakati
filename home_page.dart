import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'add_student_page.dart';
import 'update_student_page.dart';
import 'add_daily_record_page.dart';
import 'student_history_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  StudentsDatabase sqlDb = StudentsDatabase();
  bool isLoading = true;
  List studentsList = [];
  List filteredStudents = [];
  TextEditingController searchController = TextEditingController();

  Future readStudents() async {
    try {
      setState(() {
        isLoading = true;
      });

      List<Map> response = await sqlDb.readData("SELECT * FROM Students");
      studentsList.clear();

      for (var student in response) {
        Map<String, dynamic> studentMap = Map<String, dynamic>.from(student);

        try {
          List lastRecord = await sqlDb.readData(
            "SELECT * FROM DailyRecords WHERE student_id = ${studentMap['id']} ORDER BY id DESC LIMIT 1",
          );
          if (lastRecord.isNotEmpty) {
            studentMap['last_memorized'] = lastRecord[0]['memorized'] ?? '';
            studentMap['last_revision'] = lastRecord[0]['revision'] ?? '';
            studentMap['last_date'] = lastRecord[0]['date'] ?? '';
          } else {
            studentMap['last_memorized'] =
                studentMap['initial_memorized'] ?? '';
            studentMap['last_revision'] = studentMap['initial_revision'] ?? '';
            studentMap['last_date'] = studentMap['join_date'] ?? '';
          }
        } catch (e) {
          studentMap['last_memorized'] = studentMap['initial_memorized'] ?? '';
          studentMap['last_revision'] = studentMap['initial_revision'] ?? '';
          studentMap['last_date'] = studentMap['join_date'] ?? '';
        }

        studentsList.add(studentMap);
      }

      filteredStudents = List.from(studentsList);
    } catch (e) {
      print("خطأ في قراءة الطلاب: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void filterSearch(String query) {
    List results = [];
    if (query.isEmpty) {
      results = List.from(studentsList);
    } else {
      results = studentsList
          .where(
            (student) =>
                student['name'].toString().toLowerCase().contains(
                  query.toLowerCase(),
                ) ||
                student['circle_name'].toString().toLowerCase().contains(
                  query.toLowerCase(),
                ) ||
                student['last_memorized'].toString().toLowerCase().contains(
                  query.toLowerCase(),
                ) ||
                student['last_revision'].toString().toLowerCase().contains(
                  query.toLowerCase(),
                ),
          )
          .toList();
    }
    setState(() {
      filteredStudents = results;
    });
  }

  // دالة لعرض نافذة أسماء الطلاب وعددهم فقط
  void showStudentsSummary() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("إجمالي عدد الطلاب: ${studentsList.length}"),
          content: SizedBox(
            width: double.maxFinite,
            child: studentsList.isEmpty
                ? const Text("لا يوجد طلاب مسجلين حالياً.")
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: studentsList.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        dense: true,
                        leading: CircleAvatar(
                          backgroundColor: Colors.teal.shade100,
                          child: Text(
                            "${index + 1}",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        title: Text(
                          studentsList[index]['name'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "الحلقة: ${studentsList[index]['circle_name']}",
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إغلاق"),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    readStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("حلقات التحفيظ - متابعة الطلاب"),
        centerTitle: true,
        backgroundColor: Colors.teal.shade300,
        actions: [
          // زر لعرض أسماء الطلاب وعددهم في شريط التنقل العلوي
          IconButton(
            icon: const Icon(Icons.group, size: 28),
            tooltip: "عرض قائمة الأسماء والعدد",
            onPressed: showStudentsSummary,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        onPressed: () async {
          bool? added = await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddStudentPage()),
          );
          if (added == true) {
            readStudents();
          }
        },
        child: const Icon(Icons.add, size: 30),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              onChanged: filterSearch,
              decoration: InputDecoration(
                labelText: "بحث بالاسم، الحفظ، المراجعة، أو الحلقة...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredStudents.isEmpty
                  ? const Center(child: Text("لا توجد نتائج مطابقة"))
                  : ListView.builder(
                      itemCount: filteredStudents.length,
                      itemBuilder: (context, i) {
                        return Card(
                          elevation: 4,
                          color: Colors.teal.shade50,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "الطالب: ${filteredStudents[i]['name']}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.blue,
                                          ),
                                          onPressed: () async {
                                            await Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) => UpdateStudentPage(
                                                  id: filteredStudents[i]['id'],
                                                  name:
                                                      filteredStudents[i]['name'],
                                                  age:
                                                      filteredStudents[i]['age'],
                                                  circleName:
                                                      filteredStudents[i]['circle_name'],
                                                ),
                                              ),
                                            );
                                            readStudents();
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () async {
                                            await sqlDb.deleteData(
                                              "DELETE FROM Students WHERE id = ${filteredStudents[i]['id']}",
                                            );
                                            readStudents();
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Text(
                                  "العمر: ${filteredStudents[i]['age']} | الحلقة: ${filteredStudents[i]['circle_name']}",
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "آخر حفظ: ${filteredStudents[i]['last_memorized']}",
                                ),
                                Text(
                                  "آخر مراجعة: ${filteredStudents[i]['last_revision']}",
                                ),
                                const Divider(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.amber.shade700,
                                      ),
                                      onPressed: () async {
                                        bool?
                                        recorded = await Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AddDailyRecordPage(
                                                  studentId:
                                                      filteredStudents[i]['id'],
                                                  studentName:
                                                      filteredStudents[i]['name'],
                                                ),
                                          ),
                                        );
                                        if (recorded == true) {
                                          readStudents();
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.add_task,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      label: const Text(
                                        "تسجيل يومي",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.teal,
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                StudentHistoryPage(
                                                  student: filteredStudents[i],
                                                ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.history,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      label: const Text(
                                        "السجل الكامل",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
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
