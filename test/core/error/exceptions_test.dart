import 'package:flutter_test/flutter_test.dart';
import 'package:dyip/core/error/exceptions.dart';

void main() {
  group('Exceptions', () {
    test('ServerException should be an Exception', () {
      expect(ServerException(), isA<Exception>());
    });

    test('NetworkException should be an Exception', () {
      expect(NetworkException(), isA<Exception>());
    });

    test('InvalidPhoneNumberException should be an Exception', () {
      expect(InvalidPhoneNumberException(), isA<Exception>());
    });

    test('InvalidOtpException should be an Exception', () {
      expect(InvalidOtpException(), isA<Exception>());
    });

    test('UserNotFoundException should be an Exception', () {
      expect(UserNotFoundException(), isA<Exception>());
    });

    test('SessionExpiredException should be an Exception', () {
      expect(SessionExpiredException(), isA<Exception>());
    });

    test('TooManyRequestsException should be an Exception', () {
      expect(TooManyRequestsException(), isA<Exception>());
    });

    test('UnknownAuthException should contain message', () {
      const testMessage = 'Test exception message';
      final exception = UnknownAuthException(testMessage);

      expect(exception, isA<Exception>());
      expect(exception.message, testMessage);
    });

    test('Exceptions can be thrown and caught', () {
      expect(() => throw ServerException(), throwsA(isA<ServerException>()));
      expect(() => throw NetworkException(), throwsA(isA<NetworkException>()));
      expect(() => throw InvalidPhoneNumberException(),
          throwsA(isA<InvalidPhoneNumberException>()));
      expect(() => throw InvalidOtpException(),
          throwsA(isA<InvalidOtpException>()));
      expect(() => throw UserNotFoundException(),
          throwsA(isA<UserNotFoundException>()));
      expect(() => throw SessionExpiredException(),
          throwsA(isA<SessionExpiredException>()));
      expect(() => throw TooManyRequestsException(),
          throwsA(isA<TooManyRequestsException>()));
    });

    test('UnknownAuthException can be thrown and caught with message', () {
      const testMessage = 'Custom error occurred';

      expect(
        () => throw UnknownAuthException(testMessage),
        throwsA(
          predicate(
              (e) => e is UnknownAuthException && e.message == testMessage),
        ),
      );
    });
  });
}
