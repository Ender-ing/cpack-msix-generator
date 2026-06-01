# cpack-msix-generator

A custom CPack external generator implementation for natively building Windows MSIX and MSIXUpload packages.

> [!NOTE]
> Features are added to this project as needed by the [Juggernyaut Toolchain](https://github.com/Ender-ing/Juggernyaut).
>
> If you wish to add any more features, or you want to ask for them, do not hesitate!

## Usage

Attaching the generator:

```cmake
# You may load the generator as an external CPack generator
list(APPEND CPACK_GENERATOR "External")
set(CPACK_EXTERNAL_PACKAGE_SCRIPT "msix-generator-module/MSIX.cmake")
set(CPACK_EXTERNAL_ENABLE_STAGING ON)
```

Pre-generator tooling:

```cmake
# To access generator functions, you must include this file!
include("msix-generator-module/MSIXTools.cmake")
```

### CMake Fetch

If you wish to use CMake fetching to add this repository, you may do so like this:

```cmake
FetchContent_Declare(MSIXGen
    GIT_REPOSITORY https://github.com/Ender-ing/cpack-msix-generator
    GIT_TAG main # Or a commit hash!
)
FetchContent_MakeAvailable(MSIXGen)
```

And, you have two options of implementation:

```cmake
# The same as before:
list(APPEND CPACK_GENERATOR "External")
set(CPACK_EXTERNAL_PACKAGE_SCRIPT ${CPACK_MSIX_GENERATOR})
set(CPACK_EXTERNAL_ENABLE_STAGING ON)

include(${CPACK_MSIX_GENERATOR_TOOLS})
```

Or, you could use the provided preset:

```cmake
cpack_msix_preset() # This does the same thing as the code above

cpack_msix_preset(OFF) # The same, EXCEPT it makes the MSIX External Generator THE ONLY CPack generator.
```

> [!NOTE]
> In order to avoid compatibility issues when fetching from the main branch,
> it is recommended to use `cpack_msix_preset`.

### Quick Start

If you already configured your CMake build to work with cpack using other generators,
you mostly only need these variables to get the MSIX external generator to work with your existing configurations:

```cmake
# Configs
# set(CPACK_MSIX_RUNTIME_FOLDER_NAME custom/bin) # In case your default runtime folder isn't a typical root 'bin'
set(CPACK_MSIX_GENERATE_UPLOAD ON) # If you want a .msixupload file!

# Identity
set(CPACK_MSIX_PACKAGE_ARCHITECTURE "x64") # You could also use arch names like x86_64, and arm64.
set(CPACK_MSIX_PACKAGE_LOGO "C:/absolute/path/to/my/logo.png")
set(CPACK_MSIX_PACKAGE_LOGO_44 "C:/absolute/path/to/my/logo_44x44.png")
set(CPACK_MSIX_PACKAGE_LOGO_150 "C:/absolute/path/to/my/logo_150x150.png")
```

## `CPACK_MSIX_*` values

### Package generation

#### `CPACK_MSIX_PACKAGE_FILE_NAME`

- Description: The name of the generated `.msix`, `.appxsym`, and `.msixupload` files.
- Fallback: `CPACK_PACKAGE_FILE_NAME`

#### `CPACK_MSIX_RUNTIME_FOLDER_NAME`

> [!IMPORTANT]
> This value should match your build's runtime destination folder name value!
> Application implementations made through `MSIXTools.cmake` could break if
> `CPACK_MSIX_RUNTIME_FOLDER_NAME` is misconfigured!

- Description: The name of the runtime binaries folder.
- Default: `bin`

#### `CPACK_MSIX_GENERATE_UPLOAD`

> [!WARNING]
> You are allowed to generate `.msixupload` files without debug symbols,
> with the risk of getting your Microsoft Store uploads rejected!
>
> (Note that debug symbols are automatically bundled when detected)

- Description: Enable `.msixupload` generation.
- Default: `OFF`

#### `CPACK_MSIX_DEBUG_PATH_OFFSET`

> [!NOTE]
> The generator preserves the path pattern of detected debug symbol files.
> As such, the generated `.appxsym` file mirrors your binaries/libraries folder patterns.
> You may use `CPACK_MSIX_DEBUG_PATH_OFFSET` to change the root relative base for packaged debug symbol files.
>
> **For example**, if your binaries are in `/bin`, and your symbols are in `/sym/bin`,
> then you *can* define `CPACK_MSIX_DEBUG_PATH_OFFSET` to be `sym` - so the
> package generator could preserve your bin folder patterns!

- Description: Debug symbols archive path offset.
(When set to  an *empty string*, the debug symbol files in `.appxsym` are flattened!)

#### `CPACK_MSIX_APPLICATIONS` (*required*)

> [!CAUTION]
> You should not modify this by yourself!
> Please use [MSIXTools](#msix-tools) to add application implementations!

- Description: A `JSON` list of custom application implementations.
  This value will not be documented!
  You may read the contents of `MSIXTools.cmake` to figure how to add your own custom implementations.

> [!NOTE]
> You are always welcome to contribute your own custom application implementations,
> or to [ask for them to be implemented](https://github.com/Ender-ing/cpack-msix-generator/issues)!

### Package identity

#### `CPACK_MSIX_PACKAGE_VERSION`

- Fallback: `CPACK_PACKAGE_VERSION`
- Alternative: `CPACK_MSIX_PACKAGE_VERSION_*`
- Legal Pattern: `[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+`

#### `CPACK_MSIX_PACKAGE_VERSION_*`

- Components: `CPACK_MSIX_PACKAGE_VERSION_MAJOR`, `CPACK_MSIX_PACKAGE_VERSION_MINOR`,
  `CPACK_MSIX_PACKAGE_VERSION_PATCH`, `CPACK_MSIX_PACKAGE_VERSION_REVISION`
- Legal Pattern: `[0-9]+`
- Default: `0`

#### `CPACK_MSIX_PACKAGE_ARCHITECTURE` (*required*)

- Description: Sets the `ProcessorArchitecture` that your program supports.
- Legal Pattern: `x86_32|x86|x86_64|x64|arm32|arm|arm64|neutral`

#### `CPACK_MSIX_PACKAGE_NAME`

- Description: Sets the display name within the installer.
- Fallback: `CPACK_PACKAGE_NAME`

#### `CPACK_MSIX_PACKAGE_DESCRIPTION_SUMMARY`

- Description: Sets the display name within the installer.
- Fallback: `CPACK_PACKAGE_DESCRIPTION_SUMMARY`

#### `CPACK_MSIX_PACKAGE_IDENTITY_NAME`

- Description: Sets the package's identity `Name` value.
- Legal Pattern: `[a-zA-Z0-9\.-]{3,50}`
- Fallback: *Generates a legal identity name based on `CPACK_MSIX_PACKAGE_NAME`*

#### `CPACK_MSIX_PACKAGE_LOGO` (*required*)

- Description: The absolute path to a `.png` logo for your package.

#### `CPACK_MSIX_PACKAGE_LOGO_44` (*required*)

- Description: The absolute path to a 44x44 `.png` logo for your package's program aliases.

#### `CPACK_MSIX_PACKAGE_LOGO_150` (*required*)

- Description: The absolute path to a 150x150 `.png` logo for your package's program aliases.

### Publisher identity

#### `CPACK_MSIX_PACKAGE_PUBLISHER_COMMON_NAME` (*required*)

- Fallback: `CPACK_PACKAGE_VENDOR`
- Legal Pattern: [Read Distinguished Names docs](https://learn.microsoft.com/en-us/previous-versions/windows/desktop/ldap/distinguished-names)

#### `CPACK_MSIX_PACKAGE_PUBLISHER_DISPLAY_NAME`

- Description: Sets the display name of the publisher within the installer.
- Fallback: `CPACK_MSIX_PACKAGE_PUBLISHER_COMMON_NAME`

#### `CPACK_MSIX_PACKAGE_PUBLISHER_ORG`

- Description: The name of the organisation the publisher belongs to.
- Legal Pattern: [Read Distinguished Names docs](https://learn.microsoft.com/en-us/previous-versions/windows/desktop/ldap/distinguished-names)

#### `CPACK_MSIX_PACKAGE_PUBLISHER_ORG_UNIT`

- Description: The name of the unit within the organisation that the publisher belongs to.
- Legal Pattern: [Read Distinguished Names docs](https://learn.microsoft.com/en-us/previous-versions/windows/desktop/ldap/distinguished-names)

#### `CPACK_MSIX_PACKAGE_PUBLISHER_COUNTRY`

- Description: The codename of the country the publisher belongs to. (e.g. `IL`)
- Legal Pattern: [Read Distinguished Names docs](https://learn.microsoft.com/en-us/previous-versions/windows/desktop/ldap/distinguished-names)

#### `CPACK_MSIX_PACKAGE_PUBLISHER_STATE`

- Description: The name of the state or province the publisher belongs to. (e.g. `Central District`)
- Legal Pattern: [Read Distinguished Names docs](https://learn.microsoft.com/en-us/previous-versions/windows/desktop/ldap/distinguished-names)

#### `CPACK_MSIX_PACKAGE_PUBLISHER_LOCALITY`

- Description: The name of the city or town the publisher belongs to. (e.g. `Tel Aviv`)
- Legal Pattern: [Read Distinguished Names docs](https://learn.microsoft.com/en-us/previous-versions/windows/desktop/ldap/distinguished-names)

#### `CPACK_MSIX_PACKAGE_PUBLISHER_STREET`

- Description: The street address the publisher is located at. (e.g. `Haim Levanon`)
- Legal Pattern: [Read Distinguished Names docs](https://learn.microsoft.com/en-us/previous-versions/windows/desktop/ldap/distinguished-names)

### Windows Kits

#### `CPACK_MSIX_WIN_KITS_PATH`

> [!NOTE]
> If `CPACK_MSIX_WIN_KITS_PATH` is found to be pointing to a non-existent directory,
> the generator will revert to using the default value.

- Description: Sets the bin directory of the *Windows Kits*.
- Default: `C:/Program Files (x86)/Windows Kits/10/bin`

#### `CPACK_MSIX_WIN_KITS_PREFER_NEWEST`

> [!NOTE]
> The default behaviour is to look for the newest version of *Windows Kits*
> within each individual available architecture in this order:
> 'x86_64', 'arm64', 'x86_32', and last is 'arm32'.

- Description: Tells the generator to look for the newest version of *Windows Kits* within all architectures.
- Default: `OFF`

#### `CPACK_MSIX_WIN_KITS_PREFERRED_VERSION`

> [!IMPORTANT]
> Note that `CPACK_MSIX_WIN_KITS_PREFERRED_VERSION` takes priority over
> `CPACK_MSIX_WIN_KITS_PREFER_NEWEST`'s lookup behaviour!

- Description: The preferred version of *Windows Kits* to use.

## MSIX tools

### Applications

> [!IMPORTANT]
> You must add *at least* add one application implementation to your package in order for the generator not to fail!

#### `cpack_msix_add_application_alias`

- Description: Adds CLI aliases for bundled executables.
- Inputs:
  - `TARGET`: The name of the compiled target/executable (without the `.exe` extension)
  - `DISPLAY_NAME`: The display name of the alias within the installer.
  - `DESCRIPTION`: The description of the alias within the installer.
  - `ALIAS+`: The alias(es) you wish to add for your target/executable.

## Useful resources

- [GitHub maidamai0/hello_msix](https://github.com/maidamai0/hello_msix)
- [GitHub microsoft/winappCli](https://github.com/microsoft/winappCli)
- [Microsoft UWP manual conversion docs](https://learn.microsoft.com/en-us/windows/msix/desktop/desktop-to-uwp-manual-conversion)
