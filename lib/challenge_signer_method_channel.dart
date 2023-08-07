import 'dart:convert';
import "dart:math";

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:cbor/cbor.dart';
import "package:pointycastle/export.dart";
import 'package:pointycastle/asn1.dart';

import 'shared.dart';
import 'challenge_signer_platform_interface.dart';

class KeyPairStore {
  static final instance = KeyPairStore._();

  KeyPairStore._();

  AsymmetricKeyPair<PublicKey, PrivateKey>? keyPair;
}

class MethodChannelChallengeSigner extends ChallengeSignerPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('challenge_signer');

  static List<int> _randomBytes(int length) {
    final random = Random();
    return List<int>.generate(length, (_) => random.nextInt(256));
  }

  static Uint8List _seed() {
    final random = Random.secure();
    final seed = Uint8List(32);
    for (var i = 0; i < 32; i++) {
      seed[i] = random.nextInt(256);
    }
    return seed;
  }

  static Uint8List _bigIntToBytes(BigInt number) {
    final bytes = (number.bitLength + 7) >> 3;
    final b256 = BigInt.from(256);
    final result = Uint8List(bytes);
    for (var i = 0; i < bytes; i++) {
      result[bytes - 1 - i] = number.remainder(b256).toInt();
      number = number >> 8;
    }
    return result;
  }

  @override
  createCredential(applicationName) async {
    // return const MethodChannel('challenge_signer').invokeMethod('createCredential', {
    //   'applicationName': applicationName,
    // }).then((result) => Credential.fromMap(result));

    final id = _randomBytes(16);
    final idLength = ByteData(2);
    idLength.setUint16(0, id.length);

    var random = FortunaRandom();
    random.seed(KeyParameter(_seed()));

    final keyGenerator = ECKeyGenerator()..init(ParametersWithRandom(ECKeyGeneratorParameters(ECCurve_prime256v1()), random));
    final keyPair = keyGenerator.generateKeyPair();
    final publicKey = keyPair.publicKey as ECPublicKey;

    final coseKey = CborMap({
      const CborSmallInt(1): const CborSmallInt(2),
      const CborSmallInt(3): const CborSmallInt(-7),
      const CborSmallInt(-1): const CborSmallInt(1),
      const CborSmallInt(-2): CborBytes(_bigIntToBytes(publicKey.Q!.x!.toBigInteger()!)),
      const CborSmallInt(-3): CborBytes(_bigIntToBytes(publicKey.Q!.y!.toBigInteger()!)),
    });

    KeyPairStore.instance.keyPair = keyPair;
    (keyPair.privateKey as ECPrivateKey);

    List<int> attestedCredentialData = _randomBytes(16);
    attestedCredentialData += idLength.buffer.asUint8List();
    attestedCredentialData += id;
    attestedCredentialData += cborEncode(coseKey);

    List<int> authData = _randomBytes(37);
    authData += attestedCredentialData;

    final attestationObject = CborMap({CborString("authData"): CborBytes(authData)});

    return Credential(credentialId: utf8.encode("dummy"), attestationObject: cborEncode(attestationObject));
  }

  @override
  getAssertion(challenge, rpId, {allowCredentialIds}) async {
    final clientData = {"challenge": challenge};
    final clientDataJson = utf8.encode(jsonEncode(clientData));
    final authenticatorData = _randomBytes(37);

    final clientDataJsonHash = SHA256Digest().process(Uint8List.fromList(clientDataJson));

    final fortunaRandom = FortunaRandom()..seed(KeyParameter(_seed()));

    final privateKey = KeyPairStore.instance.keyPair!.privateKey as ECPrivateKey;
    final signer = ECDSASigner(SHA256Digest())
      ..init(true, ParametersWithRandom(PrivateKeyParameter(privateKey), fortunaRandom));

    final message = Uint8List.fromList(authenticatorData + clientDataJsonHash);
    final ecSignature = signer.generateSignature(message) as ECSignature;
    final signature = ASN1Sequence(elements: [ASN1Integer(ecSignature.r), ASN1Integer(ecSignature.s)]).encode();

    return Assertion(
      credentialId: utf8.encode("dummy"),
      clientData: clientDataJson,
      authenticatorData: authenticatorData,
      signature: signature,
    );
    // return const MethodChannel('challenge_signer').invokeMethod('getAssertion', {
    //   'challenge': challenge,
    //   'rpId': rpId,
    //   'allowCredentialIds': allowCredentialIds,
    // }).then((result) => Assertion.fromMap(result));
  }
}
