import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ทำให้แน่ใจว่า Flutter ถูก initialize ก่อน Firebase
  await Firebase.initializeApp(); // เริ่มต้นใช้งาน Firebase
  runApp(MyApp()); // เรียกใช้งานแอปพลิเคชัน
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // ปิดแสดงแถบ Debug
      theme: ThemeData(
        primarySwatch: Colors.deepPurple, // กำหนดธีมสีหลักเป็นสีม่วงเข้ม
      ),
      home: BookingScreen(), // หน้าหลักของแอปพลิเคชัน
    );
  }
}

class BookingScreen extends StatefulWidget {
  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  // ตัวควบคุมสำหรับการกรอกข้อมูล
  final TextEditingController movieController = TextEditingController();
  final TextEditingController theaterController = TextEditingController();
  final TextEditingController seatController = TextEditingController();

  String? editingDocId; // เก็บ ID ของเอกสารที่กำลังแก้ไข
  String? originalMovieName; // เก็บชื่อหนังต้นฉบับเมื่อทำการแก้ไข

  // อ้างอิงไปยัง collection 'BookingTickets' ใน Firestore
  final CollectionReference bookings = FirebaseFirestore.instance.collection('BookingTickets');

  // ฟังก์ชันเพิ่มข้อมูลการจอง
  void addBooking() {
    if (movieController.text.isNotEmpty && theaterController.text.isNotEmpty && seatController.text.isNotEmpty) {
      bookings.add({
        'movieName': movieController.text,
        'theaterId': theaterController.text,
        'seatNumber': seatController.text,
      });
      showSnackbar('เพิ่มการจองสำเร็จ!');
      clearFields(); // ล้างข้อมูลที่ป้อน
    } else {
      showSnackbar('กรุณากรอกข้อมูลให้ครบทุกช่อง');
    }
  }

  // ฟังก์ชันอัปเดตข้อมูลการจอง
  void updateBooking() {
    if (editingDocId != null) {
      bookings.doc(editingDocId).update({
        'theaterId': theaterController.text,
        'seatNumber': seatController.text,
      });
      showSnackbar('อัปเดตข้อมูลโรงภาพยนตร์และที่นั่งสำเร็จ!');
      setState(() {
        editingDocId = null;
      });
      clearFields();
    }
  }

  // ฟังก์ชันลบการจอง
  void deleteBooking(String docId) {
    showDeleteDialog(docId); // แสดงกล่องยืนยันก่อนลบ
  }

  // ฟังก์ชันล้างค่าฟอร์ม
  void clearFields() {
    movieController.clear();
    theaterController.clear();
    seatController.clear();
  }

  // ฟังก์ชันแสดง Snackbar แจ้งเตือน
  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // ฟังก์ชันแสดง Dialog ยืนยันการลบข้อมูล
  void showDeleteDialog(String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('ยืนยันการลบ'),
        content: Text('คุณแน่ใจหรือไม่ว่าต้องการลบการจองนี้?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              bookings.doc(docId).delete(); // ลบข้อมูลจาก Firestore
              showSnackbar('ลบการจองสำเร็จ!');
              Navigator.pop(context);
            },
            child: Text('ลบ', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('จองตั๋วภาพยนตร์')),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.pinkAccent.shade200, Colors.orangeAccent.shade200], // สีพื้นหลังแบบไล่สี
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 500), // เพิ่มเอฟเฟกต์ Animation
                curve: Curves.easeInOut,
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 6, // เงาของ Card
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: movieController,
                          decoration: InputDecoration(labelText: 'ชื่อภาพยนตร์', border: OutlineInputBorder()),
                          enabled: editingDocId == null, // ปิดการแก้ไขชื่อภาพยนตร์เมื่ออยู่ในโหมดแก้ไข
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: theaterController,
                          decoration: InputDecoration(labelText: 'รหัสโรงภาพยนตร์', border: OutlineInputBorder()),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: seatController,
                          decoration: InputDecoration(labelText: 'หมายเลขที่นั่ง', border: OutlineInputBorder()),
                        ),
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            if (editingDocId == null)
                              ElevatedButton(
                                onPressed: addBooking, // ปุ่มเพิ่มการจอง
                                child: Text('เพิ่มการจอง'),
                              ),
                            if (editingDocId != null)
                              ElevatedButton(
                                onPressed: updateBooking, // ปุ่มยืนยันการแก้ไข
                                child: Text('ยืนยันการแก้ไข'),
                              ),
                            if (editingDocId != null)
                              OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    editingDocId = null;
                                    clearFields();
                                  });
                                },
                                child: Text('ยกเลิกการแก้ไข', style: TextStyle(color: Colors.deepPurple)),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: StreamBuilder(
                  stream: bookings.snapshots(), // ดึงข้อมูลจาก Firestore แบบเรียลไทม์
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) return Center(child: CircularProgressIndicator()); // โหลดข้อมูล

                    return ListView(
                      children: snapshot.data!.docs.map((doc) {
                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 4,
                          color: Colors.white,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(doc['movieName'], style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                            subtitle: Text('โรง: ${doc['theaterId']}, ที่นั่ง: ${doc['seatNumber']}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    setState(() {
                                      editingDocId = doc.id;
                                      originalMovieName = doc['movieName'];
                                      movieController.text = doc['movieName'];
                                      theaterController.text = doc['theaterId'];
                                      seatController.text = doc['seatNumber'];
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => deleteBooking(doc.id), // ปุ่มลบการจอง
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
