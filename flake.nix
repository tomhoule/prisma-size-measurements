{
  description = "A very basic flake indeed";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages."${system}";
        inherit (pkgs) podman;
        runInContainer = (name: script:
          let scriptFile = pkgs.writeText "scriptFile" script; in
          pkgs.writeShellScriptBin name ''
            OUTDIR=$(mktemp -d)
            echo "#!/bin/bash" > $OUTDIR/script.sh
            cat ${scriptFile} >> $OUTDIR/script.sh
            chmod +x $OUTDIR/script.sh
            docker run --rm -it -v /nix:/nix -v $OUTDIR:/root --entrypoint=bash docker.io/node:lts -c 'cd /root; echo "running the script"; ./script.sh'


            echo "=============================="
            echo "ℹ️  Output written to $OUTDIR"
            echo "=============================="
          '');
      in
      {
        packages = {
          vanillaSize = runInContainer "vanillaSize" ''
            npm i prisma
          '';

          smallVanillaPrismaClient = runInContainer "vanillaSize" ''
            npm i prisma
            cp ${./small_schema.prisma} schema.prisma
            cat << EOF >> schema.prisma
              generator jsclient {
                provider = "prisma-client-js"
              }
            EOF
            npx prisma generate
          '';

          largeVanillaPrismaClient = runInContainer "vanillaSize" ''
            npm i prisma
            cp ${./large_schema.prisma} schema.prisma
            cat << EOF >> schema.prisma
              generator jsclient {
                provider = "prisma-client-js"
              }
            EOF
            npx prisma generate
          '';

          smallEdgePrismaClient = runInContainer "vanillaSize" ''
            npm i prisma
            cp ${./small_schema.prisma} schema.prisma
            cat << EOF >> schema.prisma
              generator jsclient {
                provider = "prisma-client-js"
              }
            EOF
            npx prisma generate --data-proxy
          '';

          largeEdgePrismaClient = runInContainer "vanillaSize" ''
            npm i prisma
            cp ${./large_schema.prisma} schema.prisma
            cat << EOF >> schema.prisma
              generator jsclient {
                provider = "prisma-client-js"
              }
            EOF
            npx prisma generate --data-proxy
          '';

          inherit (pkgs) diskonaut;
        };
      });
}
