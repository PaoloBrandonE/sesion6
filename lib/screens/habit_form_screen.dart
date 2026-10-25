import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/habit_repository.dart';
import '../models/habit_entry.dart';
import '../services/local_services.dart';
import '../services/photo_service.dart';
import '../utils/validators.dart';
import '../widgets/habit_widgets.dart';

class HabitFormArgs {
  const HabitFormArgs(this.entry);
  final HabitEntry entry;
}

class HabitFormScreen extends StatefulWidget {
  const HabitFormScreen({super.key, required this.services, this.args});
  final AppServices services;
  final HabitFormArgs? args;
  @override
  State<HabitFormScreen> createState() => _HabitFormScreenState();
}

class _HabitFormScreenState extends State<HabitFormScreen> {
  final _key = GlobalKey<FormState>();
  late final TextEditingController _title, _minutes, _email, _notes, _dateText;
  late DateTime _date;
  String? _category, _photo, _message;
  bool _saving = false,
      _camera = false,
      _recovery = true,
      _settings = false,
      _kept = false;
  HabitEntry? get _original => widget.args?.entry;
  @override
  void initState() {
    super.initState();
    final entry = _original;
    _title = TextEditingController(text: entry?.title);
    _minutes = TextEditingController(text: entry?.minutes.toString());
    _email = TextEditingController(
      text: entry?.email ?? '210928@unsaac.edu.pe',
    );
    _notes = TextEditingController(text: entry?.notes);
    _date = entry?.date ?? DateTime.now();
    _dateText = TextEditingController(text: dayKey(_date));
    _category = entry?.category;
    _photo = entry?.photoPath;
    unawaited(_recover());
  }

  Future<void> _recover() async {
    try {
      final path = await widget.services.photos.recover();
      if (!mounted) {
        if (path != null) await widget.services.photos.remove(path);
        return;
      }
      if (path != null) {
        _photo = path;
        _message =
            'Se recuperó la fotografía de la cámara. Completa los datos y guárdala.';
      }
    } catch (_) {
      if (mounted) {
        _message = 'No se pudo recuperar una foto anterior. Puedes tomar otra.';
      }
    }
    if (mounted) setState(() => _recovery = false);
  }

  @override
  void dispose() {
    for (final controller in [_title, _minutes, _email, _notes, _dateText]) {
      controller.dispose();
    }
    if (!_kept && _photo != null && _photo != _original?.photoPath) {
      unawaited(widget.services.photos.remove(_photo!));
    }
    super.dispose();
  }

  Future<void> _capture() async {
    setState(() {
      _camera = true;
      _message = null;
      _settings = false;
    });
    try {
      final path = await widget.services.photos.capture();
      if (!mounted) {
        if (path != null) await widget.services.photos.remove(path);
        return;
      }
      final previous = _photo;
      if (path != null) {
        setState(() => _photo = path);
        if (previous != null && previous != _original?.photoPath) {
          await widget.services.photos.remove(previous);
        }
      }
    } on PhotoFailure catch (error) {
      if (mounted) {
        setState(() {
          _message = error.message;
          _settings = error.settings;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _message =
              'No se pudo guardar la fotografía. Puedes continuar sin foto.',
        );
      }
    } finally {
      if (mounted) setState(() => _camera = false);
    }
  }

  Future<void> _save() async {
    if (_saving || _camera || _recovery || !_key.currentState!.validate()) {
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _saving = true;
      _message = null;
      _settings = false;
    });
    try {
      // Validación asíncrona real contra SQLite antes de escribir.
      if (await widget.services.repository.exists(
        _title.text,
        _date,
        excludingId: _original?.id,
      )) {
        throw const DuplicateHabit();
      }
      final value = HabitEntry(
        id: _original?.id,
        title: _title.text,
        category: _category!,
        minutes: int.parse(_minutes.text),
        date: _date,
        email: _email.text,
        notes: _notes.text,
        photoPath: _photo,
        completed: _original?.completed ?? false,
      );
      await widget.services.repository.save(value);
      _kept = true;
      final oldPhoto = _original?.photoPath;
      if (oldPhoto != null && oldPhoto != _photo) {
        await widget.services.photos.remove(oldPhoto);
      }
      if (mounted) {
        Navigator.pop(context, true); // Resultado que recarga lista/detalle.
      }
    } on DuplicateHabit catch (error) {
      if (mounted) setState(() => _message = error.toString());
    } catch (_) {
      if (mounted) {
        setState(
          () => _message =
              'No se guardó el registro. Revisa el espacio disponible e inténtalo otra vez.',
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = _saving || _camera || _recovery;
    return PopScope(
      canPop: !busy,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_original == null ? 'Nuevo registro' : 'Editar registro'),
        ),
        body: PageBody(
          maxWidth: 560,
          child: Form(
            key: _key,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: AbsorbPointer(
              absorbing: busy,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Pequeñas acciones, progreso real',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Los datos se guardan únicamente en este dispositivo.',
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    key: const Key('title'),
                    controller: _title,
                    validator: Validators.title,
                    textInputAction: TextInputAction.next,
                    maxLength: 60,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del hábito',
                      prefixIcon: Icon(Icons.edit_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    key: const Key('category'),
                    initialValue: _category,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Categoría'),
                    items: [
                      for (final category in categories)
                        DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ),
                    ],
                    validator: Validators.category,
                    onChanged: (value) => setState(() => _category = value),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const Key('minutes'),
                    controller: _minutes,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textInputAction: TextInputAction.next,
                    validator: Validators.minutes,
                    decoration: const InputDecoration(
                      labelText: 'Duración en minutos',
                      prefixIcon: Icon(Icons.timer_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _dateText,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Fecha',
                      prefixIcon: Icon(Icons.calendar_month),
                    ),
                    onTap: () async {
                      final selected = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (selected != null && mounted) {
                        setState(() {
                          _date = selected;
                          _dateText.text = dayKey(selected);
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const Key('email'),
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: Validators.email,
                    decoration: const InputDecoration(
                      labelText: 'Correo institucional',
                      prefixIcon: Icon(Icons.mail_outline),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const Key('notes'),
                    controller: _notes,
                    validator: Validators.notes,
                    minLines: 3,
                    maxLines: 5,
                    maxLength: 500,
                    decoration: const InputDecoration(
                      labelText: 'Descripción de la actividad',
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_photo != null) ...[
                    HabitPhoto(path: _photo!),
                    const SizedBox(height: 16),
                  ],
                  OutlinedButton.icon(
                    key: const Key('camera'),
                    onPressed: busy ? null : _capture,
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: Text(
                      _photo == null
                          ? 'Tomar fotografía opcional'
                          : 'Cambiar fotografía',
                    ),
                  ),
                  if (_photo != null)
                    TextButton(
                      onPressed: busy
                          ? null
                          : () async {
                              final path = _photo!;
                              setState(() => _photo = null);
                              if (path != _original?.photoPath) {
                                await widget.services.photos.remove(path);
                              }
                            },
                      child: const Text('Quitar fotografía'),
                    ),
                  if (_message != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Semantics(
                        liveRegion: true,
                        child: Text(_message!, key: const Key('formMessage')),
                      ),
                    ),
                  if (_settings)
                    TextButton(
                      onPressed: widget.services.photos.settings,
                      child: const Text('Abrir ajustes de cámara'),
                    ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    key: const Key('save'),
                    onPressed: busy ? null : _save,
                    icon: busy
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(_saving ? 'Guardando…' : 'Guardar registro'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
