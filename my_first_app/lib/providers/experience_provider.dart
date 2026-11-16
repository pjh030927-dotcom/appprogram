import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/experience_model.dart';

class ExperienceProvider with ChangeNotifier {
  List<ExperienceModel> _experienceList = [];
  final String _prefKey = 'experience_list_v2';

  List<ExperienceModel> get experienceList => _experienceList;

  // 특정 카테고리만 필터링해서 가져오기
  List<ExperienceModel> getByCategory(String category) {
    if (category == '전체') return _experienceList;
    return _experienceList.where((e) => e.category == category).toList();
  }

  Future<void> loadExperiences() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_prefKey);

    if (jsonString != null) {
      final List<dynamic> decodedList = jsonDecode(jsonString);
      _experienceList = decodedList
          .map((item) => ExperienceModel.fromJson(item as Map<String, dynamic>))
          .toList();
      notifyListeners();
    }
  }

  Future<void> addExperience(ExperienceModel newExperience) async {
    _experienceList.insert(0, newExperience); // 최신 항목이 위로 오도록 추가
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> deleteExperience(ExperienceModel target) async {
    _experienceList.remove(target);
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(
      _experienceList.map((exp) => exp.toJson()).toList(),
    );
    await prefs.setString(_prefKey, jsonString);
  }
}
