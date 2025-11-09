import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:dyip/features/authentication/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.uid,
    super.phoneNumber,
    super.displayName,
  });

  factory UserModel.fromFirebaseUser(firebase_auth.User firebaseUser) {
    return UserModel(
      uid: firebaseUser.uid,
      phoneNumber: firebaseUser.phoneNumber,
      displayName: firebaseUser.displayName,
    );
  }

  User toEntity() {
    return User(
      uid: uid,
      phoneNumber: phoneNumber,
      displayName: displayName,
    );
  }
}
