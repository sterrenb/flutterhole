import 'package:equatable/equatable.dart';

class BlockedDomain extends Equatable {
  final String entry;
  final int total;

  BlockedDomain(this.entry, this.total);
}
