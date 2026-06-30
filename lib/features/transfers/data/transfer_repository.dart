import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import 'transfer_receipt.dart';

abstract class TransferRepository {
  Future<TransferReceipt> transfer({
    required String senderPhone,
    required String receiverPhone,
    required double amount,
  });
}

class ApiTransferRepository implements TransferRepository {
  ApiTransferRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  @override
  Future<TransferReceipt> transfer({
    required String senderPhone,
    required String receiverPhone,
    required double amount,
  }) async {
    final response = await _apiClient.post(
      '${ApiConstants.walletsPath}/transfer',
      body: {
        'senderPhone': senderPhone,
        'receiverPhone': receiverPhone,
        'amount': amount,
      },
    );

    return TransferReceipt.fromJson(
      json: Map<String, dynamic>.from(response as Map),
      senderPhone: senderPhone,
      receiverPhone: receiverPhone,
      amount: amount,
    );
  }
}
