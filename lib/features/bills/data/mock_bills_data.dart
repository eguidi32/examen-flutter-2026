import 'bill.dart';
import 'bill_payment_result.dart';
import 'bill_service.dart';

class MockBillsData {
  const MockBillsData._();

  static List<Bill> currentBills({
    required String walletCode,
    required BillService service,
  }) {
    final now = DateTime.now();
    return switch (service) {
      BillService.ism => [
        _bill(
          id: 101,
          walletCode: walletCode,
          service: service,
          reference: 'ISM-FIBRE-771234567',
          amount: 25000,
          dueDate: now.add(const Duration(days: 5)),
        ),
      ],
      BillService.woyafal => [
        _bill(
          id: 201,
          walletCode: walletCode,
          service: service,
          reference: 'WOYAFAL-77654321',
          amount: 8500,
          dueDate: now.add(const Duration(days: 7)),
        ),
      ],
      BillService.rapido => [
        _bill(
          id: 301,
          walletCode: walletCode,
          service: service,
          reference: 'RAPIDO-772341198',
          amount: 15000,
          dueDate: now.add(const Duration(days: 10)),
        ),
      ],
      BillService.senelec => [
        _bill(
          id: 401,
          walletCode: walletCode,
          service: service,
          reference: 'SENELEC-779876543',
          amount: 32750,
          dueDate: now.add(const Duration(days: 12)),
        ),
      ],
    };
  }

  static BillPaymentResult paymentResult({
    required String phoneNumber,
    required String walletCode,
    required BillService service,
    required List<String> references,
    required double totalAmount,
  }) {
    return BillPaymentResult(
      phoneNumber: phoneNumber,
      walletCode: walletCode,
      serviceName: service.id,
      factureReferences: references,
      totalAmount: totalAmount,
      balance: 0,
      status: 'SUCCESS',
      message: 'Paiement simulé avec succès.',
    );
  }

  static Bill _bill({
    required int id,
    required String walletCode,
    required BillService service,
    required String reference,
    required double amount,
    required DateTime dueDate,
  }) {
    return Bill(
      id: id,
      reference: reference,
      walletCode: walletCode,
      serviceName: service.id,
      amount: amount,
      status: 'UNPAID',
      dueDate: dueDate,
    );
  }
}
