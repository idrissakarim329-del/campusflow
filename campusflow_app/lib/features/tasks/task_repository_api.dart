import 'package:campusflow_models/campusflow_models.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';

/// Implémentation réelle : parle à json-server via Dio.
class ApiTaskRepository implements TaskRepository {
  ApiTaskRepository(this._dio);
  final Dio _dio;

  @override
  Future<List<Task>> charger() async {
    final res = await _dio.get<List<dynamic>>('/tasks');
    return (res.data ?? [])
        .map((e) => Task.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Task> creer(Task tache) async {
    final res =
        await _dio.post<Map<String, dynamic>>('/tasks', data: tache.toJson());
    return Task.fromJson(res.data!);
  }

  @override
  Future<Task> modifier(int id, Map<String, dynamic> champs) async {
    final res =
        await _dio.patch<Map<String, dynamic>>('/tasks/$id', data: champs);
    return Task.fromJson(res.data!);
  }

  @override
  Future<void> supprimer(int id) async {
    await _dio.delete<dynamic>('/tasks/$id');
  }
}

/// `flutter run --dart-define=USE_FAKE=true` : travaille sans serveur.
const _utiliserFake = bool.fromEnvironment('USE_FAKE');

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  if (_utiliserFake) {
    return SimulatedTaskRepository(delai: const Duration(milliseconds: 400));
  }
  return ApiTaskRepository(ref.watch(dioProvider));
});
