import 'package:equatable/equatable.dart';

class Operator extends Equatable {
  final String id;
  final String name;
  final String email;
  final String badge;
  final String unit;
  final String avatarInitials;

  const Operator({
    required this.id,
    required this.name,
    required this.email,
    required this.badge,
    required this.unit,
    required this.avatarInitials,
  });

  @override
  List<Object?> get props => [id, email];
}
