/// Tipos de fallo del dominio.
/// El Back puede extender estos cuando conecte la lógica real.
sealed class AppFailure {
  final String message;
  const AppFailure(this.message);
}

final class ValidationFailure extends AppFailure {
  const ValidationFailure(super.message);
}

final class NotFoundFailure extends AppFailure {
  const NotFoundFailure(super.message);
}

final class DuplicateFailure extends AppFailure {
  const DuplicateFailure(super.message);
}

final class AuthFailure extends AppFailure {
  const AuthFailure(super.message);
}

final class UnexpectedFailure extends AppFailure {
  const UnexpectedFailure(super.message);
}
