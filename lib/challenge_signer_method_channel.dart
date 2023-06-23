import 'dart:convert';
import 'package:convert/convert.dart';

import 'package:cbor/cbor.dart';
import 'package:uuid/uuid.dart';
import 'package:cryptography/helpers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import "dart:math";

import 'package:cryptography/cryptography.dart' as c;
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

  Uint8List _seed() {
    var random = Random.secure();
    var seed = List<int>.generate(32, (_) => random.nextInt(256));
    return Uint8List.fromList(seed);
  }

  @override
  createCredential(applicationName) async {
    final id = utf8.encode(const Uuid().v4());
    final idLength = ByteData(2);
    idLength.setUint16(0, id.length);

    var random = FortunaRandom();
    random.seed(KeyParameter(_seed()));

    final keyGenerator = ECKeyGenerator()..init(ParametersWithRandom(ECKeyGeneratorParameters(ECCurve_prime256v1()), random));
    final keyPair = keyGenerator.generateKeyPair();
    final publicKey = keyPair.publicKey as ECPublicKey;

    // final algorithm = Ecdsa.p256(Sha256());
    // final keyPair = await algorithm.newKeyPair();
    // final publicKey = await keyPair.extractPublicKey();

    // x.setUint32(0, publicKey.Q.x.toBigInteger().toInt());
    final coseKey = CborMap({
      const CborSmallInt(1): const CborSmallInt(2),
      const CborSmallInt(3): const CborSmallInt(-7),
      const CborSmallInt(-1): const CborSmallInt(1),
      const CborSmallInt(-2): CborBytes(hex.decode(publicKey.Q!.x!.toBigInteger()!.toRadixString(16))),
      const CborSmallInt(-3): CborBytes(hex.decode(publicKey.Q!.y!.toBigInteger()!.toRadixString(16))),
    });

    KeyPairStore.instance.keyPair = keyPair;

    List<int> attestedCredentialData = randomBytes(16);
    attestedCredentialData += idLength.buffer.asUint8List();
    attestedCredentialData += id;
    attestedCredentialData += cborEncode(coseKey);

    List<int> authData = randomBytes(37);
    authData += attestedCredentialData;

    final attestationObject = CborMap({CborString("authData"): CborBytes(authData)});

    return Credential(credentialId: utf8.encode("dummy"), attestationObject: cborEncode(attestationObject));
    // return const MethodChannel('challenge_signer').invokeMethod('createCredential', {
    //   'applicationName': applicationName,
    // }).then((result) => Credential.fromMap(result));
  }

  @override
  getAssertion(challenge, rpId, {allowCredentialIds}) async {
    final clientData = {"challenge": challenge};
    final clientDataJson = utf8.encode(jsonEncode(clientData));
    final authenticatorData = randomBytes(37);

    final hashAlgorithm = c.Sha256();
    final clientDataJsonHash = await hashAlgorithm.hash(clientDataJson);

    // final algorithm = Ed25519();
    // final keyPair = KeyPairStore.instance.keyPair!;
    // final signature = await algorithm.sign(authenticatorData + clientDataJsonHash.bytes, keyPair: keyPair);

    // final ok = await algorithm.verify(authenticatorData + clientDataJsonHash.bytes, signature: signature);
    // print(ok);

    ECPrivateKey privateKey = KeyPairStore.instance.keyPair!.privateKey as ECPrivateKey;

    // some bytes to sign
    final bytes = Uint8List.fromList(authenticatorData + clientDataJsonHash.bytes);

    // a suitable random number generator - create it just once and reuse
    final rand = Random.secure();
    final fortunaPrng = FortunaRandom()
      ..seed(KeyParameter(Uint8List.fromList(List<int>.generate(
        32,
        (_) => rand.nextInt(256),
      ))));

    // the ECDSA signer using SHA-256
    final signer = ECDSASigner(SHA256Digest())
      ..init(
        true,
        ParametersWithRandom(
          PrivateKeyParameter(privateKey!),
          fortunaPrng,
        ),
      );

    // sign the bytes
    final ecSignature = signer.generateSignature(bytes) as ECSignature;

    // encode the two signature values in a common format
    // hopefully this is what the server expects
    final encoded = ASN1Sequence(elements: [
      ASN1Integer(ecSignature.r),
      ASN1Integer(ecSignature.s),
    ]).encode();

    return Assertion(
      credentialId: utf8.encode("dummy"),
      clientData: clientDataJson,
      authenticatorData: authenticatorData,
      signature: encoded,
    );
    // return const MethodChannel('challenge_signer').invokeMethod('getAssertion', {
    //   'challenge': challenge,
    //   'rpId': rpId,
    //   'allowCredentialIds': allowCredentialIds,
    // }).then((result) => Assertion.fromMap(result));
  }
}
