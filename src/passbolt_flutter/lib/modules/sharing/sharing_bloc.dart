// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:logging/logging.dart';
import 'package:passbolt_flutter/common/bloc.dart';
import 'package:passbolt_flutter/data/api/permissions_api.dart';
import 'package:passbolt_flutter/data/api/sharing_api.dart';
import 'package:passbolt_flutter/data/entities/permission.dart';
import 'package:passbolt_flutter/data/entities/permission_with_aro.dart';
import 'package:passbolt_flutter/modules/sharing/sharing_entities.dart';
import 'package:passbolt_flutter/modules/sharing/sharing_interactor.dart';

abstract class BaseSharingBloc implements Bloc<BlocState> {}

class SharingBloc extends DefaultBloc<BlocState> implements BaseSharingBloc {
  final SharingModuleIn _moduleIn;
  String _lastSearchInput;
  bool _isSearchCanceled = false;
  bool _hasChanged = false;
  List<AroPermission> _sourceArosPermissions;
  List<AroPermission> _currentArosPermissions;
  final BaseSharingInteractor _interactor;
  final _logger = Logger("SharingBloc");

  SharingBloc(this._moduleIn, this._interactor) {
    this.actions[FetchPermissionsIntent] = (intent) async {
      if (this.state is PendingState) return;
      setState(PendingState());
      final response = await _interactor.getPermissions(
        GetPermissionsRequest(_moduleIn.resourceId),
      );

      _sourceArosPermissions = List<AroPermission>();
      _sourceArosPermissions.addAll(response);
      _currentArosPermissions = response;

      setState(SharingState(response, _isArosPermissionsChanged()));
    };

    this.actions[SearchAroIntent] = (intent) async {
      try {
        _lastSearchInput = (intent as SearchAroIntent).input;
        await _search(_lastSearchInput);
      } catch (error) {
        setState(
          SharingState(
            _currentArosPermissions,
            _isArosPermissionsChanged(),
            [
              AroError(
                error.toString(),
              ),
            ],
          ),
        );
      }
    };

    this.actions[DeleteAroPermissionIntent] = (intent) async {
      if (state is SharingState) {
        final aroPermission =
            (intent as DeleteAroPermissionIntent).aroPermission;
        final currentSearchedAros = (state as SharingState).aros;

        // check owner
        final actualArosPermissions = _currentArosPermissions.where(
          (item) {
            return item.permission.aroId != aroPermission.permission.aroId;
          },
        ).toList();

        if (actualArosPermissions.any(
          (item) {
            return item.permission.type == PermissionType.owner;
          },
        )) {
          _currentArosPermissions = actualArosPermissions;
          setState(
            SharingState(_currentArosPermissions, _isArosPermissionsChanged(),
                currentSearchedAros),
          );
        } else {
          setReaction(PasswordMustHaveAnOwnerReaction());
        }
      }
    };

    this.actions[AddDefaultPermissionIntent] = (intent) async {
      if (state is SharingState) {
        final aro = (intent as AddDefaultPermissionIntent).aro;

        if (_currentArosPermissions.any(
          (permission) {
            return permission.permission.aroId == aro.userOrGroupId;
          },
        )) {
          setReaction(AlreadyInListReaction());
          return;
        }

        String permissionId;

        try {
          final source = _sourceArosPermissions.firstWhere(
            (sourceAroPermission) {
              return sourceAroPermission.aro.userOrGroupId == aro.userOrGroupId;
            },
          );
          permissionId = source.permission.id;
        } catch (error) {
          permissionId = null;
        }

        final aroPermission = AroPermission(
          Permission(
            permissionId,
            _moduleIn.resourceId,
            'Resource',
            aro.userOrGroupId,
            aro.info == 'Group' ? AroType.group : AroType.user,
            PermissionType.read,
          ),
          aro,
        );

        _currentArosPermissions.add(aroPermission);

        setState(SharingState(
            _currentArosPermissions, _isArosPermissionsChanged(), []));
      }
    };

    this.actions[EditPermissionIntent] = (intent) async {
      if (state is SharingState && intent is EditPermissionIntent) {
        final aroPermission = _currentArosPermissions.firstWhere(
          (item) {
            return item.permission.aroId ==
                intent.aroPermission.permission.aroId;
          },
        );

        final newPermission =
            aroPermission.permission.copyWithType(intent.permissionType);
        final newAroPermission =
            AroPermission(newPermission, aroPermission.aro);

        // check owner
        final actualArosPermissions = List<AroPermission>();
        actualArosPermissions.addAll(_currentArosPermissions);
        actualArosPermissions[actualArosPermissions.indexOf(aroPermission)] =
            newAroPermission;

        if (!actualArosPermissions.any(
          (item) {
            return item.permission.type == PermissionType.owner;
          },
        )) {
          setReaction(PasswordMustHaveAnOwnerReaction());
          return;
        }

        _currentArosPermissions[
            _currentArosPermissions.indexOf(aroPermission)] = newAroPermission;
        setState(
          SharingState(
            _currentArosPermissions,
            _isArosPermissionsChanged(),
            (state as SharingState).aros,
          ),
        );
      }
    };

    this.actions[ApplyChangesIntent] = (intent) async {
      if (state is SharingState) {
        try {
          await _interactor.share(_moduleIn.resourceId, _moduleIn.password,
              _getNewAroPermission(), _getDeletedAroPermissions());
          _sourceArosPermissions = [];
          _sourceArosPermissions.addAll(_currentArosPermissions);
          _hasChanged = true;
          setState(SharingState(
              _currentArosPermissions, _isArosPermissionsChanged()));
          setReaction(ApplyChangesCompleteReaction());
        } catch (error) {
          _currentArosPermissions = [];
          _currentArosPermissions.addAll(_sourceArosPermissions);
          setState(SharingState(
              _currentArosPermissions, _isArosPermissionsChanged()));
          setReaction(ErrorReaction(error.toString()));
        }
      }
    };

    this.actions[NavigateBackIntent] = (intent) async {
      setReaction(NavigateBackReaction(_hasChanged));
    };
  }

