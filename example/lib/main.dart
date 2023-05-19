import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:challenge_signer/challenge_signer.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends HookWidget {
  MyApp({super.key});

  final _challengeSignerPlugin = const ChallengeSigner();
  final challenge =
      '9Y7e5kWqO/ceoa4YGuxxJAHGqdIjHtfoTdJ2+LlybPNHkFM8gL/H1PBuinYYK2Y9HOIjHfoXdt6jB4LTVCBDPF17J5hLOxgHrA7XlizLKJHvtaLyshiRlw1MwTJ2+1kz5eLTBdr8dVTmmbA5PBfJATcux9oYnJ77bSFQunSzCU1BYqz8NQXAqssUoLzGZtcN2YiBPJk65qNxgRv3+jsyDXIOjHeaUmN1VgK0BtAPKbi+6cich3W+Trxfq5WmfqQ2AAit/qthwAfgjQ/AXOc7UyeQKnKn8m4SxMS7wY09yjBsAwSHiEq6DURRZcfjJVH8NJxOsJf6TXoVOSBvQ9RSLQ==';
  final rp = const RelyingParty(
    id: 'localhost',
    name: 'Password Manager',
  );
  final user = User(
    displayName: 'malt03',
    name: 'malt03',
    id: base64Decode('xn+DY5YPvnvfnfmyM3VyB2fRXU4pPFKJAfc1daxfAjA='),
  );

  @override
  Widget build(BuildContext context) {
    final credentialIdState = useState<List<int>?>(null);
    final credentialId = credentialIdState.value;

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              Text(credentialId == null ? 'null' : base64Encode(credentialId)),
              TextButton(
                child: const Text('Register'),
                onPressed: () async {
                  final credential = await _challengeSignerPlugin.createCredential(base64Decode(challenge), rp, user);
                  credentialIdState.value = credential.credentialId;
                },
              ),
              TextButton(
                child: const Text('Login'),
                onPressed: () async {
                  if (credentialId == null) return;
                  final assertion = await _challengeSignerPlugin.getAssertion(
                    base64Decode(challenge),
                    rp.id,
                    allowCredentialIds: [credentialId],
                  );
                  print(assertion);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
