// BRANDON PAOLO ESTRADA CUYTO · 210928 · Docente: YOVER COLLANTES VALER
const categories = ['Estudio', 'Sueño', 'Actividad física', 'Bienestar'];

String dayKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

String titleKey(String title) =>
    title.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();

class HabitEntry {
  const HabitEntry({
    this.id,
    required this.title,
    required this.category,
    required this.minutes,
    required this.date,
    required this.email,
    required this.notes,
    this.photoPath,
    this.completed = false,
  });
  final int? id;
  final String title, category, email, notes;
  final int minutes;
  final DateTime date;
  final String? photoPath;
  final bool completed;

  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'title': title.trim(),
    'title_key': titleKey(title),
    'category': category,
    'minutes': minutes,
    'date': dayKey(date),
    'email': email.trim().toLowerCase(),
    'notes': notes.trim(),
    'photo_path': photoPath,
    'completed': completed ? 1 : 0,
  };
  factory HabitEntry.fromMap(Map<String, Object?> map) => HabitEntry(
    id: map['id'] as int,
    title: map['title'] as String,
    category: map['category'] as String,
    minutes: map['minutes'] as int,
    date: DateTime.parse(map['date'] as String),
    email: map['email'] as String,
    notes: map['notes'] as String,
    photoPath: map['photo_path'] as String?,
    completed: map['completed'] == 1,
  );
}
