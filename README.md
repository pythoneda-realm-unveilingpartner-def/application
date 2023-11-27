# pythoneda-realm-unveilingpartner/application

Definition of <https://github.com/pythoneda-realm-unveilingpartner/application>.

## How to declare it in your flake

Check the latest tag of this repository and use it instead of the `[version]` placeholder below.

```nix
{
  description = "[..]";
  inputs = rec {
    [..]
    pythoneda-realm-unveilingpartner-application = {
      [optional follows]
      url =
        "github:pythoneda-realm-unveilingpartner-def/application/[version]";
    };
  };
  outputs = [..]
};
```

Should you use another PythonEDA modules, you might want to pin those also used by this project. The same applies to [nixpkgs](https://github.com/nixos/nixpkgs "nixpkgs") and [flake-utils](https://github.com/numtide/flake-utils "flake-utils").

Use the specific package depending on your system (one of `flake-utils.lib.defaultSystems`) and Python version:

- `#packages.[system].pythoneda-realm-unveilingpartner-application-python38` 
- `#packages.[system].pythoneda-realm-unveilingpartner-application-python39` 
- `#packages.[system].pythoneda-realm-unveilingpartner-application-python310` 
- `#packages.[system].pythoneda-realm-unveilingpartner-application-python311` 

## How to run pythoneda-realm-unveilingpartner/realm

``` sh
nix run 'https://github.com/pythoneda-realm-unveilingpartner-def/application/[version]'
```

### Usage

``` sh
nix run https://github.com/pythoneda-realm-unveilingpartner-def/application/[version] [-h|--help] [-r|--repository-folder folder] [-e|--event event] [-t|--tag tag]
```
- `-h|--help`: Prints the usage.
- `-r|--repository-folder`: The folder where <https://github.com/pythoneda-realm-unveilingpartner/realm> is cloned.
- `-e|--event`: The event to send. See <https://github.com/pythoneda-shared-artifact/events>.
- `-t|--tag`: If the event is `TagPushed`, specify the tag.
