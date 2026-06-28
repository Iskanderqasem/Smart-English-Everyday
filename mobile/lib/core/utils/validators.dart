import '../constants/strings.dart';

class AppValidators {
  AppValidators._();

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fieldRequired;
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return AppStrings.invalidEmail;
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldRequired;
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? confirmPassword(String? value, String? original) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldRequired;
    }
    if (value != original) {
      return AppStrings.passwordsNotMatch;
    }
    return null;
  }

  static String? username(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fieldRequired;
    }
    if (value.trim().length < 3) {
      return AppStrings.usernameTooShort;
    }
    if (value.trim().length > 30) {
      return AppStrings.usernameTooLong;
    }
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegex.hasMatch(value.trim())) {
      return AppStrings.usernameInvalid;
    }
    return null;
  }

  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null ? '$fieldName is required' : AppStrings.fieldRequired;
    }
    return null;
  }

  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fieldRequired;
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.trim().length > 100) {
      return 'Name must be less than 100 characters';
    }
    return null;
  }

  static String? minLength(String? value, int min, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldRequired;
    }
    if (value.length < min) {
      return '${fieldName ?? 'This field'} must be at least $min characters';
    }
    return null;
  }

  static String? maxLength(String? value, int max, {String? fieldName}) {
    if (value != null && value.length > max) {
      return '${fieldName ?? 'This field'} must be less than $max characters';
    }
    return null;
  }

  static String? wordCount(String? value, {int min = 50, int max = 500}) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fieldRequired;
    }
    final count = value.trim().split(RegExp(r'\s+')).length;
    if (count < min) {
      return 'Please write at least $min words (currently $count)';
    }
    if (count > max) {
      return 'Please keep your writing under $max words (currently $count)';
    }
    return null;
  }
}
