class User {
  final List<int> id;
  final String name;
  final String displayName;

  const User({required this.id, required this.name, required this.displayName});

  dynamic toMap() {
    return {'id': id, 'name': name, 'displayName': displayName};
  }
}

class RelyingParty {
  final String id;
  final String name;

  const RelyingParty({required this.id, required this.name});

  dynamic toMap() {
    return {'id': id, 'name': name};
  }
}

class Credential {
  final List<int> credentialId;
  final List<int> publicKey;
  final List<int> clientData;

  const Credential({required this.credentialId, required this.publicKey, required this.clientData});
  Credential.fromMap(dynamic map)
      : this(
          credentialId: map['credentialId'],
          publicKey: map['publicKey'],
          clientData: map['clientData'],
        );
}

class Assertion {
  final List<int> credentialId;
  final List<int> clientData;
  final List<int> authenticatorData;
  final List<int> signature;

  const Assertion({
    required this.credentialId,
    required this.clientData,
    required this.authenticatorData,
    required this.signature,
  });
  Assertion.fromMap(dynamic map)
      : this(
          credentialId: map['credentialId'],
          clientData: map['clientData'],
          authenticatorData: map['authenticatorData'],
          signature: map['signature'],
        );
}
