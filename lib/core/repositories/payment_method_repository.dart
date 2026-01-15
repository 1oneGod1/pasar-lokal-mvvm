import 'dart:collection';

import '../models/payment_method.dart';
import '../storage/local_store.dart';
import '../storage/storage_mappers.dart';

class PaymentMethodRepository {
  PaymentMethodRepository({LocalStore? store}) : _store = store {
    _restore();
  }

  static const _storageKey = 'payment.methods.v1';

  final LocalStore? _store;
  final List<PaymentMethod> _methods = [];

  UnmodifiableListView<PaymentMethod> get methods =>
      UnmodifiableListView(_methods);

  void _restore() {
    final store = _store;
    if (store == null) {
      _seedIfEmpty();
      return;
    }

    final raw = store.read<dynamic>(_storageKey);
    if (raw is List) {
      _methods
        ..clear()
        ..addAll(
          raw.whereType<Map<dynamic, dynamic>>().map(paymentMethodFromMap),
        );
    }

    _seedIfEmpty();
  }

  Future<void> _persist() async {
    final store = _store;
    if (store == null) {
      return;
    }
    final payload = _methods.map(paymentMethodToMap).toList(growable: false);
    await store.write(_storageKey, payload);
  }

  void _seedIfEmpty() {
    if (_methods.isNotEmpty) {
      _ensureDefault();
      return;
    }

    _methods.addAll([
      const PaymentMethod(
        id: 'pm-bank-bca',
        type: PaymentMethodType.bank,
        label: 'BCA',
        accountName: 'Andi Purba',
        accountNumber: '1234567890',
        isDefault: true,
      ),
      const PaymentMethod(
        id: 'pm-ewallet-gopay',
        type: PaymentMethodType.ewallet,
        label: 'GoPay',
        accountName: 'Andi Purba',
        accountNumber: '081234567890',
      ),
    ]);
    _persist();
  }

  void add(PaymentMethod method) {
    final index = _methods.indexWhere((item) => item.id == method.id);
    if (index == -1) {
      _methods.add(method);
    } else {
      _methods[index] = method;
    }

    if (method.isDefault) {
      _applyDefault(method.id);
    } else {
      _ensureDefault();
    }

    _persist();
  }

  void update(PaymentMethod method) {
    final index = _methods.indexWhere((item) => item.id == method.id);
    if (index == -1) {
      add(method);
      return;
    }

    _methods[index] = method;
    if (method.isDefault) {
      _applyDefault(method.id);
    } else {
      _ensureDefault();
    }

    _persist();
  }

  void delete(String id) {
    _methods.removeWhere((item) => item.id == id);
    _ensureDefault();
    _persist();
  }

  void setDefault(String id) {
    _applyDefault(id);
    _persist();
  }

  void _applyDefault(String id) {
    for (var i = 0; i < _methods.length; i += 1) {
      final item = _methods[i];
      _methods[i] = item.copyWith(isDefault: item.id == id);
    }
  }

  void _ensureDefault() {
    if (_methods.isEmpty) {
      return;
    }

    final hasDefault = _methods.any((item) => item.isDefault);
    if (!hasDefault) {
      _methods[0] = _methods[0].copyWith(isDefault: true);
    }
  }
}
