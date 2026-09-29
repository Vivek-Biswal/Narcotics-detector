import 'package:flutter/material.dart';
import '../../../core/enums/app_enums.dart';
import '../../../models/test_record.dart';
import '../../../repositories/test_repository.dart';

class HistoryController extends ChangeNotifier {
  final TestRepository testRepository;

  HistoryController({required this.testRepository});

  List<TestRecord> _records = [];
  bool _isLoading = false;
  String? _error;

  // Filters
  String _searchQuery = '';
  TestResult? _resultFilter;

  List<TestRecord> get records => _records;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  TestResult? get resultFilter => _resultFilter;

  Future<void> loadRecords() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _records = await testRepository.search(
        query: _searchQuery,
        resultFilter: _resultFilter,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    loadRecords();
  }

  void setResultFilter(TestResult? filter) {
    _resultFilter = filter;
    loadRecords();
  }
}
