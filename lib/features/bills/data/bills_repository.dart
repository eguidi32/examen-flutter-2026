import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import 'bill.dart';
import 'bill_payment_result.dart';
import 'bill_service.dart';

abstract class BillsRepository {
  Future<List<Bill>> fetchCurrentBills({
    required String walletCode,
    required BillService service,
  });

  Future<BillPaymentResult> payBills({
    required String phoneNumber,
    required BillService service,
    required List<String> references,
  });
}

class ApiBillsRepository implements BillsRepository {
  ApiBillsRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  @override
  Future<List<Bill>> fetchCurrentBills({
    required String walletCode,
    required BillService service,
  }) async {
    if (!service.isBackendSupported) {
      return const [];
    }

    final response = await _apiClient.get(
      '${ApiConstants.externalFacturesPath}/$walletCode/current',
      queryParameters: {'unite': service.id},
    );
    final items = List<Map<String, dynamic>>.from(response as List);

    return items.map(Bill.fromJson).toList();
  }

  @override
  Future<BillPaymentResult> payBills({
    required String phoneNumber,
    required BillService service,
    required List<String> references,
  }) async {
    final response = await _apiClient.post(
      '${ApiConstants.walletsPath}/pay-factures',
      body: {
        'phoneNumber': phoneNumber,
        'serviceName': service.id,
        'factureReferences': references,
      },
    );

    return BillPaymentResult.fromJson(
      Map<String, dynamic>.from(response as Map),
    );
  }
}
