// models/todo_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Todo {
  final String? id; // Firestore document ID (null for new todos)
  final String userId;
  final String title;
  bool completed;
  final DateTime? createdAt;

  Todo({
    this.id,
    required this.userId,
    required this.title,
    this.completed = false,
    this.createdAt,
  });

  // Factory constructor for JSONPlaceholder API (Week 4)
  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      userId: json['userId']?.toString() ?? '0',
      id: json['id']?.toString(),
      title: json['title'] ?? '',
      completed: json['completed'] ?? false,
    );
  }

  // Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'id': id,
      'title': title,
      'completed': completed,
    };
  }

  // Factory constructor for Firestore
  factory Todo.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Todo(
      id: doc.id,
      userId: data['userId'] ?? 0,
      title: data['title'] ?? '',
      completed: data['completed'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'completed': completed,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  // Create a copy with updated fields
  Todo copyWith({
    String? id,
    String? userId,
    String? title,
    bool? completed,
    DateTime? createdAt,
  }) {
    return Todo(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}