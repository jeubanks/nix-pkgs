{ pkgs }:

let
  byNameDir = ./by-name;

  isDirectory = path:
    (builtins.readDir path) == "directory";

  packageEntriesForGroup = group:
    let
      groupPath = byNameDir + "/${group}";
      names = builtins.attrNames (builtins.readDir groupPath);
      packageNames = builtins.filter (name:
        (builtins.readDir groupPath)."${name}" == "directory"
        && builtins.pathExists (groupPath + "/${name}/package.nix")
      ) names;
    in
      map (name: {
        inherit name;
        path = groupPath + "/${name}/package.nix";
      }) packageNames;

  groups = builtins.filter (group:
    (builtins.readDir byNameDir)."${group}" == "directory"
  ) (builtins.attrNames (builtins.readDir byNameDir));

  packageEntries = builtins.concatLists (map packageEntriesForGroup groups);
in
builtins.listToAttrs (map (entry: {
  name = entry.name;
  value = pkgs.callPackage entry.path { };
}) packageEntries)
