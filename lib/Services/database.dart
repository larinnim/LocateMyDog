import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String uid;
  DatabaseService({this.uid});

  // collection reference
  final CollectionReference locateCollection =
      FirebaseFirestore.instance.collection('locateDog');

  Future<void> updateUserData(
      String dogname, String ownername, String breed) async {
    return await locateCollection
        .doc(uid)
        .set({'dogname': dogname, 'ownername': ownername, 'breed': breed});
  }
}
