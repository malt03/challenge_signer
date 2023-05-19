#include "include/challenge_signer/challenge_signer_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "challenge_signer_plugin.h"

void ChallengeSignerPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  challenge_signer::ChallengeSignerPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
