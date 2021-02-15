// ©2019-2020 Actonica LLC - All Rights Reserved

class Secret {
  final String encryptedData;

  Secret(
    this.encryptedData,
  );

  @override
  String toString() {
    return 'Secret{encryptedData: $encryptedData}';
  }
}
