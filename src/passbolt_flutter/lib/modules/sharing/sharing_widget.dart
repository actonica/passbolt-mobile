// ©2019-2020 Actonica LLC - All Rights Reserved

import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:inject/inject.dart';
import 'package:logging/logging.dart';
import 'package:passbolt_flutter/analytics/AnalyticsEvents.dart';
import 'package:passbolt_flutter/common/bloc.dart';
import 'package:passbolt_flutter/common/state.dart';
import 'package:passbolt_flutter/common/ui/dialog.dart';
import 'package:passbolt_flutter/data/api/sharing_api.dart';
import 'package:passbolt_flutter/data/entities/permission.dart';
import 'package:passbolt_flutter/data/entities/permission_with_aro.dart';
import 'package:passbolt_flutter/data/entities/user_profile.dart';
import 'package:passbolt_flutter/data/providers/theme_data_provider.dart';
import 'package:passbolt_flutter/modules/sharing/sharing_bloc.dart';
import 'package:passbolt_flutter/modules/sharing/sharing_entities.dart';
import 'package:pedantic/pedantic.dart';

class SharingWidget extends StatefulWidget {
  final StateSharingWidget _stateSecretWidget;

  @provide
  const SharingWidget(this._stateSecretWidget);

  @override
  State<StatefulWidget> createState() {
    return _stateSecretWidget;
  }
}

class StateSharingWidget extends DefaultState<SharingWidget> {
  final BaseSharingBloc _bloc;
  final FirebaseAnalytics _firebaseAnalytics;
  final _logger = Logger("StateSharingWidget");
  final _avatarSize = 48.0;
  final _scaffoldGlobalKey = GlobalKey<ScaffoldState>();
  StreamSubscription _reactionsSubscriptions;

  @provide
  StateSharingWidget(this._bloc, this._firebaseAnalytics) : super(_bloc);

