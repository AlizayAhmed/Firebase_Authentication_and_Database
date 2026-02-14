// screens/user_profile_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';
import '../models/todo_model.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';
import '../widgets/profile_tab.dart';
import '../widgets/tasks_tab.dart';

class UserProfilePage extends StatefulWidget {
  final String userName;
  final String userEmail;

  const UserProfilePage({
    Key? key,
    required this.userName,
    required this.userEmail,
  }) : super(key: key);

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _authService = FirebaseAuthService();
  final _firestoreService = FirestoreService();

  AppUser? _currentUser;
  List<Todo> _todos = [];
  bool _isLoadingUser = true;
  bool _isLoadingTodos = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuild to show/hide FAB
    });
    _loadUserData();
    _loadTasks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Load user data from Firestore
  Future<void> _loadUserData() async {
    setState(() => _isLoadingUser = true);

    try {
      final uid = _authService.currentUser?.uid;
      if (uid != null) {
        final user = await _firestoreService.getUser(uid);
        setState(() {
          _currentUser = user;
          _isLoadingUser = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoadingUser = false;
      });
    }
  }

  // Load tasks from Firestore
  Future<void> _loadTasks() async {
    setState(() => _isLoadingTodos = true);

    try {
      final uid = _authService.currentUser?.uid;
      if (uid != null) {
        final todos = await _firestoreService.getUserTasks(uid);
        setState(() {
          _todos = todos;
          _isLoadingTodos = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoadingTodos = false;
      });
      _showErrorSnackBar('Failed to load tasks: ${e.toString()}');
    }
  }

  // Handle todo toggle
  Future<void> _handleTodoToggle(String todoId, bool completed) async {
    try {
      // Update in Firestore
      await _firestoreService.updateTaskStatus(
        taskId: todoId,
        completed: completed,
      );

      // Update local state
      setState(() {
        final index = _todos.indexWhere((todo) => todo.id == todoId);
        if (index != -1) {
          _todos[index].completed = completed;
        }
      });
    } catch (e) {
      _showErrorSnackBar('Failed to update task: ${e.toString()}');
    }
  }

  // Handle create task
  Future<void> _handleCreateTask(String title) async {
    try {
      final uid = _authService.currentUser?.uid;
      if (uid == null) return;

      // Create in Firestore
      final taskId = await _firestoreService.createTask(
        userId: uid,
        title: title,
      );

      // Add to local state
      setState(() {
        _todos.insert(
          0,
          Todo(
            id: taskId,
            userId: uid,
            title: title,
            completed: false,
            createdAt: DateTime.now(),
          ),
        );
      });

      _showSuccessSnackBar('Task created successfully!');
    } catch (e) {
      _showErrorSnackBar('Failed to create task: ${e.toString()}');
    }
  }

  // Handle delete task
  Future<void> _handleDeleteTask(String todoId) async {
    try {
      // Delete from Firestore
      await _firestoreService.deleteTask(todoId);

      // Remove from local state
      setState(() {
        _todos.removeWhere((todo) => todo.id == todoId);
      });

      _showSuccessSnackBar('Task deleted successfully!');
    } catch (e) {
      _showErrorSnackBar('Failed to delete task: ${e.toString()}');
    }
  }

  // Handle username update
  Future<void> _handleUsernameUpdate(String newName) async {
    try {
      final uid = _authService.currentUser?.uid;
      if (uid == null) return;

      // Update in Firebase Auth
      await _authService.updateDisplayName(newName);

      // Update in Firestore
      await _firestoreService.updateUserProfile(
        uid: uid,
        name: newName,
      );

      // Update local state
      setState(() {
        _currentUser = _currentUser?.copyWith(name: newName);
      });

      _showSuccessSnackBar('Username updated successfully!');
    } catch (e) {
      _showErrorSnackBar('Failed to update username: ${e.toString()}');
    }
  }

  // Handle logout
  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Text('Logout'),
          ],
        ),
        content: const Text('Are you sure you want to logout?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _authService.signOut();
        // Navigation handled by StreamBuilder in main.dart
      } catch (e) {
        if (mounted) {
          _showErrorSnackBar('Logout failed: ${e.toString()}');
        }
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showCreateTaskDialog() {
    final taskController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.add_task, color: Colors.blue, size: 28),
            SizedBox(width: 12),
            Text('Create New Task'),
          ],
        ),
        content: TextField(
          controller: taskController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter task title',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          maxLines: 2,
          textCapitalization: TextCapitalization.sentences,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              taskController.dispose();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final title = taskController.text.trim();
              if (title.isNotEmpty) {
                _handleCreateTask(title);
                taskController.dispose();
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blue.shade600,
          labelColor: Colors.blue.shade600,
          unselectedLabelColor: Colors.grey.shade600,
          tabs: const [
            Tab(
              icon: Icon(Icons.person),
              text: 'Profile',
            ),
            Tab(
              icon: Icon(Icons.task_alt),
              text: 'Tasks',
            ),
          ],
        ),
      ),
      body: _isLoadingUser
          ? _buildLoadingIndicator()
          : _error != null
              ? _buildErrorView()
              : _buildBody(),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton.extended(
              onPressed: _showCreateTaskDialog,
              backgroundColor: Colors.blue.shade600,
              icon: const Icon(Icons.add),
              label: const Text('New Task'),
            )
          : null,
    );
  }

  Widget _buildBody() {
    return TabBarView(
      controller: _tabController,
      children: [
        ProfileTab(
          userName: _currentUser?.name ?? widget.userName,
          userEmail: _currentUser?.email ?? widget.userEmail,
          userPhotoUrl: _currentUser?.photoUrl,
          onLogout: _handleLogout,
          onUsernameUpdate: _handleUsernameUpdate,
        ),
        TasksTab(
          todos: _todos,
          isLoading: _isLoadingTodos,
          onToggle: (todoId, completed) {
            _handleTodoToggle(todoId, completed);
          },
          onCreateTask: _handleCreateTask,
          onDeleteTask: (todoId) {
            _handleDeleteTask(todoId);
          },
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Colors.blue.shade600,
            strokeWidth: 3,
          ),
          const SizedBox(height: 24),
          Text(
            'Loading your profile...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red.shade400,
            size: 60,
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _error ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _loadUserData();
              _loadTasks();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}