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
}
