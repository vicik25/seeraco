import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seeraco/pages/home/Home.View.dart';
import 'package:seeraco/main.dart';
import 'package:seeraco/tasks/task.dart';
import 'package:seeraco/tasks/task_list.dart';
import 'package:seeraco/tasks/task_repository.dart';

void main() {
  testWidgets('loads tasks and supports completion and deletion', (tester) async {
    final repository = _FakeTaskRepository([
      const Task(id: '1', title: 'Plan the week'),
      const Task(id: '2', title: 'Send meeting notes'),
    ]);

    await tester.pumpWidget(MaterialApp(home: TaskListContainer(repository: repository)));
    await tester.pumpAndSettle();

    expect(find.text('Plan the week'), findsOneWidget);
    expect(find.text('0 of 2 complete'), findsOneWidget);

    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();
    expect(repository.tasks.first.isCompleted, isTrue);
    expect(find.text('1 of 2 complete'), findsOneWidget);

    await tester.tap(find.byTooltip('Delete Plan the week'));
    await tester.pumpAndSettle();
    expect(find.text('Plan the week'), findsNothing);
    expect(repository.tasks, hasLength(1));
  });

  testWidgets('completion can be changed with the keyboard', (tester) async {
    final repository = _FakeTaskRepository([const Task(id: '1', title: 'Keyboard task')]);

    await tester.pumpWidget(MaterialApp(home: TaskListContainer(repository: repository)));
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();

    expect(repository.tasks.first.isCompleted, isTrue);
  });

  testWidgets('announces loading while tasks are being fetched', (tester) async {
    final completer = Completer<List<Task>>();
    final repository = _FakeTaskRepository([], load: () => completer.future);

    await tester.pumpWidget(MaterialApp(home: TaskListContainer(repository: repository)));

    expect(find.bySemanticsLabel('Loading tasks'), findsOneWidget);
    completer.complete(const [Task(id: '1', title: 'Loaded task')]);
    await tester.pumpAndSettle();
    expect(find.text('Loaded task'), findsOneWidget);
  });

  testWidgets('ignores results from an outdated repository request', (tester) async {
    final pendingFetch = Completer<List<Task>>();
    final oldRepository = _FakeTaskRepository([], load: () => pendingFetch.future);
    final newRepository = _FakeTaskRepository([const Task(id: 'new', title: 'Current task')]);

    await tester.pumpWidget(MaterialApp(home: TaskListContainer(repository: oldRepository)));
    await tester.pumpWidget(MaterialApp(home: TaskListContainer(repository: newRepository)));
    await tester.pumpAndSettle();

    pendingFetch.complete(const [Task(id: 'old', title: 'Outdated task')]);
    await tester.pumpAndSettle();

    expect(find.text('Current task'), findsOneWidget);
    expect(find.text('Outdated task'), findsNothing);
  });

  testWidgets('shows an error state and retries the fetch', (tester) async {
    final repository = _FakeTaskRepository(const [
      Task(id: '1', title: 'Recovered task'),
    ], fetchError: StateError('offline'));

    await tester.pumpWidget(MaterialApp(home: TaskListContainer(repository: repository)));
    await tester.pumpAndSettle();

    expect(find.text('Tasks could not be loaded'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(repository.fetchCalls, 2);
    expect(find.text('Recovered task'), findsOneWidget);
  });

  testWidgets('shows an empty state when there are no tasks', (tester) async {
    await tester.pumpWidget(MaterialApp(home: TaskListContainer(repository: _FakeTaskRepository([]))));
    await tester.pumpAndSettle();

    expect(find.text('You’re all caught up'), findsOneWidget);
    expect(find.text('0 of 0 complete'), findsOneWidget);
  });

  testWidgets('starts on splash then navigates to customer home', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Seera.co_'), findsOneWidget);
    expect(find.text('Menyiapkan koleksi lucu...'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 701));
    await tester.pumpAndSettle();

    expect(find.text('FAVORIT SEERA'), findsOneWidget);
    expect(find.text('WHAT THEY SAY ABOUT SEERA?'), findsOneWidget);
    expect(find.text('Butterfly Beads Watch'), findsOneWidget);
    expect(find.text('Na***a'), findsOneWidget);
    expect(find.text('Ru***a'), findsOneWidget);
  });

  testWidgets('fits supported viewport widths without overflow', (tester) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final width in [320.0, 768.0, 1024.0, 1440.0]) {
      tester.view.physicalSize = Size(width, 800);
      await tester.pumpWidget(const MaterialApp(home: HomeView()));
      await tester.pumpAndSettle();

      expect(find.text('FAVORIT SEERA'), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'Viewport width $width');
    }
    addTearDown(tester.view.resetPhysicalSize);
  });
}

class _FakeTaskRepository implements TaskRepository {
  _FakeTaskRepository(this.tasks, {this.fetchError, this.load});

  final List<Task> tasks;
  Object? fetchError;
  final Future<List<Task>> Function()? load;
  int fetchCalls = 0;

  @override
  Future<List<Task>> fetchTasks() async {
    fetchCalls++;
    if (load != null) return load!();
    if (fetchError != null) {
      final error = fetchError!;
      fetchError = null;
      throw error;
    }
    return List.unmodifiable(tasks);
  }

  @override
  Future<void> setTaskCompleted(String id, bool isCompleted) async {
    final index = tasks.indexWhere((task) => task.id == id);
    tasks[index] = tasks[index].copyWith(isCompleted: isCompleted);
  }

  @override
  Future<void> deleteTask(String id) async {
    tasks.removeWhere((task) => task.id == id);
  }
}
