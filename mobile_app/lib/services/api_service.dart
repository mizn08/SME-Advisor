import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../models/chat_message.dart';
import 'cache_service.dart';
import '../models/dashboard.dart';
import '../models/gov_aid.dart';
import '../models/prediction.dart';
import '../utils/constants.dart';

class ApiService {
  ApiService() : _dio = Dio(BaseOptions(baseUrl: resolveApiBase(), connectTimeout: const Duration(seconds: 20)));

  final Dio _dio;

  Future<DashboardData> fetchDashboard(int smeId, {bool useCacheOnFail = true}) async {
    try {
      final res = await _dio.get('/sme/$smeId/dashboard');
      final map = res.data as Map<String, dynamic>;
      await CacheService.saveDashboard(smeId, map);
      return DashboardData.fromJson(map);
    } catch (_) {
      if (!useCacheOnFail) rethrow;
      final cached = await CacheService.loadDashboard(smeId);
      if (cached != null) return DashboardData.fromJson(cached);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> compareFinancing({
    required int smeId,
    required double purchaseAmount,
    required String purchaseCategory,
    bool includeSst = false,
    bool islamicOnly = false,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/compare',
      data: {
        'sme_id': smeId,
        'purchase_amount': purchaseAmount,
        'purchase_category': purchaseCategory,
        'include_sst': includeSst,
        'islamic_only': islamicOnly,
      },
    );
    return res.data ?? {};
  }

  Future<Map<String, dynamic>> fetchSectorPlaybooks() async {
    final res = await _dio.get<Map<String, dynamic>>('/sector-playbooks');
    return res.data ?? {};
  }

  Future<PredictionResult> predict({
    required int smeId,
    required double purchaseAmount,
    required String purchaseCategory,
    String? selectedBnplPlan,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/predict',
      data: {
        'sme_id': smeId,
        'purchase_amount': purchaseAmount,
        'purchase_category': purchaseCategory,
        'selected_bnpl_plan': selectedBnplPlan,
      },
    );
    final data = res.data;
    if (data == null) {
      throw DioException(
        requestOptions: res.requestOptions,
        message: 'Empty response from /predict',
      );
    }
    return PredictionResult.fromJson(data);
  }

  Future<List<GovAid>> fetchGovAid() async {
    final res = await _dio.get<List<dynamic>>('/gov-aid');
    return (res.data ?? []).map((e) => GovAid.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<PredictionHistoryItem>> fetchHistory(int smeId) async {
    final res = await _dio.get<List<dynamic>>('/sme/$smeId/predictions');
    return (res.data ?? []).map((e) => PredictionHistoryItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Map<String, dynamic>> fetchPredictionDetail(int id) async {
    final res = await _dio.get<Map<String, dynamic>>('/predictions/$id');
    return res.data ?? {};
  }

  Future<Map<String, dynamic>> fetchModelMetrics() async {
    final res = await _dio.get<Map<String, dynamic>>('/model-metrics');
    return res.data ?? {};
  }

  Future<ChatResponse> chat({required int smeId, required String message}) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/chat',
      data: {'sme_id': smeId, 'message': message},
    );
    return ChatResponse.fromJson(res.data ?? {});
  }

  Future<Map<String, dynamic>> fetchInsights(int smeId) async {
    final res = await _dio.get<Map<String, dynamic>>('/sme/$smeId/insights');
    return res.data ?? {};
  }

  Future<Map<String, dynamic>> fetchBanditStats() async {
    final res = await _dio.get<Map<String, dynamic>>('/bandit/stats');
    return res.data ?? {};
  }

  Future<void> banditFeedback({
    required int smeId,
    required String arm,
    required bool accepted,
    int? predictionId,
  }) async {
    await _dio.post('/bandit/feedback', data: {
      'sme_id': smeId,
      'arm': arm,
      'accepted': accepted,
      'prediction_id': predictionId,
    });
  }

  Future<Map<String, dynamic>> uploadInvoice({
    required int smeId,
    required List<int> bytes,
    required String fileName,
  }) async {
    final form = FormData.fromMap({
      'sme_id': smeId,
      'file': MultipartFile.fromBytes(bytes, filename: fileName),
    });
    final res = await _dio.post<Map<String, dynamic>>('/upload-invoice', data: form);
    return res.data ?? {};
  }

  Future<AgentAdvice> agentAdvise({
    required int smeId,
    required double purchaseAmount,
    required String purchaseCategory,
    String? goal,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/agent/advise',
      data: {
        'sme_id': smeId,
        'purchase_amount': purchaseAmount,
        'purchase_category': purchaseCategory,
        if (goal != null) 'goal': goal,
      },
    );
    return AgentAdvice.fromJson(res.data ?? {});
  }

  /// Upload CSV from a file path (mobile only — needs dart:io).
  Future<Map<String, dynamic>> uploadCsv({
    required int smeId,
    required String filePath,
    required String fileName,
  }) async {
    final form = FormData.fromMap({
      'sme_id': smeId,
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });
    final res = await _dio.post<Map<String, dynamic>>('/upload-csv', data: form);
    return res.data ?? {};
  }

  /// Upload CSV from raw bytes (works on web).
  Future<Map<String, dynamic>> uploadCsvBytes({
    required int smeId,
    required Uint8List bytes,
    required String fileName,
  }) async {
    final form = FormData.fromMap({
      'sme_id': smeId,
      'file': MultipartFile.fromBytes(bytes, filename: fileName),
    });
    final res = await _dio.post<Map<String, dynamic>>('/upload-csv', data: form);
    return res.data ?? {};
  }
}
