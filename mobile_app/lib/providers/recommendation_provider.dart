import 'package:flutter/foundation.dart';

import '../models/prediction.dart';

class RecommendationProvider extends ChangeNotifier {
  PredictionResult? lastResult;

  void setResult(PredictionResult? r) {
    lastResult = r;
    notifyListeners();
  }
}
