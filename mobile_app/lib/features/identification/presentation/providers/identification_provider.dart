import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers.dart';
import '../../data/datasources/identification_remote_datasource.dart';
import '../../data/repositories/identification_repository_impl.dart';
import '../../domain/entities/identification_grant.dart';
import '../../domain/repositories/identification_repository.dart';

final identificationRemoteDataSourceProvider =
    Provider<IdentificationRemoteDataSource>((ref) {
      return IdentificationRemoteDataSource(
        dio: ref.watch(apiClientProvider).dio,
      );
    });

final identificationRepositoryProvider = Provider<IdentificationRepository>((
  ref,
) {
  return IdentificationRepositoryImpl(
    remoteDataSource: ref.watch(identificationRemoteDataSourceProvider),
  );
});

final pendingIdentificationProvider = StateProvider<IdentificationGrant?>(
  (ref) => null,
);
