class AdminLineaPlanDefinition {
  final String id;
  final String name;
  final String priceLabel;
  final String description;
  final List<String> features;
  final bool highlighted;

  const AdminLineaPlanDefinition({
    required this.id,
    required this.name,
    required this.priceLabel,
    required this.description,
    required this.features,
    this.highlighted = false,
  });
}

const adminLineaPlans = <AdminLineaPlanDefinition>[
  AdminLineaPlanDefinition(
    id: 'piloto',
    name: 'Piloto',
    priceLabel: '\$0 USD / 3 meses',
    description: 'Prueba gratuita para líneas nuevas en Rabbit.',
    features: [
      'Panel admin de línea',
      'Hasta 10 conductores',
    ],
  ),
  AdminLineaPlanDefinition(
    id: 'basico',
    name: 'Básico',
    priceLabel: '\$20 USD / mes',
    description: 'Operación diaria de tu línea con lo esencial.',
    features: [
      'Conductores ilimitados',
      'Mapa GPS en tiempo real',
    ],
  ),
  AdminLineaPlanDefinition(
    id: 'pro',
    name: 'Pro',
    priceLabel: '\$30 USD / mes',
    description: 'Para líneas con mayor volumen de viajes.',
    highlighted: true,
    features: [
      'Reportes de ingresos',
      'Soporte prioritario',
    ],
  ),
];

AdminLineaPlanDefinition adminLineaPlanById(String id) {
  return adminLineaPlans.firstWhere(
    (p) => p.id == id,
    orElse: () => adminLineaPlans.first,
  );
}

String adminLineaStatusLabel(String status) {
  switch (status) {
    case 'morosa':
      return 'Pago pendiente';
    case 'suspendida':
      return 'Suspendida';
    case 'activa':
    default:
      return 'Activa';
  }
}
