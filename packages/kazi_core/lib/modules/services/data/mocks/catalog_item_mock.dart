import 'package:kazi_core/shared/entities/catalog_item.dart';

abstract class CatalogItemMock {
  static final nailServices = [
    const CatalogItem(
      id: 1,
      name: 'Alongamento de Unha',
      userId: 1, // Nail Designer 1
      defaultValue: 150.0,
      discountPercent: 10.0,
      defaultDuration: Duration(hours: 2),
      color: 'FFFF69B4', // Pink
    ),
    const CatalogItem(
      id: 2,
      name: 'Manutenção de Alongamento',
      userId: 1, // Nail Designer 1
      defaultValue: 80.0,
      discountPercent: 5.0,
      defaultDuration: Duration(hours: 1, minutes: 30),
      color: 'FFFF69B4', // Pink
    ),
    const CatalogItem(
      id: 3,
      name: 'Esmaltação em Gel',
      userId: 2, // Nail Designer 2
      defaultValue: 60.0,
      discountPercent: 0.0,
      defaultDuration: Duration(minutes: 45),
      color: 'FFFF1493', // Deep Pink
    ),
    const CatalogItem(
      id: 4,
      name: 'Manicure Tradicional',
      userId: 2, // Nail Designer 2
      defaultValue: 30.0,
      discountPercent: 0.0,
      defaultDuration: Duration(minutes: 30),
      color: 'FFFF1493', // Deep Pink
    ),
  ];

  static final lashServices = [
    const CatalogItem(
      id: 5,
      name: 'Extensão de Cílios',
      userId: 3, // Lash Designer
      defaultValue: 200.0,
      discountPercent: 15.0,
      defaultDuration: Duration(hours: 2, minutes: 30),
      color: 'FF8A2BE2', // Blue Violet
    ),
    const CatalogItem(
      id: 6,
      name: 'Manutenção de Extensão',
      userId: 3, // Lash Designer
      defaultValue: 100.0,
      discountPercent: 10.0,
      defaultDuration: Duration(hours: 1, minutes: 45),
      color: 'FF8A2BE2', // Blue Violet
    ),
    const CatalogItem(
      id: 7,
      name: 'Lash Lifting',
      userId: 3, // Lash Designer
      defaultValue: 120.0,
      discountPercent: 10.0,
      defaultDuration: Duration(hours: 1, minutes: 15),
      color: 'FF9370DB', // Medium Purple
    ),
  ];

  static final estheticianServices = [
    const CatalogItem(
      id: 8,
      name: 'Limpeza de Pele',
      userId: 4, // Esthetician
      defaultValue: 180.0,
      discountPercent: 20.0,
      defaultDuration: Duration(hours: 1, minutes: 30),
      color: 'FF00CED1', // Dark Turquoise
    ),
    const CatalogItem(
      id: 9,
      name: 'Drenagem Linfática',
      userId: 4, // Esthetician
      defaultValue: 150.0,
      discountPercent: 15.0,
      defaultDuration: Duration(hours: 1),
      color: 'FF48D1CC', // Medium Turquoise
    ),
    const CatalogItem(
      id: 10,
      name: 'Massagem Modeladora',
      userId: 4, // Esthetician
      defaultValue: 160.0,
      discountPercent: 15.0,
      defaultDuration: Duration(hours: 1),
      color: 'FF40E0D0', // Turquoise
    ),
  ];

  static final manicureServices = [
    const CatalogItem(
      id: 11,
      name: 'Manicure',
      userId: 5, // Manicure
      defaultValue: 35.0,
      discountPercent: 5.0,
      defaultDuration: Duration(minutes: 40),
      color: 'FFFFC0CB', // Pink
    ),
    const CatalogItem(
      id: 12,
      name: 'Pedicure',
      userId: 5, // Manicure
      defaultValue: 45.0,
      discountPercent: 5.0,
      defaultDuration: Duration(minutes: 50),
      color: 'FFFFB6C1', // Light Pink
    ),
  ];

  static final all = [
    ...nailServices,
    ...lashServices,
    ...estheticianServices,
    ...manicureServices,
  ];
}
