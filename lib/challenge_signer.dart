import 'shared.dart';

import 'challenge_signer_platform_interface.dart';

export 'shared.dart';

class ChallengeSigner {
  const ChallengeSigner();

  /// Creates a new credential for the given user and relying party, using the given challenge.
  Future<Credential> createCredential(List<int> challenge, RelyingParty rp, User user) {
    return ChallengeSignerPlatform.instance.createCredential(challenge, rp, user);
  }

  /// Gets an assertion for the given challenge.
  Future<Assertion> getAssertion(List<int> challenge, String rpId, {List<List<int>>? allowCredentialIds}) {
    return ChallengeSignerPlatform.instance.getAssertion(challenge, rpId, allowCredentialIds: allowCredentialIds);
  }
}
