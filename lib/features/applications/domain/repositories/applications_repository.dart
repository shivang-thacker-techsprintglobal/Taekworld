import '../entities/application_detail_entity.dart';
import '../entities/application_item_entity.dart';

abstract class ApplicationsRepository {
  Future<({List<ApplicationItemEntity> pending, List<ApplicationItemEntity> history})>
      getApplications(String dojangId);

  Future<ApplicationDetailEntity> getApplicationDetail(String applicationId);
}
