import 'package:campusflow_models/campusflow_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import '../../core/format.dart';
import 'tasks_controller.dart';

/// Contenu du détail (écran 2). Réutilisé :
///  - dans [DetailScreen] (téléphone, page séparée),
///  - directement dans le volet de droite (tablette, écran 4).
class TaskDetailView extends ConsumerWidget {
  const TaskDetailView({super.key, required this.task, this.onSupprimee});

  final Task task;

  /// Appelé après une suppression réussie (retour à la liste / vider le volet).
  final VoidCallback? onSupprimee;

  Future<void> _marquerFaite(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(tasksProvider.notifier).marquerFaite(task.id!);
      messenger.showSnackBar(
          const SnackBar(content: Text('Tâche marquée comme faite')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(messageErreur(e))));
    }
  }

  Future<void> _supprimer(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer cette tâche ?'),
        content: Text(task.titre),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Supprimer')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(tasksProvider.notifier).supprimer(task.id!);
      onSupprimee?.call();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(messageErreur(e))));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final statut = task.terminee
        ? 'Terminée'
        : (task.enRetard ? 'En retard' : 'À faire');
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.titre, style: text.headlineSmall),
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.event, size: 18),
                    const SizedBox(width: 8),
                    Text('Échéance : ${formatDate(task.echeance)}'),
                  ]),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.flag, size: 18),
                    const SizedBox(width: 8),
                    Text('Statut : $statut'),
                  ]),
                  const Divider(height: 24),
                  Text(task.description ?? 'Aucune description.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            // onPressed null => bouton désactivé automatiquement
            onPressed: task.terminee ? null : () => _marquerFaite(context, ref),
            icon: const Icon(Icons.check),
            label: Text(task.terminee ? 'Déjà terminée' : 'Marquer comme fait'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _supprimer(context, ref),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

/// Écran 2 : page de détail pour téléphone (route /tache/:id).
class DetailScreen extends ConsumerWidget {
  const DetailScreen({super.key, required this.taskId});

  final int taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taches = ref.watch(tasksProvider).valueOrNull ?? const <Task>[];
    final task = taches.where((t) => t.id == taskId).firstOrNull;
    return Scaffold(
      appBar: AppBar(title: const Text('Détail')),
      body: task == null
          ? const Center(child: Text('Tâche introuvable.'))
          : TaskDetailView(
              task: task,
              onSupprimee: () => Navigator.of(context).pop(),
            ),
    );
  }
}
