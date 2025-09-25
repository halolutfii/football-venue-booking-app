import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:football_venue_booking_app/models/field_model.dart';

class FieldService {
  final CollectionReference _fields = FirebaseFirestore.instance.collection(
    'fields',
  );

  Future<FieldModel?> getFieldById(String fieldId) async {
    final doc = await _fields.doc(fieldId).get();

    return FieldModel.fromMap(doc.data() as Map<String, dynamic>);
  }

  Future<List<FieldModel>> getFields(String venueId) async {
    final snapshot = await _fields.where("venue_id", isEqualTo: venueId).get();

    return snapshot.docs
        .map((doc) => FieldModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> createField(FieldModel field) async {
    final docRef = _fields.doc();
    final newfield = field.copyWith(fieldId: docRef.id);

    await docRef.set(newfield.toJson());
  }

  Future<void> updateField(FieldModel field) async {
    await _fields.doc(field.fieldId).update(field.toJson());
  }

  Future<void> deleteField(String fieldId) async {
    await _fields.doc(fieldId).delete();
  }
}
