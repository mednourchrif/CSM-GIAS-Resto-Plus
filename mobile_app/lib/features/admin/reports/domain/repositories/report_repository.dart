import 'package:mobile_app/shared/models/result.dart';
import '../entities/report_entity.dart';
import '../entities/report_filter.dart';

abstract class ReportRepository {
  Future<Result<Report>> generate(ReportFilter filter);
}
