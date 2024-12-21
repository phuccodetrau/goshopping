import 'package:flutter/foundation.dart';
import '../models/group_model.dart';
import '../repositories/group_repository.dart';

class GroupProvider extends ChangeNotifier {
  final GroupRepository _repository;
  List<Group> _groups = [];
  List<Group> _filteredGroups = [];
  bool _isLoading = false;
  String? _error;

  GroupProvider({required GroupRepository repository}) : _repository = repository;

  List<Group> get groups => _groups;
  List<Group> get filteredGroups => _filteredGroups;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchUserGroups(String email) async {
    try {
      _setLoading(true);
      _error = null;
      notifyListeners();

      _groups = await _repository.getUserGroups(email);
      _filteredGroups = _groups;
      
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  void filterGroups(String query) {
    if (query.isEmpty) {
      _filteredGroups = _groups;
    } else {
      _filteredGroups = _groups.where((group) => 
        group.name.toLowerCase().contains(query.toLowerCase())
      ).toList();
    }
    notifyListeners();
  }

  Future<bool> leaveGroup(String groupId) async {
    try {
      final success = await _repository.leaveGroup(groupId);
      if (success) {
        _groups.removeWhere((group) => group.id == groupId);
        _filteredGroups.removeWhere((group) => group.id == groupId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> deleteGroup(String groupId) async {
    try {
      final success = await _repository.deleteGroup(groupId);
      if (success) {
        _groups.removeWhere((group) => group.id == groupId);
        _filteredGroups.removeWhere((group) => group.id == groupId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> createGroup(String token, Map<String, dynamic> data) async {
    try {
      _setLoading(true);
      await _repository.createGroup(token, data);
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      return false;
    }
  }

  Future<String?> getUserNameByEmail(String email, String token) async {
    try {
      return await _repository.getUserNameByEmail(email, token);
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  Future<Map<String, String>?> searchUserByEmail(String email) async {
    try {
      return await _repository.searchUserByEmail(email);
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  Future<bool> addMembersToGroup({
    required String groupId,
    required List<Map<String, String>> members,
  }) async {
    try {
      return await _repository.addMembersToGroup(
        groupId: groupId,
        members: members,
      );
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  Future<List<dynamic>> getItemsWithPagination({
    required String groupId,
    required String keyword,
    required int page,
    required int limit,
  }) async {
    try {
      return await _repository.getItemsWithPagination(
        groupId: groupId,
        keyword: keyword,
        page: page,
        limit: limit,
      );
    } catch (e) {
      notifyListeners();
      rethrow;
    }
  }
}
