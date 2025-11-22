{
  description = "Dummy private flake for CI";

  outputs =
    { self }:
    let
      dummy = { ... }: { };
    in
    {
      nixosModule = dummy;
      nixosModules.default = self.nixosModule;
      homeModule = dummy;
      homeManagerModules.default = self.homeModule;
    };
}