  void _search(String input) async {
    if (input == null || input.isEmpty) {
      _isSearchCanceled = true;
      setState(SharingState(
          _currentArosPermissions, _isArosPermissionsChanged(), []));
      return;
    }

    if (this.state is SharingPendingAroState) {
      return;
    }

    setState(
      SharingPendingAroState(
        _currentArosPermissions,
        _isArosPermissionsChanged(),
        [AroPending()],
      ),
    );
    _lastSearchInput = null;
    _isSearchCanceled = false;
    final response = await _interactor.searchAros(SearchArosRequest(input));

    List<AroItem> aroEntries = response.aroEntries;
    if (aroEntries.isEmpty) {
      aroEntries = [AroNoResults()];
    }

    if (_isSearchCanceled) {
      _isSearchCanceled = false;
      return;
    }

    setState(
      SharingState(
        _currentArosPermissions,
        _isArosPermissionsChanged(),
        aroEntries,
      ),
    );

    if (_lastSearchInput != null && _lastSearchInput.isNotEmpty) {
      _search(_lastSearchInput);
    }
  }

  bool _isArosPermissionsChanged() {
    if (_sourceArosPermissions.length != _currentArosPermissions.length) {
      return true;
    }

    bool result = false;

    _sourceArosPermissions.forEach(
      (sourceAroPermission) {
        if (result) return;
        if (!_currentArosPermissions.any((currentAroPermission) {
          return sourceAroPermission == currentAroPermission;
        })) {
          result = true;
        }
      },
    );

    return result;
  }

  List<AroPermission> _getNewAroPermission() {
    final result = List<AroPermission>();

    _currentArosPermissions.forEach(
      (currentAroPermission) {
        if (!_sourceArosPermissions.any(
          (sourceAroPermission) {
            return sourceAroPermission.aro.userOrGroupId ==
                currentAroPermission.aro.userOrGroupId;
          },
        )) {
          result.add(currentAroPermission);
        } else {
          final sourceAroPermission = _sourceArosPermissions.firstWhere(
            (e) {
              return e.aro.userOrGroupId ==
                  currentAroPermission.aro.userOrGroupId;
            },
          );

          if (sourceAroPermission.permission.type !=
              currentAroPermission.permission.type) {
            result.add(currentAroPermission);
          }
        }
      },
    );

    return result;
  }

  List<AroPermission> _getDeletedAroPermissions() {
    final result = List<AroPermission>();
    _sourceArosPermissions.forEach(
      (sourceAroPermission) {
        if (!_currentArosPermissions.any((currentAroPermission) {
          return sourceAroPermission.aro.userOrGroupId ==
              currentAroPermission.aro.userOrGroupId;
        })) {
          result.add(sourceAroPermission);
        }
      },
    );

    return result;
  }
}
