import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/group_provider.dart';
import '../../providers/user_provider.dart';

class AddGroupScreen extends StatefulWidget {
  const AddGroupScreen({super.key});

  @override
  State<AddGroupScreen> createState() => _AddGroupScreenState();
}

class _AddGroupScreenState extends State<AddGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _groupNameController = TextEditingController();
  final _emailController = TextEditingController();
  String? _userName;

  @override
  void dispose() {
    _groupNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _searchUser() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    final userProvider = context.read<UserProvider>();
    final groupProvider = context.read<GroupProvider>();
    
    final token = userProvider.user?.token;
    if (token == null) return;

    final userName = await groupProvider.getUserNameByEmail(email, token);
    setState(() {
      _userName = userName;
    });
  }

  Future<void> _createGroup() async {
    if (!_formKey.currentState!.validate()) return;
    if (_userName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please search for a valid user first')),
      );
      return;
    }

    final userProvider = context.read<UserProvider>();
    final groupProvider = context.read<GroupProvider>();
    
    final token = userProvider.user?.token;
    if (token == null) return;

    final data = {
      'name': _groupNameController.text.trim(),
      'email': _emailController.text.trim(),
    };

    final success = await groupProvider.createGroup(token, data);
    if (success && mounted) {
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(groupProvider.error ?? 'Failed to create group')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupProvider = context.watch<GroupProvider>();

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Create New Group'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _groupNameController,
                  decoration: const InputDecoration(
                    labelText: 'Group Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter group name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Member Email',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter member email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                    ),
                    IconButton(
                      onPressed: _searchUser,
                      icon: const Icon(Icons.search),
                    ),
                  ],
                ),
                if (_userName != null) ...[
                  const SizedBox(height: 8),
                  Text('Found user: $_userName'),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _createGroup,
                  child: const Text('Create Group'),
                ),
              ],
            ),
          ),
        ),
        if (groupProvider.isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
