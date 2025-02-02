class Messages {
  // ข้อความสำหรับการลงทะเบียนสำเร็จ
  static const String registrationSuccess =
      'Your account has been created successfully! Please sign in to continue.';

  // ข้อความสำหรับการตรวจสอบข้อมูลทั่วไป
  static const String emailRequired = 'Please enter your email address';
  static const String invalidEmail = 'Please enter a valid email address';
  static const String usernameRequired = 'Please enter your username';
  static const String phoneNumberRequired = 'Please enter your phone number';
  static const String passwordRequired = 'Please enter your password';
  static const String passwordTooShort =
      'Password must be at least 8 characters long';
  static const String passwordsNotMatch = 'Passwords do not match';
  static const String termsAndConditions = 'Please accept terms and conditions';

  // ข้อความสำหรับการตรวจสอบข้อมูลธุรกิจ
  static const String selectBusinessType = 'Please select your business type';
  static const String businessNameRequired = 'Please enter your business name';
  static const String businessAddressRequired =
      'Please enter your business address';
  static const String taxIdRequired = 'Please enter your tax ID';
  static const String invalidTaxId = 'Tax ID must be 13 digits';

  // ข้อความสำหรับข้อผิดพลาดทั่วไป
  static const String validationError =
      'Please check your information and try again';
  static const String networkError =
      'Cannot connect to server. Please try again later';
}
