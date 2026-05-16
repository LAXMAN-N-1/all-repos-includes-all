import 'package:flutter_test/flutter_test.dart';
import 'package:ls_flutter_kit/ls_flutter_kit.dart';

void main() {
  group('AppColors', () {
    test('primary color is defined', () {
      expect(AppColors.primary.value, isNonZero);
    });
  });

  group('Validators', () {
    test('required validator works', () {
      final validator = Validators.required();
      expect(validator(''), 'This field is required');
      expect(validator('test'), isNull);
    });

    test('email validator works', () {
      final validator = Validators.email();
      expect(validator('invalid'), 'Enter a valid email');
      expect(validator('test@example.com'), isNull);
    });

    test('compose validators', () {
      final validator = Validators.compose([
        Validators.required(),
        Validators.email(),
      ]);
      expect(validator(''), 'This field is required');
      expect(validator('invalid'), 'Enter a valid email');
      expect(validator('test@example.com'), isNull);
    });

    test('password validator', () {
      final validator = Validators.password(minLength: 8);
      expect(validator('short'), 'At least 8 characters');
      expect(validator('alllowercase1'), 'Include an uppercase letter');
      expect(validator('Validpass1'), isNull);
    });
  });

  group('Extensions', () {
    test('String capitalize', () {
      expect('hello'.capitalize, 'Hello');
      expect(''.capitalize, '');
    });

    test('String initials', () {
      expect('John Doe'.initials, 'JD');
      expect('Alice'.initials, 'A');
    });

    test('Number toCurrency', () {
      expect(1234.56.toCurrency(), '₹1,234.56');
    });

    test('Number toCompact', () {
      expect(1500.toCompact(), '1.5K');
      expect(150000.toCompact(), '1.5L');
      expect(15000000.toCompact(), '1.5Cr');
    });
  });

  group('CacheManager', () {
    test('get/set works', () {
      final cache = CacheManager();
      cache.set('key', 'value');
      expect(cache.get<String>('key'), 'value');
    });

    test('returns null for missing key', () {
      final cache = CacheManager();
      expect(cache.get<String>('missing'), isNull);
    });
  });

  group('ApiException', () {
    test('factory constructors', () {
      expect(ApiException.network().type, ApiExceptionType.network);
      expect(ApiException.unauthorized().statusCode, 401);
      expect(ApiException.unauthorized().isAuth, isTrue);
    });
  });
}
