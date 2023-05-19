//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <challenge_signer/challenge_signer_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) challenge_signer_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "ChallengeSignerPlugin");
  challenge_signer_plugin_register_with_registrar(challenge_signer_registrar);
}
