import '../../../qr/domain/entities/qr_code.dart';
import 'employee.dart';

class EmployeeCreation {
  final Employee employee;
  final QrCode qrCode;

  const EmployeeCreation({required this.employee, required this.qrCode});
}
