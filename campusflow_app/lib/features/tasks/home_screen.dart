import 'package:campusflow_models/campusflow_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_client.dart';
import '../../core/format.dart';
import '../auth/auth_controller.dart';
import 'detail_screen.dart';
import 'tasks_controller.dart';

/// Largeur à partir de laquelle on affiche liste + détail côte à côte (écran 4).
const double largeurTablette = 840;

/// Écran 1 : échéances. Sur tablette, contient aussi le détail.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtre = ref.watch(filtreProvider);
    final async = ref.watch(tasksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CampusFlow'),
        actions: [
          IconButton(
            tooltip: 'Actualiser',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(tasksProvider.notifier).rafraichir(),
          ),
          IconButton(
            tooltip: 'Se déconnecter',
            icon: const Icon(Icons.logout),
            onPressed: () =>
                ref.read(authControllerProvider.notifier).deconnecter(),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, c) {
          final liste = _ListeTaches(filtre: filtre, async: async);
          if (c.maxWidth < largeurTablette) return liste;
          return Row(
            children: [
              SizedBox(width: 380, child: liste),
              const VerticalDivider(width: 1),
              const Expanded(child: _VoletDetail()),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/nouvelle'),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: filtre.index,
        onDestinationSelected: (i) =>
            ref.read(filtreProvider.notifier).state = FiltreTaches.values[i],
        destinations: const [
          NavigationDestination(icon: Icon(Icons.schedule), label: 'À faire'),
          NavigationDestination(
              icon: Icon(Icons.warning_amber), label: 'En retard'),
          NavigationDestination(
              icon: Icon(Icons.check_circle_outline), label: 'Faites'),
        ],
      ),
    );
  }
}

class _ListeTaches extends ConsumerWidget {
  const _ListeTaches({required this.filtre, required this.async});

  final FiltreTaches filtre;
  final AsyncValue<List<Task>> async;

  bool _garde(Task t) => switch (filtre) {
        FiltreTaches.aFaire => !t.terminee && !t.enRetard,
        FiltreTaches.enRetard => t.enRetard,
        FiltreTaches.faites => t.terminee,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 48),
              const SizedBox(height: 12),
              Text(messageErreur(e), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(tasksProvider),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
      data: (taches) {
        final visibles = taches.where(_garde).toList();
        return RefreshIndicator(
          onRefresh: () => ref.read(tasksProvider.notifier).rafraichir(),
          child: visibles.isEmpty
              // ListView pour que le geste « tirer pour actualiser » reste possible.
              ? ListView(children: const [
                  SizedBox(height: 120),
                  Center(child: Text('Aucune tâche ici.')),
                ])
              : ListView.builder(
                  itemCount: visibles.length,
                  itemBuilder: (context, i) => _TacheTile(task: visibles[i]),
                ),
        );
      },
    );
  }
}

class _TacheTile extends ConsumerWidget {
  const _TacheTile({required this.task});
  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final largeEcran = MediaQuery.sizeOf(context).width >= largeurTablette;
    final selectionnee = ref.watch(tacheSelectionneeProvider) == task.id;
    final couleur = task.terminee
        ? Colors.green
        : (task.enRetard ? Colors.red : Colors.orange);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: selectionnee && largeEcran
          ? Theme.of(context).colorScheme.secondaryContainer
          : null,
      child: ListTile(
        leading: Icon(
          task.terminee ? Icons.check_circle : Icons.schedule,
          color: couleur,
        ),
        title: Text(task.titre),
        subtitle: Text(formatDate(task.echeance)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          if (largeEcran) {
            ref.read(tacheSelectionneeProvider.notifier).state = task.id;
          } else {
            context.push('/tache/${task.id}');
          }
        },
      ),
    );
  }
}

/// Volet de droite (tablette) : détail de la tâche sélectionnée.
class _VoletDetail extends ConsumerWidget {
  const _VoletDetail();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ref.watch(tacheSelectionneeProvider);
    final taches = ref.watch(tasksProvider).valueOrNull ?? const <Task>[];
    final task = taches.where((t) => t.id == id).firstOrNull;
    if (task == null) {
      return const Center(child: Text('Sélectionnez une échéance'));
    }
    return TaskDetailView(
      task: task,
      onSupprimee: () =>
          ref.read(tacheSelectionneeProvider.notifier).state = null,
    );
  }
}
