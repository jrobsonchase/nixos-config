{ lib }:
{
  toKDL = {}:
    let
      inherit (lib) concatStringsSep;
      inherit (builtins) typeOf replaceStrings elem;

      # KDL Spec Summary
      # Document -> Node[]
      # Node -> {[Type] NodeName [Args] [Properties] [Children]}
      # Type -> Ident
      # NodeName -> Ident
      # Args -> Value[] # Note: ordered
      # Properties -> map[Ident]Value # Note: Unordered
      # Children -> Node[] # Note: ordered
      # Value -> String | Number | Bool | Null

      # ListOf String -> String
      indentStrings =
        let
          # Although the input of this function is a list of strings,
          # the strings themselves *will* contain newlines, so you need
          # to normalize the list by joining and resplitting them.
          unlines = lib.splitString "\n";
          lines = lib.concatStringsSep "\n";
          indentAll = lines: concatStringsSep "\n" (map (x: "	" + x) lines);
        in
        stringsWithNewlines: indentAll (unlines (lines stringsWithNewlines));

      # String -> String
      sanitizeString = replaceStrings [ "\n" ''"'' ] [ "\\n" ''\"'' ];

      # OneOf [Int Float String Bool Null] -> String
      literalValueToString = element:
        lib.throwIfNot
          (elem (typeOf element) [ "int" "float" "string" "bool" "null" ])
          "Cannot convert value of type ${typeOf element} to KDL literal."
          (if typeOf element == "null" then
            "null"
          else if element == false then
            "false"
          else if element == true then
            "true"
          else if typeOf element == "string" then
            ''"${sanitizeString element}"''
          else
            toString element);

      # Node Attrset Conversion
      # AttrsOf Anything -> String
      attrsToKDLNode = attrs:
        let
          optType = lib.optionalString (attrs ? "type") attrs.type;

          name = attrs.name;

          optArgsString = lib.optionalString (attrs ? "args")
            (lib.pipe attrs.args [
              (map literalValueToString)
              (lib.concatStringsSep " ")
            ]);

          optPropsString = lib.optionalString (attrs ? "props")
            (lib.pipe attrs.props [
              (lib.mapAttrsToList
                (name: value: "${name}=${literalValueToString value}"))
              (lib.concatStringsSep " ")
            ]);

          optChildren = lib.optionalString (attrs ? "children")
            (lib.pipe attrs.children [
              (map attrsToKDLNode)
              (s: ''
                {
                ${indentStrings s}
                }'')
            ]);

        in
        lib.concatStringsSep " " (lib.filter (s: s != "") [
          optType
          name
          optArgsString
          optPropsString
          optChildren
        ]);

    in
    nodes: ''
      ${concatStringsSep "\n" (map attrsToKDLNode nodes)}
    '';
}
