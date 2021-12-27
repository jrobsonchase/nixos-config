{
  description = "Dummy private flake for CI";

  outputs = { self }: {
    nixosModule = { ... }: {};
    nixosModules.defaultModule = self.nixosModule;
  };
}
