import 'package:dio/dio.dart';

import '../models/dashboard.dart';
import '../models/gov_aid.dart';
import '../models/prediction.dart';
import '../utils/constants.dart';

class ApiService {
  ApiService() : _dio = Dio(BaseOptions(baseUrl: resolveApiBase(), connectTimeout: const Duration(seconds: 20)));

  final Dio _dio;

  Future<DashboardData> fetchDashboard(int smeId) async {
    final res = await _dio.get('/sme/$smeId/dashboard');
    return DashboardData.fromJson(res.data as Map<String, dynamic>);
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
    return PredictionResult.fromJson(res.data!);
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
}