  @override
  void initState() {
    super.initState();
    _firebaseAnalytics.logEvent(name: AnalyticsEvents.screenSharing);
    _reactionsSubscriptions = _bloc.reactions.listen(
      (reaction) async {
        if (!mounted) return;
        switch (reaction.runtimeType) {
          case AlreadyInListReaction:
            _scaffoldGlobalKey.currentState?.hideCurrentSnackBar();
            _scaffoldGlobalKey.currentState?.showSnackBar(
              SnackBar(
                content: Text('Already in list'),
              ),
            );
            break;
          case PasswordMustHaveAnOwnerReaction:
            _scaffoldGlobalKey.currentState?.hideCurrentSnackBar();
            _scaffoldGlobalKey.currentState?.showSnackBar(
              SnackBar(
                content: Text(
                  'The password must have an owner',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.red,
              ),
            );
            break;
          case ApplyChangesCompleteReaction:
            Navigator.of(context, rootNavigator: true).pop();
            _bloc.handle(FetchPermissionsIntent());
            break;
          case NavigateBackReaction:
            Navigator.of(context)
                .pop((reaction as NavigateBackReaction).hasChanged);
            break;
          case ErrorReaction:
            Navigator.of(context, rootNavigator: true).pop();
            unawaited(
              showAlertDialog(
                  context: context,
                  message: (reaction as ErrorReaction).message),
            );
            break;
          default:
            return;
        }
      },
      cancelOnError: true,
    );
    _bloc.handle(FetchPermissionsIntent());
  }

  @override
  void dispose() {
    super.dispose();
    _reactionsSubscriptions.cancel();
    _bloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return WillPopScope(
      onWillPop: () async {
        _bloc.handle(NavigateBackIntent());
        return false;
      },
      child: Scaffold(
        key: _scaffoldGlobalKey,
        appBar: AppBar(
          title: Text('Sharing',
              style: Theme.of(context).appBarTheme.textTheme.title),
          elevation: 0,
        ),
        body: StreamBuilder(
          stream: _bloc.states,
          builder: (buildContext, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data is ErrorState) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        (snapshot.data as ErrorState).message ?? "Error",
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      createButton(
                        label: 'Try again',
                        action: () {
                          _bloc.handle(FetchPermissionsIntent());
                        },
                      ),
                    ],
                  ),
                );
              } else if (snapshot.data is SharingState) {
                final widgets = (snapshot.data as SharingState).permissions.map(
                  (permission) {
                    return _buildPermissionWidget(permission);
                  },
                ).toList();
                widgets.add(
                  SizedBox(
                    height: 128,
                  ),
                );

                return Container(
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      ListView.separated(
                        itemCount: widgets.length,
                        itemBuilder: (buildContext, index) {
                          return widgets[index];
                        },
                        separatorBuilder: (buildContext, index) {
                          return Container(
                            color: Colors.black12,
                            height: 1,
                            width: double.infinity,
                          );
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              _buildSearchResultsWidget(
                                  (snapshot.data as SharingState).aros),
                              SizedBox(
                                height: 8,
                              ),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: TextFormField(
                                      autocorrect: false,
                                      textInputAction: TextInputAction.go,
                                      onChanged: (input) {
                                        _bloc.handle(SearchAroIntent(input));
                                      },
                                      decoration: InputDecoration(
                                        labelText: 'Enter name or email',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: _buildButton(snapshot.data),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
            }

            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildButton(SharingState state) {
    return ButtonTheme(
      buttonColor: state.isChanged ? Color(0xFF358EF6) : Colors.grey,
      child: RaisedButton(
        child: Text(
          'Apply changes',
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () {
          FocusScope.of(context).unfocus();
          showAlertDialog(
            context: context,
            message: 'Change password permissions?',
            action: () {
              Navigator.of(context, rootNavigator: true).pop();
              unawaited(
                showPendingDialog(
                    context: context, message: 'Update permissions...'),
              );
              _bloc.handle(ApplyChangesIntent());
            },
            showCancelOption: true,
            positiveLabel: 'Yes',
            negativeLabel: 'No',
          );
        },
        elevation: 0,
      ),
    );
  }

  Widget _buildSearchResultsWidget(List<AroItem> aros) {
    if (aros == null || aros.isEmpty) {
      return Center();
    }

    if (aros.length > 3) {
      return SizedBox(
        height: MediaQuery.of(context).size.height / 4,
        child: Container(
          color: Colors.black12,
          child: Scrollbar(
            child: ListView.separated(
              itemBuilder: (buildContext, index) {
                final aro = aros[index];

                return _buildAroWidget(aro);
              },
              separatorBuilder: (buildContext, index) {
                return Container(height: 1, color: Colors.grey);
              },
              itemCount: aros.length,
            ),
          ),
        ),
      );
    } else {
      final widgets = List.generate(
        aros.length,
        (index) {
          return _buildAroWidget(aros[index]);
        },
      );

      return Container(
        color: Colors.black12,
        child: Column(
          children: widgets,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
        ),
      );
    }
  }

  Widget _buildAroWidget(AroItem item) {
    switch (item.runtimeType) {
      case Aro:
        final aro = item as Aro;
        return GestureDetector(
          child: Container(
            color: Colors.white,
            child: SizedBox(
              height: 64,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  if (!UserProfile.isDefaultAvatar(aro.avatarUrl))
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 0,
                        right: 16,
                        top: 8,
                        bottom: 8,
                      ),
                      child: Center(
                        child: Image.network(
                          aro.avatarUrl,
                          width: _avatarSize,
                          height: _avatarSize,
                        ),
                      ),
                    ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            aro.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            aro.info,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          onTap: () {
            FocusScope.of(context).unfocus();
            _bloc.handle(AddDefaultPermissionIntent(item));
          },
        );
        break;
      case AroNoResults:
        return Container(
          color: Colors.white,
          child: SizedBox(
            height: 64,
            child: Center(
              child: Text('No results'),
            ),
          ),
        );
        break;
      case AroError:
        final error = item as AroError;
        return Container(
          color: Colors.white,
          child: SizedBox(
            height: 64,
            child: Center(
              child:
                  Text(error.message, style: TextStyle(color: AppColors.error)),
            ),
          ),
        );
        break;
      case AroPending:
        return Container(
          color: Colors.white,
          child: SizedBox(
            height: 64,
            child: Center(
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        );
        break;
      default:
        throw UnimplementedError();
    }
  }

  Widget _buildPermissionWidget(AroPermission permissionWithAro) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      color: Colors.white,
      child: SizedBox(
        height: 64,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            if (!UserProfile.isDefaultAvatar(permissionWithAro.aro.avatarUrl))
              Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 0,
                  top: 8,
                  bottom: 8,
                ),
                child: Center(
                  child: Image.network(
                    permissionWithAro.aro.avatarUrl,
                    width: _avatarSize,
                    height: _avatarSize,
                  ),
                ),
              ),
            SizedBox(width: 16,),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    permissionWithAro.aro.name,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    permissionWithAro.aro.info,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 8,
            ),
            DropdownButton<PermissionType>(
              value: permissionWithAro.permission.type,
              onChanged: (value) async {
                _bloc.handle(EditPermissionIntent(permissionWithAro, value));
              },
              items: <PermissionType>[
                PermissionType.read,
                PermissionType.update,
                PermissionType.owner
              ].map(
                (permissionType) {
                  return DropdownMenuItem<PermissionType>(
                    value: permissionType,
                    child: Text(
                      permissionType.description,
                      style: textTheme.body2,
                    ),
                  );
                },
              ).toList(),
            ),
            SizedBox(
              width: 8,
            ),
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () async {
                _bloc.handle(DeleteAroPermissionIntent(permissionWithAro));
              },
            ),
          ],
        ),
      ),
    );
  }
}
