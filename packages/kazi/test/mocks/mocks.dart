import 'package:kazi/features/auth/domain/models/app_user.dart';
import 'package:kazi/features/services/domain/models/catalog_item.dart';
import 'package:kazi/features/services/data/repositories/models/firebase_service_model.dart';

final userMock = AppUser(
  uid: 'abc123',
  name: 'Jooj',
  email: 'test@test.com',
  photoUrl: 'url.com',
);

final catalogItemMock = CatalogItem(
  userId: userMock.uid,
  name: 'test',
  commissionPercent: 50,
  defaultValue: 35,
);

final catalogItemsMock = [
  // One type carries a colour, the rest leave it unset: both paths are exercised
  // wherever these mocks are used.
  catalogItemMock.copyWith(name: 'test1', color: 'FF2F6FEB'),
  catalogItemMock.copyWith(name: 'test2'),
  catalogItemMock.copyWith(name: 'test3'),
  catalogItemMock.copyWith(name: 'test4'),
  catalogItemMock.copyWith(name: 'test5'),
  catalogItemMock.copyWith(name: 'test6'),
];

final serviceMock = FirebaseServiceModel(
  date: DateTime(2022),
  catalogItem: catalogItemMock,
  userId: userMock.uid,
  commissionPercent: catalogItemMock.commissionPercent!,
  value: catalogItemMock.defaultValue!,
  catalogItemId: 'aaa1',
);

final servicesMock = [
  serviceMock.copyWith(date: DateTime(2022, 12)),
  serviceMock.copyWith(date: DateTime(2022, 12, 2)),
  serviceMock.copyWith(date: DateTime(2022, 12, 3)),
  serviceMock.copyWith(date: DateTime(2022, 12, 4)),
  serviceMock.copyWith(date: DateTime(2022, 12, 5)),
  serviceMock.copyWith(date: DateTime(2022, 12, 6)),
];

final catalogItemsWithIdsMock = [
  catalogItemMock.copyWith(id: '1', name: 'test1'),
  catalogItemMock.copyWith(id: '2', name: 'test2'),
  catalogItemMock.copyWith(id: '3', name: 'test3'),
  catalogItemMock.copyWith(id: '4', name: 'test4'),
  catalogItemMock.copyWith(id: '5', name: 'test5'),
  catalogItemMock.copyWith(id: '6', name: 'test6'),
];

final servicesWithTypeIdMock = [
  serviceMock.copyWith(catalogItemId: '1', date: DateTime(2022, 12)),
  serviceMock.copyWith(catalogItemId: '1', date: DateTime(2022, 12, 2)),
  serviceMock.copyWith(catalogItemId: '2', date: DateTime(2022, 12, 3)),
  serviceMock.copyWith(catalogItemId: '3', date: DateTime(2022, 12, 4)),
  serviceMock.copyWith(catalogItemId: '4', date: DateTime(2022, 12, 5)),
  serviceMock.copyWith(catalogItemId: '5', date: DateTime(2022, 12, 6)),
];

final servicesWithTypesMock = [
  serviceMock.copyWith(
    catalogItemId: '1',
    date: DateTime(2022, 12),
    catalogItem: catalogItemMock.copyWith(id: '1', name: 'test1'),
  ),
  serviceMock.copyWith(
    catalogItemId: '1',
    date: DateTime(2022, 12, 2),
    catalogItem: catalogItemMock.copyWith(id: '1', name: 'test1'),
  ),
  serviceMock.copyWith(
    catalogItemId: '2',
    date: DateTime(2022, 12, 3),
    catalogItem: catalogItemMock.copyWith(id: '2', name: 'test2'),
  ),
  serviceMock.copyWith(
    catalogItemId: '3',
    date: DateTime(2022, 12, 4),
    catalogItem: catalogItemMock.copyWith(id: '3', name: 'test3'),
  ),
  serviceMock.copyWith(
    catalogItemId: '4',
    date: DateTime(2022, 12, 5),
    catalogItem: catalogItemMock.copyWith(id: '4', name: 'test4'),
  ),
  serviceMock.copyWith(
    catalogItemId: '5',
    date: DateTime(2022, 12, 6),
    catalogItem: catalogItemMock.copyWith(id: '5', name: 'test5'),
  ),
];
