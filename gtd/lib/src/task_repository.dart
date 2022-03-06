import 'package:gtd_domain/gtd_domain.dart';
import 'package:gtd_domain/src/repository.dart';
import 'package:updatable/updatable.dart';

class TaskRepository with Updatable implements Repository<Task> {
  List<Task> _tasks = [];

  // Singleton
  TaskRepository._hidden();
  static final shared = TaskRepository._hidden();

  // Overrides
  @override
  int get length => _tasks.length;

  @override
  Task operator [](int index) {
    return _tasks[index];
  }

  @override
  void add(Task element) {
    insert(0, element);
  }

  @override
  void insert(int index, Task element) {
    changeState(() {
      _tasks.insert(index, element);
    });
  }

  @override
  void move(int from, int to) {
    final taskFrom = _tasks[from];
    batchChangeState(() {
      _tasks.removeAt(from);
      _tasks.insert(to, taskFrom);
    });
  }

  @override
  void remove(Task element) {
    changeState(() {
      _tasks.remove(element);
    });
  }

  @override
  void removeAt(int index) {
    changeState(() {
      _tasks.removeAt(index);
    });
  }

  @override
  void removeAll() {
    final List<Task> toRemove = [];
    for (var e in _tasks) {
      if (e.state == TaskState.done) toRemove.add(e);
    }

    batchChangeState(() {
      _tasks.removeWhere((element) => toRemove.contains(element));
    });
}

}

extension Testing on TaskRepository {
  void reset() {
    _tasks = [];
  }

  void addTestData({int amount = 100}) {
    // un bucle for de 1 a 100
    // que añade tareas en estado toDo (si el índice es par)
    // y en estado done (si es impar)
    // OJO: mira a ver si int es un objeto y si tiene métodos que sirvan para esto
    for (int i = 0; i < amount; i++) {
      if (i.isEven) {
        TaskRepository.shared
            .add(Task.toDo(description: 'Something I should do $i'));
      } else {
        TaskRepository.shared.add(Task.done(description: 'A finished task $i'));
      }
    }
  }
}
