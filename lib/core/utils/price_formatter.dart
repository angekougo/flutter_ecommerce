import 'package:intl/intl.dart';

final _formatter = NumberFormat.decimalPattern('fr_FR');

/// 45000 -> "45 000 FCFA"
String formatPrice(num amount) => '${_formatter.format(amount)} FCFA';
