import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'shared.dart';

import 'challenge_signer_platform_interface.dart';

class MethodChannelChallengeSigner extends ChallengeSignerPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('challenge_signer');

  @override
  createCredential(challenge, rp, user) {
    return const MethodChannel('challenge_signer').invokeMethod('createCredential', {
      'challenge': challenge,
      'rp': rp.toMap(),
      'user': user.toMap(),
    }).then((result) => Credential.fromMap(result));
  }

  @override
  getAssertion(challenge, rpId, {allowCredentialIds}) {
    return const MethodChannel('challenge_signer').invokeMethod('getAssertion', {
      'challenge': challenge,
      'rpId': rpId,
      'allowCredentialIds': allowCredentialIds,
    }).then((result) => Assertion.fromMap(result));
  }
}
