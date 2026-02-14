// services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';
import '../models/todo_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _todosCollection => _firestore.collection('todos');

  // ==================== USER OPERATIONS ====================

  /// Create or update user profile in Firestore
  Future<void> createOrUpdateUser({
    required String uid,
    required String name,
    required String email,
    String? photoUrl,
  }) async {
    try {
      final userDoc = _usersCollection.doc(uid);
      final docSnapshot = await userDoc.get();

      if (docSnapshot.exists) {
        // Update existing user
        await userDoc.update({
          'name': name,
          'email': email,
          'photoUrl': photoUrl,
          'lastLogin': FieldValue.serverTimestamp(),
        });
      } else {
        // Create new user
        await userDoc.set({
          'name': name,
          'email': email,
          'photoUrl': photoUrl,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Failed to save user data: ${e.toString()}');
    }
  }

  /// Get user profile from Firestore
  Future<AppUser?> getUser(String uid) async {
    try {
      final docSnapshot = await _usersCollection.doc(uid).get();
      if (docSnapshot.exists) {
        return AppUser.fromFirestore(docSnapshot);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch user data: ${e.toString()}');
    }
  }

  /// Update user profile
  Future<void> updateUserProfile({
    required String uid,
    String? name,
    String? photoUrl,
  }) async {
    try {
      final Map<String, dynamic> updates = {};
      if (name != null) updates['name'] = name;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;

      if (updates.isNotEmpty) {
        await _usersCollection.doc(uid).update(updates);
      }
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  /// Stream of user profile (real-time updates)
  Stream<AppUser?> userStream(String uid) {
    return _usersCollection.doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return AppUser.fromFirestore(snapshot);
      }
      return null;
    });
  }

  // ==================== TODO/TASK OPERATIONS ====================

  /// Create a new task
  Future<String> createTask({
    required String userId,
    required String title,
  }) async {
    try {
      final docRef = await _todosCollection.add({
        'userId': userId,
        'title': title,
        'completed': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create task: ${e.toString()}');
    }
  }

  /// Get all tasks for a user
  Future<List<Todo>> getUserTasks(String userId) async {
    try {
      final querySnapshot = await _todosCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Todo.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch tasks: ${e.toString()}');
    }
  }

  /// Stream of user tasks (real-time updates)
  Stream<List<Todo>> userTasksStream(String userId) {
    return _todosCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Todo.fromFirestore(doc)).toList();
    });
  }

  /// Update task completion status
  Future<void> updateTaskStatus({
    required String taskId,
    required bool completed,
  }) async {
    try {
      await _todosCollection.doc(taskId).update({
        'completed': completed,
      });
    } catch (e) {
      throw Exception('Failed to update task: ${e.toString()}');
    }
  }

  /// Update task title
  Future<void> updateTaskTitle({
    required String taskId,
    required String title,
  }) async {
    try {
      await _todosCollection.doc(taskId).update({
        'title': title,
      });
    } catch (e) {
      throw Exception('Failed to update task: ${e.toString()}');
    }
  }

  /// Delete a task
  Future<void> deleteTask(String taskId) async {
    try {
      await _todosCollection.doc(taskId).delete();
    } catch (e) {
      throw Exception('Failed to delete task: ${e.toString()}');
    }
  }

  /// Delete all tasks for a user
  Future<void> deleteAllUserTasks(String userId) async {
    try {
      final querySnapshot = await _todosCollection
          .where('userId', isEqualTo: userId)
          .get();

      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete tasks: ${e.toString()}');
    }
  }

  /// Get task count for a user
  Future<int> getUserTaskCount(String userId) async {
    try {
      final querySnapshot = await _todosCollection
          .where('userId', isEqualTo: userId)
          .get();
      return querySnapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to count tasks: ${e.toString()}');
    }
  }

  /// Get completed task count
  Future<int> getCompletedTaskCount(String userId) async {
    try {
      final querySnapshot = await _todosCollection
          .where('userId', isEqualTo: userId)
          .where('completed', isEqualTo: true)
          .get();
      return querySnapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to count completed tasks: ${e.toString()}');
    }
  }
}