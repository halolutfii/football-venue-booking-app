import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:football_venue_booking_app/models/field_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FieldService {
  final CollectionReference _fields = FirebaseFirestore.instance.collection(
    'fields',
  );
  final SupabaseClient _supabase = Supabase.instance.client;

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

  Future<void> createField(FieldModel field, File photo) async {
    final docRef = _fields.doc();

    final urlPhoto = await uploadFieldPhoto(docRef.id, field.venueId, photo);

    final newfield = field.copyWith(fieldId: docRef.id, fieldPhoto: urlPhoto);

    await docRef.set(newfield.toJson());
  }

  Future<void> updateField(FieldModel field, File photo) async {
    final urlPhoto = await uploadFieldPhoto(
      field.fieldId!,
      field.venueId,
      photo,
    );

    final newfield = field.copyWith(fieldPhoto: urlPhoto);

    await _fields.doc(field.fieldId).update(newfield.toJson());
  }

  Future<void> deleteField(String fieldId) async {
    await _fields.doc(fieldId).delete();
  }

  Future<String> uploadFieldPhoto(String uid, String venueId, File file) async {
    final fileName = 'public/$uid/${DateTime.now()}-${file.uri.pathSegments.last}';

    await _supabase.storage
        .from('field-photos')
        .upload(fileName, file, fileOptions: const FileOptions(upsert: true));

    return _supabase.storage.from('field-photos').getPublicUrl(fileName);
  }
}
