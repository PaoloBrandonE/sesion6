abstract final class Validators {
  static String? title(String? input) {
    final value = input?.trim() ?? '';
    if (value.isEmpty) return 'Escribe el nombre del hábito.';
    if (value.length < 3 || value.length > 60) {
      return 'Usa entre 3 y 60 caracteres.';
    }
    return null;
  }

  static String? email(String? input) {
    final value = input?.trim() ?? '';
    if (!RegExp(r'^[a-zA-Z0-9._%+\-]+@unsaac\.edu\.pe$').hasMatch(value)) {
      return 'Usa tu correo institucional, por ejemplo 210928@unsaac.edu.pe.';
    }
    return null;
  }

  static String? minutes(String? input) {
    final number = int.tryParse(input?.trim() ?? '');
    if (number == null || number < 1 || number > 1440) {
      return 'Escribe un número entero entre 1 y 1440 minutos.';
    }
    return null;
  }

  static String? category(String? input) =>
      input == null ? 'Selecciona una categoría.' : null;
  static String? notes(String? input) {
    final length = input?.trim().length ?? 0;
    return length < 10 || length > 500
        ? 'Describe la actividad con entre 10 y 500 caracteres.'
        : null;
  }
}
