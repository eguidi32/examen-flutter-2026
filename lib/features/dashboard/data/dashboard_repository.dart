import '../../../core/constants/api_constants.dart';
import '../../../core/models/wallet_transaction.dart';
import '../../../core/network/api_client.dart';
import 'wallet_balance.dart';

abstract class DashboardRepository {
  Future<WalletBalance> fetchBalance(String phoneNumber);

  Future<List<WalletTransaction>> fetchRecentTransactions(String phoneNumber);
}

class ApiDashboardRepository implements DashboardRepository {
  ApiDashboardRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  @override
  Future<WalletBalance> fetchBalance(String phoneNumber) async {
    final response = await _apiClient.get(
      '${ApiConstants.walletsPath}/$phoneNumber/balance',
    );

    return WalletBalance.fromJson(Map<String, dynamic>.from(response as Map));
  }

  @override
  Future<List<WalletTransaction>> fetchRecentTransactions(
    String phoneNumber,
  ) async {
    final response = await _apiClient.get(
      '${ApiConstants.walletsPath}/$phoneNumber/transactions',
    );
    final items = List<Map<String, dynamic>>.from(response as List);

    return items.map(WalletTransaction.fromJson).take(5).toList();
  }
}
