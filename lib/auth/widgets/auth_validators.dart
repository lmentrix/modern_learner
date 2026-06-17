String? validateName(String? v) {
  if (v == null || v.trim().isEmpty) return 'Name is required';
  if (v.trim().length < 2) return 'Name must be at least 2 characters';
  return null;
}

String? validateEmail(String? v) {
  if (v == null || v.trim().isEmpty) return 'Email is required';
  final emailRe = RegExp(
    r'^[\w.+\-]+@[\w\-]+\.[a-z]{2,}$',
    caseSensitive: false,
  );
  if (!emailRe.hasMatch(v.trim())) return 'Enter a valid email address';
  return null;
}

String? validatePassword(String? v) {
  if (v == null || v.isEmpty) return 'Password is required';
  if (v.length < 6) return 'Password must be at least 6 characters';
  return null;
}
