import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'task.dart';
import 'task_repository.dart';

class TaskListContainer extends StatefulWidget {
  const TaskListContainer({super.key, this.repository});

  final TaskRepository? repository;

  @override
  State<TaskListContainer> createState() => _TaskListContainerState();
}

class _TaskListContainerState extends State<TaskListContainer> {
  late TaskRepository _repository;
  List<Task> _tasks = const [];
  final Set<String> _pendingTaskIds = {};
  Object? _loadError;
  bool _isLoading = true;
  int _fetchGeneration = 0;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? InMemoryTaskRepository();
    _loadTasks();
  }

  @override
  void didUpdateWidget(covariant TaskListContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository) {
      _repository = widget.repository ?? InMemoryTaskRepository();
      _loadTasks();
    }
  }

  Future<void> _loadTasks() async {
    final generation = ++_fetchGeneration;
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final tasks = await _repository.fetchTasks();
      if (!mounted || generation != _fetchGeneration) return;
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted || generation != _fetchGeneration) return;
      setState(() {
        _loadError = error;
        _isLoading = false;
      });
    }
  }

  Future<void> _setTaskCompleted(Task task, bool isCompleted) async {
    setState(() => _pendingTaskIds.add(task.id));
    try {
      await _repository.setTaskCompleted(task.id, isCompleted);
      if (!mounted) return;
      setState(() {
        _tasks = _tasks
            .map((current) => current.id == task.id ? current.copyWith(isCompleted: isCompleted) : current)
            .toList();
      });
    } catch (error) {
      if (mounted) _showMutationError('Could not update the task.', error);
    } finally {
      if (mounted) setState(() => _pendingTaskIds.remove(task.id));
    }
  }

  Future<void> _deleteTask(Task task) async {
    setState(() => _pendingTaskIds.add(task.id));
    try {
      await _repository.deleteTask(task.id);
      if (!mounted) return;
      setState(() {
        _tasks = _tasks.where((current) => current.id != task.id).toList();
      });
    } catch (error) {
      if (mounted) _showMutationError('Could not delete the task.', error);
    } finally {
      if (mounted) setState(() => _pendingTaskIds.remove(task.id));
    }
  }

  void _showMutationError(String message, Object error) {
    RM.scaffold.context = context;
    RM.scaffold.showSnackBar(
      SnackBar(
        content: Text('$message $error'),
        behavior: SnackBarBehavior.fixed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 32, 16, 24),
                  sliver: SliverToBoxAdapter(
                    child: _TaskListHeader(
                      total: _tasks.length,
                      completed: _tasks.where((task) => task.isCompleted).length,
                    ),
                  ),
                ),
                if (_isLoading)
                  const SliverFillRemaining(hasScrollBody: false, child: _TaskListLoading())
                else if (_loadError != null)
                  SliverFillRemaining(hasScrollBody: false, child: _TaskListError(onRetry: _loadTasks))
                else if (_tasks.isEmpty)
                  const SliverFillRemaining(hasScrollBody: false, child: _TaskListEmpty())
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    sliver: SliverToBoxAdapter(
                      child: TaskList(
                        tasks: _tasks,
                        pendingTaskIds: _pendingTaskIds,
                        onTaskToggled: _setTaskCompleted,
                        onTaskDeleted: _deleteTask,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TaskList extends StatelessWidget {
  const TaskList({
    required this.tasks,
    required this.onTaskToggled,
    required this.onTaskDeleted,
    this.pendingTaskIds = const {},
    super.key,
  });

  final List<Task> tasks;
  final Set<String> pendingTaskIds;
  final TaskToggleCallback onTaskToggled;
  final ValueChanged<Task> onTaskDeleted;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: 'Task list, ${tasks.length} tasks',
      child: Column(
        children: [
          for (var index = 0; index < tasks.length; index++) ...[
            if (index > 0) const SizedBox(height: 8),
            Builder(
              builder: (context) {
                final task = tasks[index];
                return Material(
                  color: colorScheme.surfaceContainerLow,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: CheckboxListTile(
                    value: task.isCompleted,
                    onChanged: pendingTaskIds.contains(task.id) ? null : (value) => onTaskToggled(task, value ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    title: Text(
                      task.title,
                      style: textTheme.titleSmall?.copyWith(
                        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                        color: task.isCompleted ? colorScheme.onSurfaceVariant : colorScheme.onSurface,
                      ),
                    ),
                    subtitle: task.description == null
                        ? null
                        : Text(
                            task.description!,
                            style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                    secondary: IconButton(
                      tooltip: 'Delete ${task.title}',
                      onPressed: pendingTaskIds.contains(task.id) ? null : () => onTaskDeleted(task),
                      icon: pendingTaskIds.contains(task.id)
                          ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.delete_outline),
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

typedef TaskToggleCallback = void Function(Task task, bool isCompleted);

class _TaskListHeader extends StatelessWidget {
  const _TaskListHeader({required this.total, required this.completed});

  final int total;
  final int completed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final countLabel = '$completed of $total complete';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.check_circle_outline, color: colorScheme.primary),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'SEERACO  /  YOUR SPACE',
                style: textTheme.labelLarge?.copyWith(color: colorScheme.primary, letterSpacing: 1.1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text('Tasks', style: textTheme.headlineLarge),
        const SizedBox(height: 8),
        Text(
          'A clear list for what comes next.',
          style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        Semantics(
          liveRegion: true,
          label: countLabel,
          child: Text(countLabel, style: textTheme.labelLarge?.copyWith(color: colorScheme.onSurfaceVariant)),
        ),
      ],
    );
  }
}

class _TaskListLoading extends StatelessWidget {
  const _TaskListLoading();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label: 'Loading tasks',
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var index = 0; index < 3; index++) ...[
              if (index > 0) const SizedBox(height: 8),
              Container(
                height: 76,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TaskListError extends StatelessWidget {
  const _TaskListError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined, size: 40, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text('Tasks could not be loaded', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Something went wrong while loading your tasks.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}

class _TaskListEmpty extends StatelessWidget {
  const _TaskListEmpty();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.task_alt, size: 40, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text('You’re all caught up', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'There are no tasks here right now.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
