Heaven with Hell: Haskell Packages with C Sources
-------------------------------------------------
Bugs are constantly being created and fixed. Software is constantly being adapted for new use cases and new architectures. 

"Fixing" packages in nix requires the solution of a constraints problem (which may have many solutions including
wait until it fixes itself), solving the configurations and incantations required to get nix to build the package,
and in some cases fixing the source code or configuration of the package itself. 

Or you can wait until the problem becomes undefined because the ground has shifted
and other things are breaking.

Just to duplicate breifly the documentations

```
stdenv.mkDeriviation {
    pname = "libfoo";
    version = "1.2.3";
    ...
    buildInputs = [perl ncurses]
}
```

buildInputs is then meant to take care of the business of ensuring the bin directories of
those inputs git put on the path and that the include files are included in CFLAGS etc as well.

This is the promise of nix that if the software packages you require are built in a way that approximates
discretion and sanity by the low bar of the UNIX moral universe (i.e. binaries are in /bin, include files are in /include)
nix, nixpkgs, will be able to fetch them and build them and hash them and put them in a store where they reside for ever more
ready for use and enjoyment.


So Where are Build Inputs for the Haskell Packages?
--------------------------------------------------------
Let's search:

```
repo:NixOS/nixpkgs path:/development/haskell-modules buildInputs
```

We have `pkgs/development/haskell-modules/lib/compose.nix` what does compse do?
Well it takes hackage-packages.nix and constructs a full package set out of that. 


So whats the issue? Well the cabal file defines this thing:

```
executable utf8-troubleshoot
  main-is: Main.hs
  other-modules:
      Paths_with_utf8
  hs-source-dirs:
      app/utf8-troubleshoot
  ghc-options: -Wall -Wcompat -Wincomplete-record-updates -Wincomplete-uni-patterns -Wredundant-constraints
  c-sources:
      app/utf8-troubleshoot/cbits/locale.c
  build-depends:
      base >=4.10 && <4.21
    , directory >=1.2.5.0 && <1.4
    , filepath >=1.0 && <1.6
    , process >=1.0.1.1 && <1.7
    , safe-exceptions
    , text >=0.7 && <2.2
    , th-env >=0.1.0.0 && <0.2
  default-language: Haskell2010
```

Which has a c-source.

This lib has a flake so what If I check it out directly and play around with it a bit?


Well if we examine contents of hackage packages lets pick one:

```
  "BerkeleyDB" = callPackage
    ({ mkDerivation, base, bytestring, db, extensible-exceptions }:
     mkDerivation {
       pname = "BerkeleyDB";
       version = "0.8.7";
       sha256 = "0q1qc6rds05bkxl2m3anp7x75cwinp9nhy8j0g1vaj2scasvki62";
       libraryHaskellDepends = [ base bytestring extensible-exceptions ];
       librarySystemDepends = [ db ];
       description = "Berkeley DB binding";
       license = lib.licenses.bsd3;
     }) {inherit (pkgs) db;};
```



callPackage 
