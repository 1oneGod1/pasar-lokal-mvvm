import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../../../core/models/payment_method.dart';
import '../../../core/repositories/payment_method_repository.dart';

class PaymentMethodsViewModel extends ChangeNotifier {
  PaymentMethodsViewModel(this._repository);

  final PaymentMethodRepository _repository;

  UnmodifiableListView<PaymentMethod> get methods => _repository.methods;

  void addMethod(PaymentMethod method) {
    _repository.add(method);
    notifyListeners();
  }

  void updateMethod(PaymentMethod method) {
    _repository.update(method);
    notifyListeners();
  }

  void deleteMethod(String id) {
    _repository.delete(id);
    notifyListeners();
  }

  void setDefault(String id) {
    _repository.setDefault(id);
    notifyListeners();
  }
}
