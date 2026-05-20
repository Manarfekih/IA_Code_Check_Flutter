class AppValidators {
  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,}$');
    if (!emailRegex.hasMatch(email.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateUsername(String? username) {
    if (username == null || username.trim().isEmpty) {
      return 'Username is required';
    }

    if (username.trim().length < 3) {
      return 'Username must be at least 3 characters';
    }

    return null;
  }

  static String? validateCode(String? code) {
    if (code == null || code.isEmpty) {
      return 'Please enter or paste some code';
    }
    if (code.length > 10000) {
      return 'Code is too long (max 10000 characters)';
    }
    return null;
  }
  
  
}