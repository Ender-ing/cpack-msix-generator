# cpack-msix-generator

A custom CPack external generator implementation for natively building Windows MSIX and MSIXUPLOAD packages.

> [!NOTE]
> This project, as it as right now, can be used by CLI packages.
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
> In order to avoid compatibility when fetching from the main branch,
> it is recommended to use `cpack_msix_preset`.

### Quick Start

If you already configured your CMake build to work with cpack using other generators,
you mostly only need these variables to get the MSIX external generator to work with your existing configurations:

```cmake
# Configs
set(CPACK_MSIX_RUNTIME_FOLDER_NAME ${CMAKE_INSTALL_SYSTEM_RUNTIME_DESTINATION}) # In case your default runtime folder isn't 'bin'
set(CPACK_MSIX_GENERATE_UPLOAD ON) # If you want a .msixupload file!

# Identity
set(CPACK_MSIX_PACKAGE_IDENTITY_NAME "MyAwesomeProjectIdentity")
set(CPACK_MSIX_PACKAGE_ARCHITECTURE "x86_64") # Could also use x64. (Check documentation below for more info) 
set(CPACK_MSIX_PACKAGE_LOGO "C:/absolute/path/to/my/logo.png")
set(CPACK_MSIX_PACKAGE_LOGO_44 "C:/absolute/path/to/my/logo_44x44.png")
set(CPACK_MSIX_PACKAGE_LOGO_150 "C:/absolute/path/to/my/logo_150x150.png")
```

## `CPACK_MSIX_*` values

### Package generation

#### `CPACK_MSIX_PACKAGE_FILE_NAME`

- Description: The name of the generated `.msix`, `.appxsym`, and `.msixupload` files.
- Fallback: `CPACK_PACKAGE_FILE_NAME`

#### `CPACK_MSIX_RUNTIME_FOLDER_NAME` (*required*)

> [!IMPORTANT]
> This value should match your `CMAKE_INSTALL_SYSTEM_RUNTIME_DESTINATION` value!
> Application implementations make through `MSIXTools.cmake` could break if misconfigured!

- Description: The name of the runtime binaries folder.
- Fallback: `bin`

#### `CPACK_MSIX_GENERATE_UPLOAD`

> [!WARNING]
> You are allowed to generate `.msixupload` files without debug symbols,
> with the risk of getting your Microsoft Store uploads rejected!
>
> (Note that debug symbols are automatically bundled when detected)

- Description: Enable `.msixupload` generation.
- Default: `OFF`

#### `CPACK_MSIX_APPLICATIONS` (*required*)

> [!CAUTION]
> You should not modify this by yourself!
> Please use [MSIXTools](#msix-tools) to add application implementations!

- Description: A `JSON` list of custom application implementations.
  This value will not be documented!
  You may read the contents of `MSIXTools.cmake` to figure how to add your own custom implementaionts.

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

#### `CPACK_MSIX_PACKAGE_ARCHITECTURE` (*required*)

- Description: Sets the `ProcessorArchitecture` that your program supports.
- Legal Pattern: `x86_64|x64|arm64|x86_32|x86`

#### `CPACK_MSIX_PACKAGE_IDENTITY_NAME` (*required*)

- Description: Sets the package's identity `Name` value.
- Legal Pattern: `[a-zA-Z\.-]{3,50}`

#### `CPACK_MSIX_PACKAGE_NAME`

- Description: Sets the display name within the installer.
- Fallback: `CPACK_PACKAGE_NAME`

#### `CPACK_MSIX_PACKAGE_DESCRIPTION_SUMMARY`

- Description: Sets the display name within the installer.
- Fallback: `CPACK_PACKAGE_DESCRIPTION_SUMMARY`

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

## MSIX tools

> [!NOTE]
> You must add *at least* add one application implementation to your package in order for the generator not to fail!

### Applications

#### `cpack_msix_add_application_alias`

- Description: Adds CLI aliases for bundled executables.
- Inputs:
  - `TARGET`: The name of the compiled target/executable (without the `.exe` extension)
  - `DISPLAY_NAME`: The display name of the alias within the installer.
  - `DESCRIPTION`: The description of the alias within the installer.
  - `ALIAS+`: The alias(es) you wish to add for your target/executable.

## Features awaiting implementation

- Add asset sets for logos, colours, etc. (`cpack_msix_add_assets_set`)
- Add a graphical applicaiton type (`cpack_msix_add_application_graphical`)
- Support package signing (`CPACK_MSIX_CERTIFICATE_PATH`)
