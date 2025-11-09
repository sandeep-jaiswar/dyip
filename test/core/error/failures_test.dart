import 'package:flutter_test/flutter_test.dart';
import 'package:dyip/core/error/failures.dart';

void main() {
  group('Failure', () {
    test('ServerFailure should be a Failure', () {
      expect(ServerFailure(), isA<Failure>());
    });

    test('NetworkFailure should be a Failure', () {
      expect(NetworkFailure(), isA<Failure>());
    });

    test('InvalidPhoneNumberFailure should be a Failure', () {
      expect(InvalidPhoneNumberFailure(), isA<Failure>());
    });

    test('InvalidOtpFailure should be a Failure', () {
      expect(InvalidOtpFailure(), isA<Failure>());
    });

    test('UserNotFoundFailure should be a Failure', () {
      expect(UserNotFoundFailure(), isA<Failure>());
    });

    test('SessionExpiredFailure should be a Failure', () {
      expect(SessionExpiredFailure(), isA<Failure>());
    });

    test('TooManyRequestsFailure should be a Failure', () {
      expect(TooManyRequestsFailure(), isA<Failure>());
    });

    test('UnknownAuthFailure should contain message', () {
      const testMessage = 'Test error message';
      const failure = UnknownAuthFailure(testMessage);

      expect(failure, isA<Failure>());
      expect(failure.message, testMessage);
      expect(failure.props, [testMessage]);
    });

    test('Failures should support equality', () {
      expect(ServerFailure(), equals(ServerFailure()));
      expect(NetworkFailure(), equals(NetworkFailure()));
      expect(InvalidPhoneNumberFailure(), equals(InvalidPhoneNumberFailure()));
      expect(InvalidOtpFailure(), equals(InvalidOtpFailure()));
    });

    test('UnknownAuthFailure with same message should be equal', () {
      const message = 'Test message';
      const failure1 = UnknownAuthFailure(message);
      const failure2 = UnknownAuthFailure(message);

      expect(failure1, equals(failure2));
    });

    test('UnknownAuthFailure with different messages should not be equal',
        () {
      const failure1 = UnknownAuthFailure('Message 1');
      const failure2 = UnknownAuthFailure('Message 2');

      expect(failure1, isNot(equals(failure2)));
    });

    test('Different failure types should not be equal', () {
      expect(ServerFailure(), isNot(equals(NetworkFailure())));
      expect(
          InvalidPhoneNumberFailure(), isNot(equals(InvalidOtpFailure())));
    });
  });
}
