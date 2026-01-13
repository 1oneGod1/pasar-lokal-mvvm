import '../models/payment_invoice.dart';
import '../network/api_client.dart';

class PaymentRepository {
  PaymentRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<PaymentInvoice> createXenditInvoice({
    required int amount,
    required String externalId,
    String? payerEmail,
    String? description,
  }) async {
    final response = await _apiClient.postJson('/v1/payments/xendit/invoices', {
      'amount': amount,
      'external_id': externalId,
      if (payerEmail != null && payerEmail.trim().isNotEmpty)
        'payer_email': payerEmail.trim(),
      if (description != null && description.trim().isNotEmpty)
        'description': description.trim(),
    });

    return PaymentInvoice.fromJson(response);
  }

  Future<PaymentInvoice> getPaymentByExternalId(String externalId) async {
    final response = await _apiClient.getJson(
      '/v1/payments/external/$externalId',
    );
    return PaymentInvoice.fromJson(response);
  }
}
