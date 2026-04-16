# SKSE Plugin Template

A CommonLibSSE plugin template using [xmake](https://xmake.io) as the build system, with integration of [styyx-utils](https://github.com/Styyx1/StyyxUtils).

Supports **Skyrim 1.5.97**, **Skyrim 1.6.1130+**, and optionally **Skyrim VR** from a single codebase but with separate DLLs.
Flat Skyrim builds use the `lib/commonlibsse` submodule. VR builds use the `lib/commonlibVR` submodule. The two CommonLib submodules are selected by build config and are not included at the same time.

---

## Prerequisites

| Tool                                                      | Notes                                             |
| --------------------------------------------------------- | ------------------------------------------------- |
| [Visual Studio 2022](https://visualstudio.microsoft.com/) | With the**Desktop development with C++** workload |
| [xmake](https://xmake.io/#/guide/installation)            | v2.8.2 or later                                   |
| [Git](https://git-scm.com/)                               | For general interaction with github               |

---

## Getting Started

### 1. Create your repository

Click **"Use this template"** at the top of this repository on GitHub, then clone your newly created repo:
```bash
git clone --recurse-submodules https://github.com/your-name/your-plugin-name
cd your-plugin-name
```

The ``--recurse-submodules`` is important, it pulls in CommonLibSSE, CommonLibVR, and styyx-utils automatically.

**Cloning directly?** If you cloned without the flag, run:
```bash
git submodule update --init --recursive
```

### 2. Configure the project

For **Skyrim AE** (default):

```bash
xmake f --skyrim_ae=true
```

For **Skyrim SE**:

```bash
xmake f --skyrim_ae=false
```

For **Skyrim VR**:

```bash
xmake f --skyrim_vr=true
```

### 3. Build

```bash
xmake
```

The compiled ``.dll`` and ``.pdb`` are automatically copied to:
```
Distr/AE/SKSE/Plugins/   (AE build)
Distr/SE/SKSE/Plugins/   (SE build)
Distr/VR/SKSE/Plugins/   (VR build)
```

### 4. Rename the plugin

In ``xmake.lua``, replace all occurrences of ``plugin-template`` with your plugin name:

```lua
set_project("your-plugin-name")

target("your-plugin-name")
    add_rules("commonlibsse.plugin", {
        name = "your-plugin-name",
        author = "your-name",
        description = "Your plugin description."
    })
```

---

## xmake Config Options

Set options with `xmake f --option=value` before building, or use ``set_config("setting_name", true/false)`` in the xmake.lua

| Option | Default | Description |
| -       |-         | -            |
| ``skyrim_ae``| ``true`` | Target Skyrim AE. Set to``false`` for SE |
| ``skyrim_vr``| ``false`` | Target Skyrim VR. This switches the CommonLib dependency from `lib/commonlibsse` to `lib/commonlibVR` |
| ``use-hook-utils``| ``false`` | Enable hooking utilities from styyx-utils (pulls in xbyak) |
| ``skse_xbyak``| ``false`` | Enable xbyak support in CommonLibSSE directly |
| ``rex_toml``| ``false`` | Enable TOML config file support via CommonLibSSE |
| ``rex_json``| ``false`` | Enable JSON config file support via CommonLibSSE |
| ``rex_ini``| ``false`` | Enable INI config file support via CommonLibSSE |

### Example: Enable hook utilities

```bash
xmake f --skyrim_ae=true --use-hook-utils=true
xmake
```
or in xmake.lua
```lua
set_config("use-hook-utils", true)
```

---

## Build both game versions

To build both SE and AE versions in one step:

```bash
xmake shiprelease
```

This will:

1. Build the AE version → `Distr/AE/SKSE/Plugins/`
2. Build the SE version → `Distr/SE/SKSE/Plugins/`
3. Restore the default AE configuration

To build only Skyrim VR:

```bash
xmake shiprelease-vr
```

This builds the VR version to `Distr/VR/SKSE/Plugins/`.

---

## Runtime differences

Use `SKSE_TEMPLATE_SKYRIM_SE`, `SKSE_TEMPLATE_SKYRIM_AE`, or `SKSE_TEMPLATE_SKYRIM_VR` when your plugin needs runtime-specific code paths.

For relocation values, the template provides:

```cpp
REL_ID(se, ae)
REL_ID_3(se, ae, vr)
OFFSET(se, ae)
OFFSET_3(se, ae, vr)
```

---

## styyx-utils

This template includes [styyx-utils](https://github.com/Styyx1/StyyxUtils) as a submodule, a header-only utility library for CommonLibSSE plugin development. It provides helpers for actors, cells, forms, magic, menus, timers, and more.

To use it, simply include the main header in your precompiled header:

mind, using the main header does not pull in ``st-ui.h`` which could be used for SKSE Menu Framework integration

```cpp
#include <styyx-utils.h>
```

If you enabled `use-hook-utils`, hooking utilities are available via:

```cpp
#include <st-hooks.h>
```

---

## License

[MIT](LICENSE)

## Contributions

PRs are welcome
