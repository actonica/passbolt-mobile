// ©2019-2020 Actonica LLC - All Rights Reserved

import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:inject/inject.dart';
import 'package:logging/logging.dart';
import 'package:passbolt_flutter/analytics/AnalyticsEvents.dart';
import 'package:passbolt_flutter/common/bloc.dart';
import 'package:passbolt_flutter/common/router.dart';
import 'package:passbolt_flutter/common/state.dart';
import 'package:passbolt_flutter/common/ui/custom_scroll_physics.dart';
import 'package:passbolt_flutter/common/ui/custom_scrollbar.dart';
import 'package:passbolt_flutter/data/entities/resource.dart';
import 'package:passbolt_flutter/data/providers/theme_data_provider.dart';
import 'package:passbolt_flutter/di/app_di_module.dart';
import 'package:passbolt_flutter/di/app_di_module_provider.dart';
import 'package:passbolt_flutter/modules/resource_crud/di/resource_crud_di_module.dart';
import 'package:passbolt_flutter/modules/resources/resources_bloc.dart';
import 'package:passbolt_flutter/modules/resources/resources_entities.dart';
import 'package:passbolt_flutter/modules/secret/di/secret_injector.dart';
import 'package:passbolt_flutter/modules/secret/di/secret_module.dart';
import 'package:passbolt_flutter/modules/secret/secret_entities.dart';
import 'package:passbolt_flutter/tools/values_converter.dart';

class ResourcesWidget extends StatefulWidget {
  final StateResourcesWidget _stateResourcesWidget;

  @provide
  const ResourcesWidget(this._stateResourcesWidget);

  @override
  State<StatefulWidget> createState() {
    return _stateResourcesWidget;
  }
}

class StateResourcesWidget extends DefaultState<ResourcesWidget> {
  final BaseResourcesBloc _bloc;
  final FirebaseAnalytics _firebaseAnalytics;
  final _textEditingController = TextEditingController();
  final _logger = Logger('_StateResourcesWidget');
  String _filter = '';

  @provide
  StateResourcesWidget(this._bloc, this._firebaseAnalytics) : super(_bloc);

  @override
  void initState() {
    super.initState();
    _firebaseAnalytics.logEvent(name: AnalyticsEvents.screenResources);
    _bloc.handle(FetchResourcesIntent());
  }

  @override
  void dispose() {
    super.dispose();
    _bloc.dispose();
    _textEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _bloc.states,
      builder: (context, AsyncSnapshot<BlocState> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data is ResourcesState) {
            final state = snapshot.data as ResourcesState;
            final items = state.resources;

            List<Widget> resourcesWidgets = List.generate(
              items.length,
              (index) {
                return _buildResourceWidget(items[index], context);
              },
            );

            Widget floatingActionButton = FloatingActionButton(
              onPressed: () async {
                await Navigator.of(context)
                    .pushNamed(RouteName.resourceCreate.toString());

                _bloc.handle(FetchResourcesIntent());
              },
              child: Icon(Icons.add),
              backgroundColor: AppColors.main,
              foregroundColor: Colors.white,
            );

            Widget floatingActionButtonContainer;

            if (Platform.isAndroid) {
              floatingActionButtonContainer = floatingActionButton;
            } else {
              floatingActionButtonContainer = Padding(
                padding: EdgeInsets.only(bottom: 32),
                child: floatingActionButton,
              );
            }

            return Scaffold(
              floatingActionButton: floatingActionButtonContainer,
              body: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: Column(
                  children: <Widget>[
                    Container(
                      color: AppColors.main,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          _buildHeader(state),
                          _buildSearchBar(),
                        ],
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          await _bloc.handle(FetchResourcesIntent());
                        },
                        child: MediaQuery.removePadding(
                          context: context,
                          removeTop: true,
                          child: CustomScrollbar(
                            child: ListView.separated(
                              physics: CustomScrollPhysics(),
                              itemBuilder:
                                  (BuildContext buildContext, int index) {
                                return resourcesWidgets[index];
                              },
                              separatorBuilder:
                                  (BuildContext buildContext, int index) {
                                return Padding(
                                  padding: EdgeInsets.only(left: 16),
                                  child: Container(
                                    width: double.infinity,
                                    height: 1,
                                    color: Color(0xFFE2E2E2),
                                  ),
                                );
                              },
                              itemCount: resourcesWidgets.length,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          } else if (snapshot.data is ErrorState) {
            return _buildErrorWidget(snapshot.data);
          }
        }

        return _buildProgressWidget();
      },
    );
  }

  Widget _buildHeader(ResourcesState state) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.only(left: 16, right: 16, top: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(
              'Passwords',
              style: TextStyle(color: Colors.white, fontSize: 34),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Container(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      Navigator.of(context).pushNamed(
                        RouteName.profile.toString(),
                      );
                    },
                    child: Image.asset(
                      'assets/images/ic_profile.png',
                      width: 32,
                      height: 32,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: 16,
      ),
      child: Container(
        height: 48,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Icon(
                Icons.search,
                color: AppColors.searchIcon,
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextField(
                  controller: _textEditingController,
                  decoration: InputDecoration.collapsed(
                    hintText: 'Search',
                  ),
                  onChanged: (input) {
                    _filter = input;
                    _bloc.handle(FilterIntent(_filter));
                  },
                ),
              ),
            )
          ],
        ),
        decoration: BoxDecoration(
          color: AppColors.searchBackground,
          borderRadius: BorderRadius.all(
            Radius.circular(12.0),
          ),
        ),
      ),
    );
  }

  Widget _buildResourceWidget(Resource item, BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        FocusScope.of(context).unfocus();

        AppDiModule appDiModule = AppDiModuleProvider.of(context).appDiModule;

        final route = SecretInjector.createSync(
          SecretDiModule(
            SecretModuleIn(item),
          ),
          ResourceCrudDiModule(null),
          appDiModule,
        ).widget();

        await Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (buildContext) {
              return route;
            },
          ),
        );

        await _bloc.handle(FetchResourcesIntent());
        await _bloc.handle(FilterIntent(_filter));
      },
      child: Container(
        color: Colors.white,
        child: SizedBox(
          height: 80,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    ValuesConverter.nullOrEmptyToNa(item.name),
                    style: TextStyle(fontSize: 15, color: Color(0xFF606060)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Text(
                    ValuesConverter.nullOrEmptyToNa(item.username),
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF999999),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Text(
                    ValuesConverter.nullOrEmptyToNa(item.uri),
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF999999),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(ErrorState state) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              state.message ?? 'Error',
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 16,
            ),
            createButton(
              label: 'Try again',
              action: () {
                _bloc.handle(FetchResourcesIntent());
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildProgressWidget() {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
