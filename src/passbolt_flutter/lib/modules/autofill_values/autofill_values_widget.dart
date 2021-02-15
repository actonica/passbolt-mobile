// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:inject/inject.dart';
import 'package:logging/logging.dart';
import 'package:passbolt_flutter/analytics/AnalyticsEvents.dart';
import 'package:passbolt_flutter/common/bloc.dart';
import 'package:passbolt_flutter/common/state.dart';
import 'package:passbolt_flutter/common/ui/custom_scroll_physics.dart';
import 'package:passbolt_flutter/common/ui/custom_scrollbar.dart';
import 'package:passbolt_flutter/data/entities/resource.dart';
import 'package:passbolt_flutter/data/providers/theme_data_provider.dart';
import 'package:passbolt_flutter/i18n/app_i18n.dart';
import 'package:passbolt_flutter/modules/autofill_values/autofill_values_bloc.dart';
import 'package:passbolt_flutter/modules/autofill_values/autofill_values_entities.dart';
import 'package:passbolt_flutter/tools/values_converter.dart';

class AutofillValuesWidget extends StatefulWidget {
  final StateAutofillValuesWidget _state;

  @provide
  const AutofillValuesWidget(this._state);

  @override
  State<StatefulWidget> createState() {
    return _state;
  }
}

class StateAutofillValuesWidget extends DefaultState<AutofillValuesWidget> {
  final BaseAutofillValuesBloc _bloc;
  final FirebaseAnalytics _firebaseAnalytics;
  final _textEditingController = TextEditingController();
  final _logger = Logger('_StateResourcesWidget');
  bool _isAcsSorting = true;
  String _filter = '';

  @provide
  StateAutofillValuesWidget(this._bloc, this._firebaseAnalytics) : super(_bloc);

  @override
  void initState() {
    super.initState();
    _firebaseAnalytics.logEvent(name: AnalyticsEvents.screenResources);
    _bloc.handle(GetAutofillValuesIntent());
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
          if (snapshot.data is AutofillValuesState) {
            final state = snapshot.data as AutofillValuesState;
            return _buildBody(state);
          } else if (snapshot.data is ErrorState) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      (snapshot.data as ErrorState).message ?? 'Error',
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    createButton(
                      label: 'Try again',
                      action: () {
                        _bloc.handle(GetAutofillValuesIntent());
                      },
                    )
                  ],
                ),
              ),
            );
          }
        }

        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Widget _buildBody(AutofillValuesState state) {
    List<Widget> resourcesWidgets = List.generate(
      state.resources.length,
      (index) {
        return _buildResourceWidget(state.resources[index]);
      },
    );

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          children: <Widget>[
            _buildHeader(state),
            Expanded(
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: CustomScrollbar(
                  child: ListView.separated(
                    physics: CustomScrollPhysics(),
                    itemBuilder: (BuildContext buildContext, int index) {
                      return resourcesWidgets[index];
                    },
                    separatorBuilder: (BuildContext buildContext, int index) {
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
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AutofillValuesState state) {
    return Container(
      color: AppColors.main,
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 8,
          bottom: 16,
        ),
        child: SafeArea(
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
        ),
      ),
    );
  }

  Widget _buildResourceWidget(Resource item) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        this._bloc.handle(SelectResourceForAutofillIntent(item));
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
}
