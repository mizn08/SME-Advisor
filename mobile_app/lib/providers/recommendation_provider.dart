import 'package:flutter/foundation.dart';

import '../models/prediction.dart';

class RecommendationProvider extends ChangeNotifier {
  PredictionResult? lastResult;
  double? lastPurchaseAmount;
  String? lastPurchaseCategory;

  void setResult(
    PredictionResult? r, {
    double? purchaseAmount,
    String? purchaseCategory,
  }) {
    lastResult = r;
    if (purchaseAmount != null) lastPurchaseAmount = purchaseAmount;
    if (purchaseCategory != null) lastPurchaseCategory = purchaseCategory;
    notifyListeners();
  }
}
