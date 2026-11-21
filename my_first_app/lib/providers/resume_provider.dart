import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/resume_model.dart';

class ResumeProvider with ChangeNotifier {
  List<ResumeModel> _resumeList = [];
  final String _prefKey = 'resume_list';

  List<ResumeModel> get resumeList => _resumeList;

  ResumeModel? getById(String id) {
    for (final resume in _resumeList) {
      if (resume.id == id) return resume;
    }
    return null;
  }

  Future<void> loadResumes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_prefKey);

    if (jsonString != null) {
      final List<dynamic> decodedList = jsonDecode(jsonString);
      bool needsMigration = false;
      final baseTimestamp = DateTime.now().microsecondsSinceEpoch;

      _resumeList = List.generate(decodedList.length, (i) {
        final map = decodedList[i] as Map<String, dynamic>;
        final rawId = map['id'] as String?;
        if (rawId == null || rawId.isEmpty) {
          needsMigration = true;
        }
        return ResumeModel.fromJson(map, fallbackId: '${baseTimestamp}_$i');
      });

      if (needsMigration) {
        await _saveToPrefs();
      }
      notifyListeners();
    }
  }

  Future<void> addResume(ResumeModel newResume) async {
    _resumeList.add(newResume);
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> updateResumeById(String id, ResumeModel updatedResume) async {
    final index = _resumeList.indexWhere((r) => r.id == id);
    if (index == -1) return;
    _resumeList[index] = updatedResume;
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> deleteResumeById(String id) async {
    _resumeList.removeWhere((r) => r.id == id);
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(
      _resumeList.map((resume) => resume.toJson()).toList(),
    );
    await prefs.setString(_prefKey, jsonString);
  }
}
