class PaymentInvoice {
  const PaymentInvoice({
    required this.paymentId,
    required this.invoiceId,
    required this.externalId,
    required this.amount,
    required this.status,
    required this.invoiceUrl,
  });

  final String paymentId;
  final String invoiceId;
  final String externalId;
  final int amount;
  final String status;
  final String invoiceUrl;

  factory PaymentInvoice.fromJson(Map<String, dynamic> json) {
    return PaymentInvoice(
      paymentId: (json['payment_id'] as String?) ?? '',
      invoiceId: (json['invoice_id'] as String?) ?? '',
      externalId: (json['external_id'] as String?) ?? '',
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      status: (json['status'] as String?) ?? '',
      invoiceUrl: (json['invoice_url'] as String?) ?? '',
    );
  }

  bool get isValid => paymentId.isNotEmpty && invoiceId.isNotEmpty;
}
