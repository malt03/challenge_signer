import 'package:flutter_test/flutter_test.dart';
import 'package:challenge_signer/challenge_signer.dart';
import 'package:challenge_signer/challenge_signer_platform_interface.dart';
import 'package:challenge_signer/challenge_signer_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockChallengeSignerPlatform
    with MockPlatformInterfaceMixin
    implements ChallengeSignerPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final ChallengeSignerPlatform initialPlatform = ChallengeSignerPlatform.instance;

  test('$MethodChannelChallengeSigner is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelChallengeSigner>());
  });

  test('getPlatformVersion', () async {
    ChallengeSigner challengeSignerPlugin = ChallengeSigner();
    MockChallengeSignerPlatform fakePlatform = MockChallengeSignerPlatform();
    ChallengeSignerPlatform.instance = fakePlatform;

    expect(await challengeSignerPlugin.getPlatformVersion(), '42');
  });
}
