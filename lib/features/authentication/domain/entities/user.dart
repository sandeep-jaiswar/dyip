import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String uid;
  final String? phoneNumber;
  final String? displayName;

  const User({required this.uid, this.phoneNumber, this.displayName});

  @override
  List<Object?> get props => [uid, phoneNumber, displayName];
}
