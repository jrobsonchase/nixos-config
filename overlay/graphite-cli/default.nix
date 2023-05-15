{ pkgs }:
let
  nodePackages = pkgs.callPackage ./node_packages { };
  graphite-cli = nodePackages."@withgraphite/graphite-cli";
in
graphite-cli // {
  meta = graphite-cli.meta // {
    name = "graphite-cli";
    license = "AGPL";
    description = "Graphite is a fast, simple code review platform designed for engineers who want to write and review smaller pull requests, stay unblocked, and ship faster.";
  };
}
