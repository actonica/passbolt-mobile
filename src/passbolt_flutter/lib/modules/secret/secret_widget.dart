// ©2019-2020 Actonica LLC - All Rights Reserved

import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:inject/inject.dart';
import 'package:logging/logging.dart';
import 'package:passbolt_flutter/analytics/AnalyticsEvents.dart';
import 'package:passbolt_flutter/common/bloc.dart';
import 'package:passbolt_flutter/common/router.dart';
import 'package:passbolt_flutter/common/state.dart';
import 'package:passbolt_flutter/common/ui/dialog.dart';
import 'package:passbolt_flutter/data/entities/comment.dart';
import 'package:passbolt_flutter/data/entities/permission.dart';
import 'package:passbolt_flutter/data/entities/permission_with_aro.dart';
import 'package:passbolt_flutter/data/entities/resource.dart';
import 'package:passbolt_flutter/data/entities/user_profile.dart';
import 'package:passbolt_flutter/data/providers/theme_data_provider.dart';
import 'package:passbolt_flutter/modules/resource_crud/resource_crud_entities.dart';
import 'package:passbolt_flutter/modules/secret/secret_bloc.dart';
import 'package:passbolt_flutter/modules/secret/secret_entities.dart';
import 'package:passbolt_flutter/modules/sharing/sharing_entities.dart';
import 'package:passbolt_flutter/tools/values_converter.dart';
import 'package:pedantic/pedantic.dart';
import 'package:url_launcher/url_launcher.dart';

class SecretWidget extends StatefulWidget {
  final StateSecretWidget _stateSecretWidget;

  @provide
  const SecretWidget(this._stateSecretWidget);

  @override
  State<StatefulWidget> createState() {
    return _stateSecretWidget;
  }
}

class StateSecretWidget extends DefaultState<SecretWidget> {
  final BaseSecretBloc _bloc;
  final FirebaseAnalytics _firebaseAnalytics;
  final _logger = Logger("_StateSecretWidget");
  final _scaffoldGlobalKey = GlobalKey<ScaffoldState>();
  final _avatarSize = 48.0;
  final _cellHeight = 64.0;
  final _contentSpace = 8.0;
  final _horizontalPadding = 16.0;
  final _verticalPadding = 16.0;
  final _titlePadding = 16.0;
  bool _isSecretRevealed = false;
  StreamSubscription _reactionsSubscription;

  @provide
  StateSecretWidget(this._bloc, this._firebaseAnalytics) : super(_bloc);

  @override
  void initState() {
    super.initState();
    _firebaseAnalytics.logEvent(name: AnalyticsEvents.screenSecret);
    _reactionsSubscription = _bloc.reactions.listen(
      (reaction) async {
        if (!mounted) return;
        Navigator.of(context, rootNavigator: true).pop();

        switch (reaction.runtimeType) {
          case DeleteCompleteReaction:
            unawaited(
              showAlertDialog(
                context: context,
                message: 'Complete',
                action: () async {
                  Navigator.of(context, rootNavigator: true).pop();
                  Navigator.of(context).pop();
                },
              ),
            );
            break;
          case ErrorReaction:
            unawaited(
              showAlertDialog(
                context: context,
                message: (reaction as ErrorReaction).message,
              ),
            );
            break;
          default:
            return;
        }
      },
      cancelOnError: true,
    );
    _bloc.handle(FetchSecretDetailsIntent());
  }

