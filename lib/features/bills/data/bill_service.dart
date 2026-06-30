enum BillService {
  ism(id: 'ISM', label: 'ISM', isBackendSupported: true),
  woyafal(id: 'WOYAFAL', label: 'WOYAFAL', isBackendSupported: true),
  rapido(id: 'RAPIDO', label: 'RAPIDO', isBackendSupported: false),
  senelec(id: 'SENELEC', label: 'SENELEC', isBackendSupported: false);

  const BillService({
    required this.id,
    required this.label,
    required this.isBackendSupported,
  });

  final String id;
  final String label;
  final bool isBackendSupported;

  String get category {
    return switch (this) {
      BillService.ism => 'Internet',
      BillService.woyafal => 'Eau',
      BillService.rapido => 'Transport',
      BillService.senelec => 'Électricité',
    };
  }

  String get description {
    return switch (this) {
      BillService.ism => 'Internet - Fibre 50 Mbps',
      BillService.woyafal => 'Eau - Abonnement',
      BillService.rapido => 'Transport - Abonnement',
      BillService.senelec => 'Électricité - Basse tension',
    };
  }
}
