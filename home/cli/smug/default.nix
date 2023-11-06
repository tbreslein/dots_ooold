{ config, lib, ... }:

let
  plainDev = {
    name = "dev";
    panes = [ "-" ];
  };
  rustDev = {
    name = "dev";
    panes = [ "-" "- commands: [bacon]" ];
  };
  plainSh = {
    name = "sh";
    panes = [ "-" ];
  };
  npmRunServe = {
    name = "server";
    panes = [ "- commands: [npm run serve]" ];
  };
  defaultWindows = [ plainDev plainSh ];

  mkWindow = { name, panes, root ? "." }:
    "\n  - name: ${name}\n    root: ${root}\n    panes:\n"
    + lib.concatStringsSep "\n" (map (x: "      " + x) panes);

  mkSmug = name: root: windows: {
    target = "${config.home.homeDirectory}/.config/smug/${name}.yml";
    text = ''
      ---
      session: ${name}
      root: ~/${root}
      windows: ${lib.concatStringsSep "\n" (map mkWindow windows)}
    '';
  };

in {
  home.file = {
    smug_notes = mkSmug "notes" "syncthing/notes" [ plainDev ];
    smug_dots = mkSmug "dots" "dots" defaultWindows;
    smug_corries = mkSmug "corries" "coding/corries" [ rustDev plainSh ];
    smug_tdos = mkSmug "tdos" "coding/tdos" [ rustDev plainSh ];
    smug_frankenrepo = mkSmug "frankenrepo" "coding/frankenrepo" defaultWindows;
    smug_frankenrepo-dev = mkSmug "frankenrepo.dev" "coding/frankenrepo.dev"
      (defaultWindows ++ [ npmRunServe ]);
    smug_capturedlambda = mkSmug "capturedlambda" "coding/capturedlambda"
      (defaultWindows ++ [ npmRunServe ]);
    smug_planning = mkSmug "planning" "work/planning" (defaultWindows ++ [{
      name = "moco";
      root = "../MocoTrackingClient";
      panes = [ "- commands: [poetry run python moco_client.py]" ];
    }]);
  };
}
