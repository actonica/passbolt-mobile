// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:passbolt_flutter/data/api/groups_api.dart';
import 'package:passbolt_flutter/data/entities/group.dart';

abstract class BaseGroupsProvider {
  Future<Group> getGroup(String id);

  Future<List<Group>> getAllGroups();
}

class GroupsProvider implements BaseGroupsProvider {
  final BaseGroupsApi _groupsApi;
  List<Group> _groups = [];

  GroupsProvider(this._groupsApi);

  @override
  Future<Group> getGroup(String id) async {
    await _fetchGroups();
    return _groups.firstWhere(
          (group) {
        return group.id == id;
      },
    );
  }

  @override
  Future<List<Group>> getAllGroups() async {
    await _fetchGroups();
    return _groups;
  }

  void _fetchGroups() async {
    if (_groups.isEmpty) {
      final wsResponse = await _groupsApi.getGroups();
      _groups = [];
      _groups = wsResponse.groups;
    }
  }
}