  @override
  void dispose() {
    super.dispose();
    _reactionsSubscription.cancel();
    _bloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appBarTitleStyle = Theme.of(context).appBarTheme.textTheme.title;

    return StreamBuilder(
      stream: _bloc.states,
      builder: (context, AsyncSnapshot<BlocState> snapshot) {
        if (snapshot.data is PendingSecretState ||
            snapshot.data is PendingDeleteResourceState) {
          final resource = (snapshot.data as BaseSecretState).resource;
          return Scaffold(
            key: _scaffoldGlobalKey,
            appBar: AppBar(
              title: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  resource.name,
                  style: appBarTitleStyle,
                ),
              ),
              elevation: 0,
            ),
            body: _buildContentView(snapshot),
          );
        } else if (snapshot.data is SecretState) {
          final resource = (snapshot.data as SecretState).resource;
          return Scaffold(
            key: _scaffoldGlobalKey,
            appBar: AppBar(
              title: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  resource.name,
                  style: appBarTitleStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              actions: <Widget>[
                if (resource.permissionType != PermissionType.read)
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () async {
                      final updatedResource =
                          await Navigator.of(context).pushNamed(
                        RouteName.resourceUpdate.toString(),
                        arguments: ResourceCrudModuleIn(
                            ResourceCrudMode.edit,
                            resource,
                            (snapshot.data as SecretState).decryptedSecret),
                      ) as Resource;

                      if (updatedResource != null) {
                        _bloc.handle(UpdateModuleInIntent(updatedResource));
                        _bloc.handle(FetchSecretDetailsIntent());
                      }
                    },
                  ),
                if (resource.permissionType == PermissionType.owner)
                  IconButton(
                    icon: Icon(Icons.share),
                    onPressed: () async {
                      if (snapshot.data is SecretState) {
                        final result = await Navigator.of(context).pushNamed(
                          RouteName.sharing.toString(),
                          arguments: SharingModuleIn(resource.id,
                              (snapshot.data as SecretState).decryptedSecret),
                        );

                        if (result ?? false) {
                          _bloc.handle(FetchSecretDetailsIntent());
                        }
                      }
                    },
                  ),
                if (resource.permissionType == PermissionType.owner)
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      await showAlertDialog(
                        context: context,
                        message:
                            'You are about to delete this password. Are you sure?',
                        showCancelOption: true,
                        titleLabel: 'Delete password',
                        positiveLabel: 'Yes',
                        negativeLabel: 'No',
                        action: () async {
                          Navigator.of(context, rootNavigator: true).pop();
                          unawaited(
                            showPendingDialog(
                                context: context,
                                message: 'Delete resource...'),
                          );
                          _bloc.handle(DeleteResourceIntent());
                        },
                      );
                    },
                  )
              ],
              elevation: 0,
            ),
            body: _buildContentView(snapshot),
          );
        } else {
          return Scaffold(
            key: _scaffoldGlobalKey,
            appBar: AppBar(
              title: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Error',
                  style: appBarTitleStyle,
                ),
              ),
              elevation: 0,
            ),
            body: _buildContentView(snapshot),
          );
        }
      },
    );
  }

  Widget _buildContentView(AsyncSnapshot snapshot) {
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
                _bloc.handle(FetchSecretDetailsIntent());
              },
            ),
          ],
        ),
      );
    } else if (snapshot.data is PendingSecretState) {
      return Container(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (snapshot.data is SecretState) {
      final textTheme = Theme.of(context).textTheme;
      final state = snapshot.data as SecretState;
      final resource = state.resource;
      final aroPermissions = state.aroPermissions;
      final List<Widget> aroPermissionsWidgets = aroPermissions.map(
        (item) {
          return _buildAroWidget(item);
        },
      ).toList();
      final List<Widget> commentsWidgets = state.comments?.map(
        (comment) {
          return _buildCommentWidget(comment);
        },
      )?.toList();

      final titleStyle = textTheme.body2;

      return SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.only(
              left: _horizontalPadding,
              right: _horizontalPadding,
              bottom: _verticalPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: _titlePadding),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'Information',
                          style: textTheme.title,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 48,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                        'Created  ${ValuesConverter.toTimeFromNow(resource.created) ?? "n/a"}'),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    _launchUrl(resource.uri);
                  },
                  child: _buildInfoWidget('URI', resource.uri),
                ),
                _buildInfoWidget('User name', resource.username),
                SizedBox(
                  height: _cellHeight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              'Password',
                              style: titleStyle,
                            ),
                            SizedBox(
                              height: _contentSpace,
                            ),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Text(
                                _isSecretRevealed
                                    ? (snapshot.data as SecretState)
                                        .decryptedSecret
                                    : "***********",
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(
                              _isSecretRevealed
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () async {
                              setState(
                                () {
                                  _isSecretRevealed = !_isSecretRevealed;
                                },
                              );
                            },
                            color: Colors.grey,
                          ),
                          IconButton(
                            icon: Icon(Icons.content_copy),
                            onPressed: () async {
                              await _copyToClipboard(
                                (snapshot.data as SecretState).decryptedSecret,
                              );
                            },
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildInfoWidget('Description', resource.description),
                Padding(
                  padding: EdgeInsets.only(
                    top: _titlePadding,
                    bottom: _titlePadding,
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'Shared with',
                          style: textTheme.title,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: aroPermissionsWidgets,
                ),
                if (state.comments != null && state.comments.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(
                      top: _titlePadding,
                      bottom: _titlePadding,
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            'Comments',
                            style: textTheme.title,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (state.comments != null && state.comments.isNotEmpty)
                  Column(
                    children: commentsWidgets,
                  ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Container(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }

  Widget _buildInfoWidget(String infoLabel, String infoValue) {
    final textTheme = Theme.of(context).textTheme;
    final titleStyle = textTheme.body2;
    return SizedBox(
      height: _cellHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  infoLabel,
                  style: titleStyle,
                ),
                SizedBox(
                  height: _contentSpace,
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    ValuesConverter.nullOrEmptyToNa(infoValue),
                  ),
                ),
              ],
            ),
          ),
          if (infoValue != null && infoValue.isNotEmpty)
            IconButton(
              icon: Icon(Icons.content_copy),
              onPressed: () async {
                await _copyToClipboard(
                  infoValue,
                );
              },
              color: Colors.grey,
            ),
        ],
      ),
    );
  }

  Widget _buildAroWidget(AroPermission item) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      color: Colors.white,
      child: SizedBox(
        height: 68,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            if (!UserProfile.isDefaultAvatar(item.aro.avatarUrl))
              Padding(
                padding: const EdgeInsets.only(
                  left: 0,
                  right: 16,
                  top: 8,
                  bottom: 8,
                ),
                child: Center(
                  child: Image.network(
                    item.aro.avatarUrl,
                    width: _avatarSize,
                    height: _avatarSize,
                  ),
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.aro.name,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.body2,
                    ),
                    Text(
                      item.aro.info,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.body1,
                    ),
                    Text(
                      item.permission.type.longDescription,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.body1,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentWidget(Comment comment) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: <Widget>[
        if (!UserProfile.isDefaultAvatar(comment.avatarUrl))
          Padding(
            padding: const EdgeInsets.only(
              left: 0,
              right: 16,
              top: 8,
              bottom: 8,
            ),
            child: Center(
              child: Image.network(
                comment.avatarUrl,
                width: _avatarSize,
                height: _avatarSize,
              ),
            ),
          ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  comment.content,
                ),
                SizedBox(
                  height: 8,
                ),
                RichText(
                  text: TextSpan(
                    style: textTheme.body1,
                    children: <TextSpan>[
                      TextSpan(
                          text: '${comment.userName}, ',
                          style: TextStyle(fontStyle: FontStyle.italic)),
                      TextSpan(
                        text: '${comment.created}',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  void _copyToClipboard(String data) async {
    await Clipboard.setData(ClipboardData(text: data));
    _scaffoldGlobalKey.currentState?.removeCurrentSnackBar();
    _scaffoldGlobalKey.currentState?.showSnackBar(
      SnackBar(
        content: Text('Copied to Clipboard'),
      ),
    );
  }

  void _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: false, forceWebView: false);
    } else {
      _logger.warning('launch bad url $url');
      unawaited(showAlertDialog(context: context, message: "Bad url"));
    }
  }
}
