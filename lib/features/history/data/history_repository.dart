import '../../../core/constants/api_constants.dart';
import '../../../core/models/wallet_transaction.dart';
import '../../../core/network/api_client.dart';
import '../../dashboard/data/mock_dashboard_data.dart';

abstract class HistoryRepository {
  Future<List<WalletTransaction>> fetchTransactions(String phoneNumber);
}

class ApiHistoryRepository implements HistoryRepository {
  ApiHistoryRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  @override
  Future<List<WalletTransaction>> fetchTransactions(String phoneNumber) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.walletsPath}/$phoneNumber/transactions',
      );
      final items = List<Map<String, dynamic>>.from(response as List);

      return items.map(WalletTransaction.fromJson).toList();
    } on ApiException {
      return MockDashboardData.transactions(phoneNumber);
    }
  }
}
