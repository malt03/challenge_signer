import 'dart:convert';
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
  createCredential(applicationName) async {
    final dummy = Uint8List.fromList(utf8.encode("dummy")).buffer;

    final publicKey = {
      'challenge': dummy,
      'rp': {'name': applicationName},
      'user': {
        'id': dummy,
        'name': 'dummy',
        'displayName': 'dummy',
      },
      'pubKeyCredParams': [
        {'type': 'public-key', 'alg': -7}
      ],
      'timeout': 60000,
      'attestation': 'none',
    };

    final PublicKeyCredential credential = await window.navigator.credentials!.create({'publicKey': publicKey});
    final response = credential.response as AuthenticatorAttestationResponse;

    return Credential(
      credentialId: credential.rawId!.asUint8List(),
      attestationObject: response.attestationObject!.asUint8List(),
    );
  }

  @override
  getAssertion(challenge, rpId, {allowCredentialIds}) async {
    final publicKey = {
      'allowCredentials': allowCredentialIds?.map((id) => {'id': Uint8List.fromList(id).buffer, 'type': 'public-key'}).toList(),
      'challenge': Uint8List.fromList(utf8.encode(challenge)).buffer,
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
