import '../services/mock/mock_record_service.dart';
import '../models/test_record.dart';
import '../core/enums/app_enums.dart';

/// Test repository — abstraction over record service for UI controllers.
/// TODO: Add caching, pagination, and offline-first sync logic here.
class TestRepository {
  final MockRecordService recordService;

  TestRepository({required this.recordService});

  Future<List<TestRecord>> getAll() => recordService.getAllRecords();

  Future<TestRecord?> getById(String id) => recordService.getRecord(id);

  Future<TestRecord> save(TestRecord record) => recordService.saveRecord(record);

  Future<void> delete(String id) => recordService.deleteRecord(id);

  /// Get summary statistics for dashboard.
  Future<Map<String, int>> getSummaryStats() async {
    final records = await getAll();
    return {
      'total': records.length,
      'positive': records.where((r) => r.result == TestResult.positive).length,
      'negative': records.where((r) => r.result == TestResult.negative).length,
      'inconclusive': records.where((r) => r.result == TestResult.inconclusive).length,
    };
  }

  /// Filter and search records.
  Future<List<TestRecord>> search({
    String? query,
    TestResult? resultFilter,
    String? operatorFilter,
    VerificationStatus? statusFilter,
    bool newestFirst = true,
  }) async {
    var records = await getAll();

    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      records = records
          .where((r) =>
              r.testId.toLowerCase().contains(q) ||
              r.operatorId.toLowerCase().contains(q))
          .toList();
    }

    if (resultFilter != null) {
      records = records.where((r) => r.result == resultFilter).toList();
    }

    if (operatorFilter != null && operatorFilter.isNotEmpty) {
      records = records
          .where((r) =>
              r.operatorId.toLowerCase() == operatorFilter.toLowerCase())
          .toList();
    }

    if (statusFilter != null) {
      records =
          records.where((r) => r.verificationStatus == statusFilter).toList();
    }

    records.sort((a, b) => newestFirst
        ? b.timestamp.compareTo(a.timestamp)
        : a.timestamp.compareTo(b.timestamp));

    return records;
  }
}
