// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:logging/logging.dart';
import 'package:passbolt_flutter/app/app_assembly.dart';
import 'package:passbolt_flutter/common/bloc.dart';
import 'package:passbolt_flutter/data/entities/user.dart';
import 'package:passbolt_flutter/data/providers/settings_provider.dart';
import 'package:passbolt_flutter/modules/profile/profile_entities.dart';
import 'package:passbolt_flutter/modules/profile/profile_interactor.dart';

abstract class BaseProfileBloc implements Bloc<BlocState> {}

class ProfileBloc extends DefaultBloc<BlocState> implements BaseProfileBloc {
  final BaseProfileInteractor _interactor;
  final _logger = Logger('ProfileBloc');

  ProfileBloc(this._interactor) {
    this.actions[FetchProfileIntent] = (intent) async {
      try {
        await Future.delayed(Duration(milliseconds: 100));

        final User user = await _interactor.getUser();
        final String privateKey = await _interactor.getPrivateKey();
        final Settings settings = await _interactor.getSettings();

        setState(
          ProfileState(
            items: [
              UserInfo(
                userName: '${user.profile.firstName} ${user.profile.lastName}',
                userEmail: user.name,
                userRole: user.role.name,
                userAvatarUrl: user.profile.avatarUrl,
              ),
              Space(),
              KeyInfoWithRoute(
                title: 'Public key',
                keyData: user.publicKey.armoredKey,
                route: KeyInfoRoute.public,
              ),
              KeyInfoWithRoute(
                title: 'Private key',
                keyData: privateKey,
                route: KeyInfoRoute.private,
              ),
              Space(),
              AutoLogout(
                title: 'Auto logout',
                value: settings.autoLogoutPreset.minutes > 0
                    ? '${settings.autoLogoutPreset.minutes} min'
                    : 'immediately',
                preset: settings.autoLogoutPreset,
              ),
              LoginWithBiometrics(
                title: 'Unlock with biometrics',
                value: settings.loginWithBiometrics,
              ),
              Space(),
              KeyInfo(title: 'Key id', value: user.publicKey.id),
              KeyInfoWithCopy(title: 'Uid', value: user.publicKey.uid),
              KeyInfoWithCopy(
                  title: 'Fingerprint', value: user.publicKey.fingerprint),
              KeyInfo(title: 'Created', value: user.publicKey.created),
              KeyInfo(title: 'Expires', value: user.publicKey.expires ?? '-'),
              KeyInfo(
                  title: 'Key Length', value: user.publicKey.bits.toString()),
              KeyInfo(title: 'Algorithm', value: user.publicKey.type),
              Space(),
              InfoWithUrl(title: 'Terms of use', url: AppAssembly.termsUrl),
              InfoWithUrl(title: 'Privacy', url: AppAssembly.privacyUrl),
              Logout(title: 'Logout'),
            ],
          ),
        );
      } catch (error) {
        setReaction(ErrorReaction(error.toString()));
      }
    };
  }
}
