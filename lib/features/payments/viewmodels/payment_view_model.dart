import 'package:flutter/foundation.dart';

import '../../../core/models/payment_invoice.dart';
import '../../../core/repositories/payment_repository.dart';

class PaymentViewModel extends ChangeNotifier {
  PaymentViewModel(this._repository);

  final PaymentRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<PaymentInvoice?> createInvoice({
    required int amount,
    required String externalId,
    String? payerEmail,
    String? description,
  }) async {
    if (_isLoading) return null;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final invoice = await _repository.createXenditInvoice(
        amount: amount,
        externalId: externalId,
        payerEmail: payerEmail,
        description: description,
      );
      _isLoading = false;
      notifyListeners();
      return invoice;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<PaymentInvoice?> refreshByExternalId(String externalId) async {
    if (_isLoading) return null;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final invoice = await _repository.getPaymentByExternalId(externalId);
      _isLoading = false;
      notifyListeners();
      return invoice;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }
}
