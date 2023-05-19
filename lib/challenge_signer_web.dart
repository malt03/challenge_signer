import 'dart:html';
import 'dart:typed_data';

import 'shared.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'challenge_signer_platform_interface.dart';

class ChallengeSignerWeb extends ChallengeSignerPlatform {
  static void registerWith(Registrar registrar) {
    ChallengeSignerPlatform.instance = ChallengeSignerWeb();
  }

  @override
  createCredential(challenge, rp, user) async {
    final publicKey = {
      'challenge': Uint8List.fromList(challenge).buffer,
      'rp': rp.toMap(),
      'user': {
        'id': Uint8List.fromList(user.id).buffer,
        'name': user.name,
        'displayName': user.displayName,
      },
      'pubKeyCredParams': [
        {'type': 'public-key', 'alg': -7}
      ],
      'timeout': 60000,
      'attestation': 'none',
    };

    final PublicKeyCredential credential = await window.navigator.credentials!.create({'publicKey': publicKey});
    final AuthenticatorAttestationResponse response = credential.response as AuthenticatorAttestationResponse;

    return Credential(
      credentialId: credential.rawId!.asUint8List(),
      publicKey: response.attestationObject!.asUint8List(),
      clientData: response.clientDataJson!.asUint8List(),
    );
  }

  @override
  getAssertion(challenge, rpId, {allowCredentialIds}) async {
    final publicKey = {
      'allowCredentials': allowCredentialIds?.map((id) => {'id': Uint8List.fromList(id).buffer, 'type': 'public-key'}).toList(),
      'challenge': Uint8List.fromList(challenge).buffer,
      'timeout': 60000,
    };

    final PublicKeyCredential credential = await window.navigator.credentials!.get({'publicKey': publicKey});
    final AuthenticatorAssertionResponse response = credential.response as AuthenticatorAssertionResponse;

    return Assertion(
      credentialId: credential.rawId!.asUint8List(),
      clientData: response.clientDataJson!.asUint8List(),
      authenticatorData: response.authenticatorData!.asUint8List(),
      signature: response.signature!.asUint8List(),
    );
  }
}
