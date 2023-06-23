import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'challenge_signer_method_channel.dart';

import 'shared.dart';

abstract class ChallengeSignerPlatform extends PlatformInterface {
  ChallengeSignerPlatform() : super(token: _token);

  static final Object _token = Object();

  static ChallengeSignerPlatform _instance = MethodChannelChallengeSigner();
  static ChallengeSignerPlatform get instance => _instance;

  static set instance(ChallengeSignerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<Credential> createCredential(String applicationName);

  Future<Assertion> getAssertion(String challenge, String rpId, {List<List<int>>? allowCredentialIds});
}
