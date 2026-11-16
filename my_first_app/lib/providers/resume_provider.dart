import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/resume_model.dart';

class ResumeProvider with ChangeNotifier {
  List<ResumeModel> _resumeList = [];
  final String _prefKey = 'resume_list';

  List<ResumeModel> get resumeList => _resumeList;

  // 앱 시작 시 SharedPreferences에서 데이터 불러오기
  Future<void> loadResumes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_prefKey);

    if (jsonString != null) {
      final List<dynamic> decodedList = jsonDecode(jsonString);
      _resumeList = decodedList
          .map((item) => ResumeModel.fromJson(item as Map<String, dynamic>))
          .toList();
      notifyListeners(); // 화면 갱신
    }
  }

  // 새 자소서 추가 및 저장
  Future<void> addResume(ResumeModel newResume) async {
    _resumeList.add(newResume);
    await _saveToPrefs();
    notifyListeners(); // 화면 갱신
  }

  // 자소서 삭제
  Future<void> deleteResume(int index) async {
    _resumeList.removeAt(index);
    await _saveToPrefs();
    notifyListeners(); // 화면 갱신
  }

  // SharedPreferences에 데이터 저장하기
  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(
      _resumeList.map((resume) => resume.toJson()).toList(),
    );
    await prefs.setString(_prefKey, jsonString);
  }
}
