{
  description = "Dummy private flake for CI";

  outputs = { self }:
    let dummy = { ... }: { }; in
    {
      nixosModule = dummy;
      nixosModules.defaultModule = self.nixosModule;
      homeModule = dummy;
      homeModules.defaultModule = self.homeModule;
    };
}
