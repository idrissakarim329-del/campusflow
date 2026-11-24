import 'package:campusflow_models/campusflow_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import '../../core/format.dart';
import 'tasks_controller.dart';

/// Écran 3 : formulaire de création. Envoie un POST /tasks.
class TaskFormScreen extends ConsumerStatefulWidget {
  const TaskFormScreen({super.key});

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titre = TextEditingController();
  final _description = TextEditingController();
  DateTime? _date;
  bool _enCours = false;

  @override
  void dispose() {
    _titre.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 3)),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _save() async {
    // validate() lance tous les validator et affiche les messages d'erreur
    if (!_formKey.currentState!.validate()) return;
    final messenger = ScaffoldMessenger.of(context);
    if (_date == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Choisissez une date d\'échéance.')),
      );
      return;
    }
    final desc = _description.text.trim();
    setState(() => _enCours = true);
    try {
      await ref.read(tasksProvider.notifier).ajouter(
            Task(
              titre: _titre.text.trim(),
              echeance: _date!,
              description: desc.isEmpty ? null : desc,
            ),
          );
      messenger.showSnackBar(const SnackBar(content: Text('Tâche enregistrée')));
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(messageErreur(e))));
      if (mounted) setState(() => _enCours = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle échéance')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titre,
              decoration: const InputDecoration(
                labelText: 'Titre',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
              validator: (v) {
                final s = v?.trim() ?? '';
                if (s.isEmpty) return 'Le titre est obligatoire';
                if (s.length < 3) return 'Au moins 3 caractères';
                return null; // null = valide
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _description,
              decoration: const InputDecoration(
                labelText: 'Description (optionnel)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.event),
              label: Text(
                _date == null
                    ? 'Choisir la date d\'échéance'
                    : 'Échéance : ${formatDate(_date!)}',
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _enCours ? null : _save,
              child: _enCours
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }
}
