import 'shared.dart';

import 'challenge_signer_platform_interface.dart';

export 'shared.dart';

class ChallengeSigner {
  const ChallengeSigner();

  /// Creates a new credential for the given user and relying party, using the given challenge.
  Future<Credential> createCredential(String applicationName) {
    return ChallengeSignerPlatform.instance.createCredential(applicationName);
  }

  /// Gets an assertion for the given challenge.
  Future<Assertion> getAssertion(String challenge, String rpId, {List<List<int>>? allowCredentialIds}) {
    return ChallengeSignerPlatform.instance.getAssertion(challenge, rpId, allowCredentialIds: allowCredentialIds);
  }
}
