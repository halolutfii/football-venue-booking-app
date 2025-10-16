import 'dart:io';

import 'package:flutter/material.dart';
import 'package:football_venue_booking_app/models/field_model.dart';
import 'package:football_venue_booking_app/services/field_service.dart';
import 'package:football_venue_booking_app/services/schedule_service.dart';
import 'package:football_venue_booking_app/utils/currency_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class FieldProvider extends ChangeNotifier {
  final FieldService _service = FieldService();
  final ScheduleService _scheduleService = ScheduleService();
  final ImagePicker _picker = ImagePicker();

  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final specController = TextEditingController();
  final slotDurationController = TextEditingController();

  List<FieldModel> _fields = [];
  FieldModel? _field;
  String? _errorMessage;
  bool _isLoading = false;
  TimeOfDay? openingTime;
  TimeOfDay? closingTime;
  String? openingTimeStr;
  String? closingTimeStr;
  File? photo;
  Map<String, List<Map<String, dynamic>>> _allSchedules = {};
  DateTime? _selectedDate;
  int? _selectedSlotIndex;

  List<FieldModel> get fields => _fields;
  FieldModel? get field => _field;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  Map<String, List<Map<String, dynamic>>> get allSchedules => _allSchedules;
  DateTime? get selectedDate => _selectedDate;
  int? get selectedSlotIndex => _selectedSlotIndex;

  List<DateTime> get availableDates {
    final keys = _allSchedules.keys.toList()..sort((a, b) => a.compareTo(b));

    return keys.map((k) => DateTime.parse(k)).toList();
  }

  List<Map<String, dynamic>> get selectedDaySlots {
    if (_selectedDate == null) return [];
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);

    return _allSchedules[dateStr] ?? [];
  }

  Future<void> loadAllFields() async {
    _errorMessage = null;
    _isLoading = true;

    notifyListeners();
    try {
      _fields = await _service.getAllFields();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  Future<void> loadFields(venueId) async {
    _errorMessage = null;
    _isLoading = true;

    notifyListeners();
    try {
      _fields = await _service.getFields(venueId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  Future<void> loadFieldById(String fieldId) async {
    _errorMessage = null;
    _isLoading = true;

    notifyListeners();
    try {
      _field = await _service.getFieldById(fieldId);

      if (_field != null) {
        nameController.text = _field!.name;
        priceController.text = CurrencyUtil.format(_field!.defaultPrice);
        specController.text = _field!.specifications;
        slotDurationController.text = _field!.slotDurationStr;
        openingTime = _field!.openingTime;
        closingTime = _field!.closingTime;

        notifyListeners();
      } else {
        throw "Field is not found";
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  Future<void> addField(String venueId) async {
    _errorMessage = null;

    notifyListeners();
    try {
      final FieldModel field = FieldModel(
        venueId: venueId,
        name: nameController.text.trim(),
        defaultPrice: CurrencyUtil.parse(priceController.text),
        specifications: specController.text.trim(),
        openingTime: openingTime!,
        closingTime: closingTime!,
        slotDuration: int.parse(slotDurationController.text),
      );

      await _service.createField(field, photo!);
      _fields.add(field);

      resetForm();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  Future<void> editField(String fieldId, String venueId) async {
    _errorMessage = null;
    _isLoading = true;

    notifyListeners();
    try {
      final FieldModel field = FieldModel(
        fieldId: fieldId,
        venueId: venueId,
        name: nameController.text.trim(),
        defaultPrice: CurrencyUtil.parse(priceController.text),
        specifications: specController.text.trim(),
        openingTime: openingTime!,
        closingTime: closingTime!,
        slotDuration: int.parse(slotDurationController.text),
      );

      await _service.updateField(field, photo!);

      resetForm();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  Future<void> removeField(String fieldId) async {
    _errorMessage = null;
    _isLoading = true;

    notifyListeners();
    try {
      await _service.deleteField(fieldId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  Future<void> pickTime(BuildContext context, bool isOpening) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isOpening
          ? (openingTime ?? const TimeOfDay(hour: 8, minute: 0))
          : (closingTime ?? const TimeOfDay(hour: 18, minute: 0)),
    );
    if (picked != null) {
      if (isOpening) {
        openingTime = picked;
      } else {
        closingTime = picked;
      }

      notifyListeners();
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      photo = File(pickedFile.path);
    }
  }

  void resetForm() {
    nameController.clear();
    priceController.clear();
    specController.clear();
    slotDurationController.clear();

    openingTime = null;
    closingTime = null;
    photo = null;
    _field = null;

    notifyListeners();
  }

  void generateSchedule(fieldId) async {
    _isLoading = true;

    try {
      final now = DateTime.now();

      final schedules = await _scheduleService.generateSchedule(
        fieldId: fieldId,
        currentDate: now,
        endDate: now.add(const Duration(days: 30)),
      );

      // print("method: $schedules");
      _allSchedules = schedules;

      _selectedDate = now;
      notifyListeners();

      // schedules.forEach((date, slots) {
      //   print('Date: $date');
      //   for (var slot in slots) {
      //     print(
      //       '${slot['start_time']} - ${slot['end_time']} | Rp${slot['price']} | ${slot['status']}',
      //     );
      //   }
      // });

      // print("Total hari digenerate: ${schedules.length}");
      // print("Jadwal: ${schedules.keys}");
      // print("Jadwal hari pertama: ${schedules.keys.first}");
      // print("Jadwal hari terakhir: ${schedules.keys.last}");
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    _selectedSlotIndex = null;

    notifyListeners();
  }

  void selectSlot(int index) {
    if (_selectedSlotIndex == index) {
      _selectedSlotIndex = null;
    } else {
      _selectedSlotIndex = index;
    }

    notifyListeners();
  }
}
