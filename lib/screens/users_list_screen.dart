import 'package:flutter/material.dart';
import '../db/db_crud.dart'; // ✅ Importar DBOperations en lugar de DatabaseHelper
import '../models/user.dart';

class UsersListScreen extends StatefulWidget {
  const UsersListScreen({super.key});

  @override
  UsersListScreenState createState() => UsersListScreenState();
}

class UsersListScreenState extends State<UsersListScreen> {
  List<User> _users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() async {
    final users = await DBOperations.instance.getAllUsers(); // ✅ Corrección aquí
    setState(() {
      _users = users;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Usuarios Registrados")),
      body: _users.isEmpty
          ? const Center(child: Text("No hay usuarios registrados."))
          : ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                return ListTile(
                  leading: const Icon(Icons.account_circle),
                  title: Text(user.username),
                  subtitle: Text("ID: ${user.id}"),
                );
              },
            ),
    );
  }
}
