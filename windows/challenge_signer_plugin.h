#ifndef FLUTTER_PLUGIN_CHALLENGE_SIGNER_PLUGIN_H_
#define FLUTTER_PLUGIN_CHALLENGE_SIGNER_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace challenge_signer {

class ChallengeSignerPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  ChallengeSignerPlugin();

  virtual ~ChallengeSignerPlugin();

  // Disallow copy and assign.
  ChallengeSignerPlugin(const ChallengeSignerPlugin&) = delete;
  ChallengeSignerPlugin& operator=(const ChallengeSignerPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace challenge_signer

#endif  // FLUTTER_PLUGIN_CHALLENGE_SIGNER_PLUGIN_H_
