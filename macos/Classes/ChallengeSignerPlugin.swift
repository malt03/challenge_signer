import Cocoa
import FlutterMacOS

public class ChallengeSignerPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "challenge_signer", binaryMessenger: registrar.messenger)
    let instance = ChallengeSignerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "write":
      let access = SecAccessControlCreateWithFlags(
        nil,
        kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
        .userPresence,
        nil
      )
      let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccessControl as String: access as Any,
        kSecAttrService as String: "KeyChainSandbox",
        kSecAttrAccount as String: "dummy-account",
        kSecValueData as String: "dummy-value".data(using: .utf8)!,
      ]
      let status = SecItemAdd(query as CFDictionary, nil)
      guard status == errSecSuccess else {
        result(FlutterError(code: String(status), message: "Keychain error", details: nil))
        return
      }
    case "read":
      let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrService as String: "KeyChainSandbox",
        kSecAttrAccount as String: "dummy-account",
        kSecMatchLimit as String: kSecMatchLimitOne,
        kSecReturnData as String: true,
      ]
      var item: CFTypeRef?
      let status = SecItemCopyMatching(query as CFDictionary, &item)
      guard status == errSecSuccess else { 
        result(FlutterError(code: String(status), message: "Keychain error", details: nil))
        return
      }
      // print(String(data: item as! Data, encoding: .utf8))
    default:
      print(call.arguments!)
      result(["Hello", "World"])
      // result(FlutterMethodNotImplemented)
    }
  }
}
