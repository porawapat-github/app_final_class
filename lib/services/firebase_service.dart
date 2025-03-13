import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final CollectionReference bookings =
      FirebaseFirestore.instance.collection('BookingTickets');

  Future<void> addBooking(String movie, int cinema, int seat) {
    return bookings.add({
      'Movie_Title': movie,
      'Cinema_Code': cinema,
      'Seat_Number': seat,
    });
  }

  Future<void> updateBooking(String docId, String movie, int cinema, int seat) {
    return bookings.doc(docId).update({
      'Movie_Title': movie,
      'Cinema_Code': cinema,
      'Seat_Number': seat,
    });
  }

  Future<void> deleteBooking(String docId) {
    return bookings.doc(docId).delete();
  }

  Stream<QuerySnapshot> getBookings() {
    return bookings.snapshots();
  }
}
