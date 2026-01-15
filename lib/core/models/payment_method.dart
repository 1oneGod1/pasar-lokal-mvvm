enum PaymentMethodType { bank, ewallet, card }

class PaymentMethod {
  const PaymentMethod({
    required this.id,
    required this.type,
    required this.label,
    required this.accountName,
    required this.accountNumber,
    this.isDefault = false,
  });

  final String id;
  final PaymentMethodType type;
  final String label;
  final String accountName;
  final String accountNumber;
  final bool isDefault;

  PaymentMethod copyWith({
    String? id,
    PaymentMethodType? type,
    String? label,
    String? accountName,
    String? accountNumber,
    bool? isDefault,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      type: type ?? this.type,
      label: label ?? this.label,
      accountName: accountName ?? this.accountName,
      accountNumber: accountNumber ?? this.accountNumber,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  String get maskedNumber {
    final raw = accountNumber.trim();
    if (raw.length <= 4) {
      return raw;
    }
    return '•••• ${raw.substring(raw.length - 4)}';
  }
}

extension PaymentMethodTypeLabel on PaymentMethodType {
  String get label {
    return switch (this) {
      PaymentMethodType.bank => 'Bank',
      PaymentMethodType.ewallet => 'E-Wallet',
      PaymentMethodType.card => 'Kartu',
    };
  }
}
