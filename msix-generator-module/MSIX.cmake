cmake_minimum_required(VERSION 3.21 FATAL_ERROR)

####################################################
## USE
####################################################

# list(APPEND CPACK_GENERATOR "External")
# set(CPACK_EXTERNAL_PACKAGE_SCRIPT ".../MSIX.cmake")
# set(CPACK_EXTERNAL_ENABLE_STAGING ON)

####################################################
## SUPPORTED VARIABLES
####################################################

# [VERSION VARIABLES]:
# Must follow the format: {major}.{minor}.{patch}.{revision}
# CPACK_MSIX_PACKAGE_VERSION
if(NOT DEFINED CPACK_MSIX_PACKAGE_VERSION)
    set(CPACK_MSIX_PACKAGE_VERSION ${CPACK_PACKAGE_VERSION})
endif()
if(CPACK_MSIX_PACKAGE_VERSION MATCHES "^[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+$")
    set(MSIX_INTERNAL_PACKAGE_VERSION ${CPACK_MSIX_PACKAGE_VERSION})
else()
    message(WARNING "[CPACK MSIX] No valid 'CPACK_MSIX_PACKAGE_VERSION' value detected. (Detected: '${CPACK_MSIX_PACKAGE_VERSION}') Falling back to 'CPACK_MSIX_PACKAGE_VERSION_*'")
    # CPACK_MSIX_PACKAGE_VERSION_MAJOR
    if(NOT DEFINED CPACK_MSIX_PACKAGE_VERSION_MAJOR)
        set(CPACK_MSIX_PACKAGE_VERSION_MAJOR 0)
    endif()
    # CPACK_MSIX_PACKAGE_VERSION_MINOR
    if(NOT DEFINED CPACK_MSIX_PACKAGE_VERSION_MINOR)
        set(CPACK_MSIX_PACKAGE_VERSION_MINOR 0)
    endif()
    # CPACK_MSIX_PACKAGE_VERSION_PATCH
    if(NOT DEFINED CPACK_MSIX_PACKAGE_VERSION_PATCH)
        set(CPACK_MSIX_PACKAGE_VERSION_PATCH 0)
    endif()
    # CPACK_MSIX_PACKAGE_VERSION_REVISION
    if(NOT DEFINED CPACK_MSIX_PACKAGE_VERSION_REVISION)
        set(CPACK_MSIX_PACKAGE_VERSION_REVISION 0)
    endif()
    set(MSIX_INTERNAL_PACKAGE_VERSION "${CPACK_MSIX_PACKAGE_VERSION_MAJOR}.${CPACK_MSIX_PACKAGE_VERSION_MINOR}.${CPACK_MSIX_PACKAGE_VERSION_PATCH}.${CPACK_MSIX_PACKAGE_VERSION_REVISION}")
endif()

# [PLATFORM VARIABLES]
# CPACK_MSIX_PACKAGE_ARCHITECTURE
if(DEFINED CPACK_MSIX_PACKAGE_ARCHITECTURE)
    # Port over arch names
    if(CPACK_MSIX_PACKAGE_ARCHITECTURE STREQUAL "x86_32")
        set(CPACK_MSIX_PACKAGE_ARCHITECTURE "x86")
    elseif(CPACK_MSIX_PACKAGE_ARCHITECTURE STREQUAL "x86_64")
        set(CPACK_MSIX_PACKAGE_ARCHITECTURE "x64")
    elseif(CPACK_MSIX_PACKAGE_ARCHITECTURE STREQUAL "arm32")
        set(CPACK_MSIX_PACKAGE_ARCHITECTURE "arm")
    elseif(CPACK_MSIX_PACKAGE_ARCHITECTURE STREQUAL "arm64")
        set(CPACK_MSIX_PACKAGE_ARCHITECTURE "arm64")
    endif()

    if(NOT CPACK_MSIX_PACKAGE_ARCHITECTURE MATCHES "^(x86|x64|arm|arm64|neutral)$")
        message(FATAL_ERROR "[CPACK MSIX] Expecting a valid 'CPACK_MSIX_PACKAGE_ARCHITECTURE' value: x86|x64|arm|arm64|neutral")
    endif()
else()
    message(FATAL_ERROR "[CPACK MSIX] 'CPACK_MSIX_PACKAGE_ARCHITECTURE' not set!")
endif()

# [PACKAGE DETAILS]
# CPACK_MSIX_PACKAGE_NAME
if(NOT DEFINED CPACK_MSIX_PACKAGE_NAME)
    set(CPACK_MSIX_PACKAGE_NAME ${CPACK_PACKAGE_NAME})
endif()
# CPACK_MSIX_PACKAGE_DESCRIPTION_SUMMARY
if(NOT DEFINED CPACK_MSIX_PACKAGE_DESCRIPTION_SUMMARY)
    set(CPACK_MSIX_PACKAGE_DESCRIPTION_SUMMARY ${CPACK_PACKAGE_DESCRIPTION_SUMMARY})
endif()
# CPACK_MSIX_PACKAGE_IDENTITY_NAME
if(NOT DEFINED CPACK_MSIX_PACKAGE_IDENTITY_NAME)
    # Sanitise name
    string(REGEX REPLACE "[ ]" "." MSIX_INTERNAL_SANITIZED_PACKAGE_NAME "${CPACK_MSIX_PACKAGE_NAME}")
    string(REGEX REPLACE "[^a-zA-Z0-9\\.\\-]" "" MSIX_INTERNAL_SANITIZED_PACKAGE_NAME "${MSIX_INTERNAL_SANITIZED_PACKAGE_NAME}")
    string(REGEX REPLACE "[^a-zA-Z0-9\\.\\-]" "" MSIX_INTERNAL_SANITIZED_PACKAGE_NAME "${MSIX_INTERNAL_SANITIZED_PACKAGE_NAME}")
    string(LENGTH "${MSIX_INTERNAL_SANITIZED_PACKAGE_NAME}" MSIX_INTERNAL_SANITIZED_PACKAGE_NAME_LENGTH)

    # Ensure valid length
    if(MSIX_INTERNAL_SANITIZED_PACKAGE_NAME_LENGTH LESS 3)
        set(MSIX_INTERNAL_SANITIZED_PACKAGE_NAME "CPack.${MSIX_INTERNAL_SANITIZED_PACKAGE_NAME}")
    elseif(MSIX_INTERNAL_SANITIZED_PACKAGE_NAME_LENGTH GREATER 50)
        string(SUBSTRING "${MSIX_INTERNAL_SANITIZED_PACKAGE_NAME}" 0 50 MSIX_INTERNAL_SANITIZED_PACKAGE_NAME)
    endif()

    # Update CPACK_MSIX_PACKAGE_IDENTITY_NAME!
    set(CPACK_MSIX_PACKAGE_IDENTITY_NAME ${MSIX_INTERNAL_SANITIZED_PACKAGE_NAME})

    message(WARNING "[CPACK MSIX] No 'CPACK_MSIX_PACKAGE_IDENTITY_NAME' value detected. Generated identity name: '${MSIX_INTERNAL_SANITIZED_PACKAGE_NAME}'.")
endif()
string(LENGTH "${CPACK_MSIX_PACKAGE_IDENTITY_NAME}" MSIX_INTERNAL_IDENTITY_LENGTH)
if((NOT DEFINED CPACK_MSIX_PACKAGE_IDENTITY_NAME) OR (MSIX_INTERNAL_IDENTITY_LENGTH LESS 3) 
    OR (MSIX_INTERNAL_IDENTITY_LENGTH GREATER 50)
    OR (NOT CPACK_MSIX_PACKAGE_IDENTITY_NAME MATCHES "^[a-zA-Z0-9\\.\\-]+$"))
    message(FATAL_ERROR "[CPACK MSIX] Expecting a valid 'CPACK_MSIX_PACKAGE_IDENTITY_NAME' value!")
endif()
# CPACK_MSIX_PACKAGE_LOGO (REQUIRED)
if((NOT CPACK_MSIX_PACKAGE_LOGO MATCHES "\\.png$") OR (NOT EXISTS ${CPACK_MSIX_PACKAGE_LOGO}))
    message(FATAL_ERROR "[CPACK MSIX] Expecting 'CPACK_MSIX_PACKAGE_LOGO' to point to a valid '.png' file!")
endif()
# CPACK_MSIX_PACKAGE_LOGO_44 (REQUIRED)
if((NOT CPACK_MSIX_PACKAGE_LOGO_44 MATCHES "\\.png$") OR (NOT EXISTS ${CPACK_MSIX_PACKAGE_LOGO_44}))
    message(FATAL_ERROR "[CPACK MSIX] Expecting 'CPACK_MSIX_PACKAGE_LOGO_44' to point to a valid 44x44 '.png' file!")
endif()
# CPACK_MSIX_PACKAGE_LOGO_150 (REQUIRED)
if((NOT CPACK_MSIX_PACKAGE_LOGO_150 MATCHES "\\.png$") OR (NOT EXISTS ${CPACK_MSIX_PACKAGE_LOGO_150}))
    message(FATAL_ERROR "[CPACK MSIX] Expecting 'CPACK_MSIX_PACKAGE_LOGO_150' to point to a valid 150x150 '.png' file!")
endif()

# [PUBLISHER]
# CPACK_MSIX_PACKAGE_PUBLISHER_COMMON_NAME (REQUIRED)
if(NOT DEFINED CPACK_MSIX_PACKAGE_PUBLISHER_COMMON_NAME)
    set(CPACK_MSIX_PACKAGE_PUBLISHER_COMMON_NAME ${CPACK_PACKAGE_VENDOR})
endif()
# CPACK_MSIX_PACKAGE_PUBLISHER_DISPLAY_NAME
if(NOT DEFINED CPACK_MSIX_PACKAGE_PUBLISHER_DISPLAY_NAME)
    set(CPACK_MSIX_PACKAGE_PUBLISHER_DISPLAY_NAME ${CPACK_MSIX_PACKAGE_PUBLISHER_COMMON_NAME})
endif()

# [PUBLISHER INFO]
set(MSIX_INTERNAL_PUBLISHER "")
if((DEFINED CPACK_MSIX_PACKAGE_PUBLISHER_COMMON_NAME) AND (CPACK_MSIX_PACKAGE_PUBLISHER_COMMON_NAME STREQUAL ""))
    message(FATAL_ERROR "[CPACK MSIX] Expecting a non-empty 'CPACK_MSIX_PACKAGE_PUBLISHER_COMMON_NAME' value!")
else()
    set(MSIX_INTERNAL_PUBLISHER "CN=${CPACK_MSIX_PACKAGE_PUBLISHER_COMMON_NAME}")
endif()
# CPACK_MSIX_PACKAGE_PUBLISHER_ORG
if((DEFINED CPACK_MSIX_PACKAGE_PUBLISHER_ORG) AND (NOT CPACK_MSIX_PACKAGE_PUBLISHER_ORG STREQUAL ""))
    set(MSIX_INTERNAL_PUBLISHER "${MSIX_INTERNAL_PUBLISHER},O=${CPACK_MSIX_PACKAGE_PUBLISHER_ORG}")
endif()
# CPACK_MSIX_PACKAGE_PUBLISHER_ORG_UNIT
if((DEFINED CPACK_MSIX_PACKAGE_PUBLISHER_ORG_UNIT) AND (NOT CPACK_MSIX_PACKAGE_PUBLISHER_ORG_UNIT STREQUAL ""))
    set(MSIX_INTERNAL_PUBLISHER "${MSIX_INTERNAL_PUBLISHER},OU=${CPACK_MSIX_PACKAGE_PUBLISHER_ORG_UNIT}")
endif()
# CPACK_MSIX_PACKAGE_PUBLISHER_COUNTRY
if((DEFINED CPACK_MSIX_PACKAGE_PUBLISHER_COUNTRY) AND (NOT CPACK_MSIX_PACKAGE_PUBLISHER_COUNTRY STREQUAL ""))
    set(MSIX_INTERNAL_PUBLISHER "${MSIX_INTERNAL_PUBLISHER},C=${CPACK_MSIX_PACKAGE_PUBLISHER_COUNTRY}")
endif()
# CPACK_MSIX_PACKAGE_PUBLISHER_STATE
if((DEFINED CPACK_MSIX_PACKAGE_PUBLISHER_STATE) AND (NOT CPACK_MSIX_PACKAGE_PUBLISHER_STATE STREQUAL ""))
    set(MSIX_INTERNAL_PUBLISHER "${MSIX_INTERNAL_PUBLISHER},ST=${CPACK_MSIX_PACKAGE_PUBLISHER_STATE}")
endif()
# CPACK_MSIX_PACKAGE_PUBLISHER_LOCALITY
if((DEFINED CPACK_MSIX_PACKAGE_PUBLISHER_LOCALITY) AND (NOT CPACK_MSIX_PACKAGE_PUBLISHER_LOCALITY STREQUAL ""))
    set(MSIX_INTERNAL_PUBLISHER "${MSIX_INTERNAL_PUBLISHER},L=${CPACK_MSIX_PACKAGE_PUBLISHER_LOCALITY}")
endif()
# CPACK_MSIX_PACKAGE_PUBLISHER_STREET
if((DEFINED CPACK_MSIX_PACKAGE_PUBLISHER_STREET) AND (NOT CPACK_MSIX_PACKAGE_PUBLISHER_STREET STREQUAL ""))
    set(MSIX_INTERNAL_PUBLISHER "${MSIX_INTERNAL_PUBLISHER},STREET=${CPACK_MSIX_PACKAGE_PUBLISHER_STREET}")
endif()

# [FILE/DIR NAMES]
# CPACK_MSIX_PACKAGE_FILE_NAME
if(NOT DEFINED CPACK_MSIX_PACKAGE_FILE_NAME)
    set(CPACK_MSIX_PACKAGE_FILE_NAME ${CPACK_PACKAGE_FILE_NAME})
endif()
# CPACK_MSIX_RUNTIME_FOLDER_NAME (Should match build configs)
if(NOT DEFINED CPACK_MSIX_RUNTIME_FOLDER_NAME)
    set(CPACK_MSIX_RUNTIME_FOLDER_NAME bin)
endif()
# CPACK_MSIX_DEBUG_PATH_OFFSET
set(MSIX_INTERNAL_FLATTEN_DEBUG_DIR OFF)
if(NOT DEFINED CPACK_MSIX_DEBUG_PATH_OFFSET)
    set(CPACK_MSIX_DEBUG_PATH_OFFSET "")
elseif(CPACK_MSIX_DEBUG_PATH_OFFSET STREQUAL "")
    set(MSIX_INTERNAL_FLATTEN_DEBUG_DIR ON)
    message(FATAL_ERROR "[CPACK MSIX] Detected an empty 'CPACK_MSIX_DEBUG_PATH_OFFSET' value. Enabled shared directory pooling for all debug symbols.")
endif()

# [PACKAGE UPLOAD]
option(CPACK_MSIX_GENERATE_UPLOAD "Trigger MSIX '.msixupload' file generation" OFF)

# [PACKAGE APPLICATIONS]
# CPACK_MSIX_APPLICATIONS (REQUIRED)
if(DEFINED CPACK_MSIX_APPLICATIONS)
    set(MSIX_INTERNAL_APPLICATIONS "{ \"applications\": [${CPACK_MSIX_APPLICATIONS}] }")

    # Count apps
    string(JSON MSIX_JSON_APP_COUNT LENGTH "${MSIX_INTERNAL_APPLICATIONS}" "applications")
    math(EXPR MSIX_INTERNAL_APPLICATIONS_LAST_INDEX "${MSIX_JSON_APP_COUNT} - 1")

    # Must contain at least one app!
    if(NOT MSIX_JSON_APP_COUNT GREATER 0)
        message(FATAL_ERROR "[CPACK MSIX] Expecting at least one valid app inside 'CPACK_MSIX_APPLICATIONS'! Try using 'MSIXTools' to add applications.")
    endif()
else()
    message(FATAL_ERROR "[CPACK MSIX] Expecting 'CPACK_MSIX_APPLICATIONS' to point to a non-empty valid list of MSIX applications! Try using 'MSIXTools' to add applications.")
endif()

# [WINDOWS KITS]
# CPACK_MSIX_WIN_KITS_PATH
if((DEFINED CPACK_MSIX_WIN_KITS_PATH) AND (EXISTS "${CPACK_MSIX_WIN_KITS_PATH}"))
    set(MSIX_INTERNAL_WINDOWS_KITS_BASE "${CPACK_MSIX_WIN_KITS_PATH}")
else()
    set(MSIX_INTERNAL_WINDOWS_KITS_BASE "C:/Program Files (x86)/Windows Kits/10/bin")
    if((DEFINED CPACK_MSIX_WIN_KITS_PATH) AND (NOT EXISTS "${CPACK_MSIX_WIN_KITS_PATH}"))
        message(WARNING "[CPACK MSIX] Used 'CPACK_MSIX_WIN_KITS_PATH' value doesn't point to a valid bin directory. Reverting to default value: ${MSIX_INTERNAL_WINDOWS_KITS_BASE}")
    endif()
endif()
# CPACK_MSIX_WIN_KITS_PREFERRED_VERSION
if((DEFINED CPACK_MSIX_WIN_KITS_PREFERRED_VERSION) AND (NOT CPACK_MSIX_WIN_KITS_PREFERRED_VERSION STREQUAL ""))
    set(MSIX_INTERNAL_WIN_KITS_VERSION_SET ON)
else()
    set(MSIX_INTERNAL_WIN_KITS_VERSION_SET OFF)
endif()
# CPACK_MSIX_WIN_KITS_PREFER_NEWEST
option(CPACK_MSIX_WIN_KITS_PREFER_NEWEST "Force overall newest version lookup. (Ignores architecture priority)" OFF)

####################################################
## STAGING
####################################################

# Determine where CPack dumped the component folders
if(EXISTS "${CPACK_TEMPORARY_DIRECTORY}/${CPACK_PACKAGE_FILE_NAME}")
    set(MSIX_INTERNAL_STAGE_ROOT "${CPACK_TEMPORARY_DIRECTORY}/${CPACK_PACKAGE_FILE_NAME}")
else()
    set(MSIX_INTERNAL_STAGE_ROOT "${CPACK_TEMPORARY_DIRECTORY}")
endif()

# Create a clean staging directory
set(MSIX_STAGING_ROOT "${CPACK_TOPLEVEL_DIRECTORY}/MSIX")
file(REMOVE_RECURSE "${MSIX_STAGING_ROOT}") # Clean up from previous runs
file(MAKE_DIRECTORY "${MSIX_STAGING_ROOT}")

message(STATUS "[CPACK MSIX] Flattening component directories into ${MSIX_STAGING_ROOT}...")

# Loop through the component folders and merge their contents
file(GLOB MSIX_COMPONENT_DIRS LIST_DIRECTORIES true "${MSIX_INTERNAL_STAGE_ROOT}/*")
foreach(COMP_DIR IN LISTS MSIX_COMPONENT_DIRS)
    if(IS_DIRECTORY "${COMP_DIR}")
        # Get everything inside this component folder (e.g., the 'bin' folder)
        file(GLOB COMP_CONTENTS "${COMP_DIR}/*")
        if(COMP_CONTENTS)
            # Copy it into our flattened root
            file(COPY ${COMP_CONTENTS} DESTINATION "${MSIX_STAGING_ROOT}")
        endif()
    endif()
endforeach()

####################################################
## WINDOWS KITS LOOKUP
## CREDIT: https://forum.qt.io/topic/147272/preparing-app-for-microsoft-store-qt-6-cmake?_=1737373157758
####################################################

# Define search paths
set(MSIX_INTERNAL_WIN_KITS_SEARCH_PATHS "")

# Prioritise the user's preferred version
if(MSIX_INTERNAL_WIN_KITS_VERSION_SET)
    set(MSIX_INTERNAL_WIN_KITS_PREFERRED_VERSION_PATH "${MSIX_INTERNAL_WINDOWS_KITS_BASE}/${CPACK_MSIX_WIN_KITS_PREFERRED_VERSION}")
    foreach(ARCH "x64" "arm64" "x86" "arm")
        if(EXISTS "${MSIX_INTERNAL_WIN_KITS_PREFERRED_VERSION_PATH}/${ARCH}")
            list(APPEND MSIX_INTERNAL_WIN_KITS_SEARCH_PATHS "${MSIX_INTERNAL_WIN_KITS_PREFERRED_VERSION_PATH}/${ARCH}")
        endif()
    endforeach()
endif()

# Get all versioned directories, newest to oldest!
file(GLOB MSIX_INTERNAL_VERSIONED_DIRS LIST_DIRECTORIES true "${MSIX_INTERNAL_WINDOWS_KITS_BASE}/*")
list(SORT MSIX_INTERNAL_VERSIONED_DIRS COMPARE NATURAL ORDER DESCENDING)

# Paths lookup
if(CPACK_MSIX_WIN_KITS_PREFER_NEWEST)
    # Give priority to newer versions!
    foreach(DIR ${MSIX_INTERNAL_VERSIONED_DIRS})
        foreach(ARCH "x64" "arm64" "x86" "arm")
            if(EXISTS "${DIR}/${ARCH}")
                list(APPEND MSIX_INTERNAL_WIN_KITS_SEARCH_PATHS "${DIR}/${ARCH}")
            endif()
        endforeach()
    endforeach()
else()
    # Give priority to the newest arch-specific version!
    foreach(ARCH "x64" "arm64" "x86" "arm")
        foreach(DIR ${MSIX_INTERNAL_VERSIONED_DIRS})
            if(EXISTS "${DIR}/${ARCH}")
                list(APPEND MSIX_INTERNAL_WIN_KITS_SEARCH_PATHS "${DIR}/${ARCH}")
            endif()
        endforeach()
    endforeach()
endif()

# Attempt to find 'makeappx'
find_program(MAKEAPPX_EXECUTABLE makeappx
    PATHS ${MSIX_INTERNAL_WIN_KITS_SEARCH_PATHS}
    REQUIRED
)
if(MAKEAPPX_EXECUTABLE)
    message(STATUS "[CPACK MSIX] Found MakeAppx at: ${MAKEAPPX_EXECUTABLE}")
endif()

####################################################
## PACKAGING READYUP
####################################################

# Get the binaries directory (usually /bin)
# set(MSIX_INTERNAL_BIN "${MSIX_STAGING_ROOT}/${CPACK_MSIX_RUNTIME_FOLDER_NAME}")

# Get a list of manifest applications
set(MSIX_INTERNAL_MANIFEST_APPLICATIONS "")
foreach(INDEX RANGE ${MSIX_INTERNAL_APPLICATIONS_LAST_INDEX})
    # Extract application type
    string(JSON APP_TYPE GET "${MSIX_INTERNAL_APPLICATIONS}" "applications" ${INDEX} "type")

    if(APP_TYPE STREQUAL "ALIAS")
        # Get info
        string(JSON CURRENT_TARGET GET "${MSIX_INTERNAL_APPLICATIONS}" "applications" ${INDEX} "target")
        string(JSON CURRENT_NAME GET "${MSIX_INTERNAL_APPLICATIONS}" "applications" ${INDEX} "name")
        string(JSON CURRENT_DESCRIPTION GET "${MSIX_INTERNAL_APPLICATIONS}" "applications" ${INDEX} "description")

        message(STATUS "[CPACK MSIX] Adding 'app execution aliases' for '${CURRENT_TARGET}'...")
        set(MSIX_INTERNAL_MANIFEST_APPLICATIONS "${MSIX_INTERNAL_MANIFEST_APPLICATIONS}    <Application
                Id=\"TARGET.ALIAS.${CURRENT_TARGET}\" Executable=\"${CPACK_MSIX_RUNTIME_FOLDER_NAME}\\${CURRENT_TARGET}.exe\"
                                EntryPoint=\"Windows.FullTrustApplication\">
      
            <uap:VisualElements DisplayName=\"${CURRENT_NAME}\" Description=\"${CURRENT_DESCRIPTION}\" 
                              BackgroundColor=\"transparent\" Square150x150Logo=\"Assets\\Logo-150.png\" Square44x44Logo=\"Assets\\Logo-44.png\"
                              AppListEntry=\"none\" />

            <Extensions>
                <uap5:Extension Category=\"windows.appExecutionAlias\">
                    <uap5:AppExecutionAlias>\n")

        # Loop through the nested aliases array
        string(JSON ALIAS_COUNT LENGTH "${MSIX_INTERNAL_APPLICATIONS}" "applications" ${INDEX} "aliases")

        if(ALIAS_COUNT GREATER 0)
            math(EXPR MSIX_INTERNAL_ALIAS_LAST_INDEX "${ALIAS_COUNT} - 1")
            foreach(ALIAS_INDEX RANGE ${MSIX_INTERNAL_ALIAS_LAST_INDEX})
                string(JSON CURRENT_ALIAS GET "${MSIX_INTERNAL_APPLICATIONS}" "applications" ${INDEX} "aliases" ${ALIAS_INDEX})
                message(STATUS "[CPACK MSIX] Adding '${CURRENT_ALIAS}' alias for '${CURRENT_TARGET}'...")

                set(MSIX_INTERNAL_MANIFEST_APPLICATIONS "${MSIX_INTERNAL_MANIFEST_APPLICATIONS}
                    <uap5:ExecutionAlias Alias=\"${CURRENT_ALIAS}.exe\" />\n")
            endforeach()
        else()
            message(STATUS "[CPACK MSIX] Target '${CURRENT_TARGET}' must have at least one alias!")
        endif()

        set(MSIX_INTERNAL_MANIFEST_APPLICATIONS "${MSIX_INTERNAL_MANIFEST_APPLICATIONS}
                    </uap5:AppExecutionAlias>
                </uap5:Extension>
            </Extensions>
        </Application>\n")
    else()
        message(FATAL_ERROR "[CPACK MSIX] Unsupported/unknown application type detected: ${APP_TYPE}")
    endif()
endforeach()

# Make a debug dir
set(MSIX_STAGING_DEBUG_ROOT "${CPACK_TOPLEVEL_DIRECTORY}/MSIX_DEBUG")
file(REMOVE_RECURSE "${MSIX_STAGING_DEBUG_ROOT}") # Clean up from previous runs
file(MAKE_DIRECTORY "${MSIX_STAGING_DEBUG_ROOT}")

# Move debug files
file(GLOB_RECURSE MSIX_INTERNAL_PDB_FILES "${MSIX_STAGING_ROOT}/*.pdb")
list(LENGTH MSIX_INTERNAL_PDB_FILES MSIX_INTERNAL_PDB_COUNT)
set(MSIX_INTERNAL_PDB_DETECTED OFF)
if(MSIX_INTERNAL_PDB_COUNT GREATER 0)
    message(STATUS "[CPACK MSIX] Debug symbols found. Beginning debug symbols isolation...")
    set(MSIX_INTERNAL_PDB_DETECTED ON)

    # Copy and Delete original files
    foreach(PDB_FILE IN LISTS MSIX_INTERNAL_PDB_FILES)
    
        # Get fixed path
        if(MSIX_INTERNAL_FLATTEN_DEBUG_DIR)
            cmake_path(GET PDB_FILE FILENAME REL_PDB_PATH)
        else()
            if(CPACK_MSIX_DEBUG_PATH_OFFSET STREQUAL "")
                set(REL_PDB_PATH_BASE "${MSIX_STAGING_ROOT}")
            else()
                set(REL_PDB_PATH_BASE "${MSIX_STAGING_ROOT}/${CPACK_MSIX_DEBUG_PATH_OFFSET}")
            endif()
            file(RELATIVE_PATH REL_PDB_PATH "${REL_PDB_PATH_BASE}" "${PDB_FILE}")
        endif()
        set(FULL_PDB_DEST_PATH "${MSIX_STAGING_DEBUG_ROOT}/${REL_PDB_PATH}")

        # Move the file
        message(STATUS "[CPACK MSIX] Isolating debug symbols file '${PDB_FILE}' into: ${FULL_PDB_DEST_PATH}")
        cmake_path(GET FULL_PDB_DEST_PATH PARENT_PATH FULL_PDB_DEST_DIR)
        file(MAKE_DIRECTORY "${FULL_PDB_DEST_DIR}")
        file(COPY_FILE "${PDB_FILE}" "${FULL_PDB_DEST_PATH}" ONLY_IF_DIFFERENT)
        if(EXISTS ${PDB_FILE})
            file(REMOVE ${PDB_FILE})
        endif()
    endforeach()

    # We're done with MSIX_INTERNAL_PDB_FILES!
endif()

# Generate a manifest
configure_file(
    "${CMAKE_CURRENT_LIST_DIR}/AppxManifest.xml.in"
    "${MSIX_STAGING_ROOT}/AppxManifest.xml"
    @ONLY
)

# Copy manfiest assets
file(MAKE_DIRECTORY "${MSIX_STAGING_ROOT}/Assets")
file(COPY_FILE "${CPACK_MSIX_PACKAGE_LOGO}" "${MSIX_STAGING_ROOT}/Assets/Logo.png")
file(COPY_FILE "${CPACK_MSIX_PACKAGE_LOGO_44}" "${MSIX_STAGING_ROOT}/Assets/Logo-44.png")
file(COPY_FILE "${CPACK_MSIX_PACKAGE_LOGO_150}" "${MSIX_STAGING_ROOT}/Assets/Logo-150.png")

####################################################
## PACKAGING
## CREDIT: https://forum.qt.io/topic/147272/preparing-app-for-microsoft-store-qt-6-cmake?_=1737373157758
####################################################

# Create a packaging folder
set(MSIX_STAGING_UPLOAD_ROOT "${CPACK_TOPLEVEL_DIRECTORY}/MSIX_UPLOAD")
file(REMOVE_RECURSE "${MSIX_STAGING_UPLOAD_ROOT}")
file(MAKE_DIRECTORY "${MSIX_STAGING_UPLOAD_ROOT}")

# Invoke MakeAppx to bundle the directory into the final MSIX
message(STATUS "[CPACK MSIX] Packaging MSIX with MakeAppx...")
execute_process(
    COMMAND "${MAKEAPPX_EXECUTABLE}" pack 
            /d "${MSIX_STAGING_ROOT}" 
            /p "${MSIX_STAGING_UPLOAD_ROOT}/${CPACK_MSIX_PACKAGE_FILE_NAME}.msix"
            /o # Overwrite if exists
    RESULT_VARIABLE MAKEAPPX_RESULT
    OUTPUT_VARIABLE MAKEAPPX_OUTPUT
    ERROR_VARIABLE MAKEAPPX_ERROR
)
if(NOT MAKEAPPX_RESULT EQUAL 0)
    message(FATAL_ERROR "[CPACK MSIX] MakeAppx failed to generate the MSIX package." ${MAKEAPPX_OUTPUT} ${MAKEAPPX_ERROR})
else()
    message(STATUS "[CPACK MSIX] Generated an MSIX package: ${MSIX_STAGING_UPLOAD_ROOT}/${CPACK_MSIX_PACKAGE_FILE_NAME}.msix")

    message(STATUS "[CPACK MSIX] Copying MSIX package from '${MSIX_STAGING_UPLOAD_ROOT}' to '${${CPACK_PACKAGE_DIRECTORY}}'...")
    execute_process(
        COMMAND ${CMAKE_COMMAND} -E copy_if_different "${MSIX_STAGING_UPLOAD_ROOT}/${CPACK_MSIX_PACKAGE_FILE_NAME}.msix" "${CPACK_PACKAGE_DIRECTORY}"
    )
endif()

# Check if an upload file is required
if(CPACK_MSIX_GENERATE_UPLOAD)
    message(STATUS "[CPACK MSIX] Generating a '.msixupload' file...")

    # Package debug symbols
    if(MSIX_INTERNAL_PDB_DETECTED)
        message(STATUS "[CPACK MSIX] Debug symbols found. Generating a '.appxsym' file...")

        # Zip the .pdb files into .appxsym
        execute_process(
            COMMAND "${CMAKE_COMMAND}" -E tar "cf" "${MSIX_STAGING_UPLOAD_ROOT}/${CPACK_MSIX_PACKAGE_FILE_NAME}.appxsym" --format=zip .
            WORKING_DIRECTORY "${MSIX_STAGING_DEBUG_ROOT}"
            RESULT_VARIABLE PDB_ZIP_RESULT
            OUTPUT_VARIABLE PDB_ZIP_OUTPUT
            ERROR_VARIABLE PDB_ZIP_ERROR
        )

        if(NOT PDB_ZIP_RESULT EQUAL 0)
            message(FATAL_ERROR "[CPACK MSIX] MakeAppx failed to generate a '.appxsym' file." ${PDB_ZIP_OUTPUT} ${PDB_ZIP_ERROR})
        else()
            message(STATUS "[CPACK MSIX] Generated an debug symbols file: ${MSIX_STAGING_UPLOAD_ROOT}/${CPACK_MSIX_PACKAGE_FILE_NAME}.appxsym")
        endif()
    endif()

    # Zip the contents into .msixupload
    execute_process(
        COMMAND "${CMAKE_COMMAND}" -E tar "cf" "${CPACK_PACKAGE_DIRECTORY}/${CPACK_MSIX_PACKAGE_FILE_NAME}.msixupload" --format=zip .
        WORKING_DIRECTORY "${MSIX_STAGING_UPLOAD_ROOT}"
        RESULT_VARIABLE UPLOAD_ZIP_RESULT
        OUTPUT_VARIABLE UPLOAD_ZIP_OUTPUT
        ERROR_VARIABLE UPLOAD_ZIP_ERROR
    )
    if(NOT MSIX_INTERNAL_PDB_DETECTED)
        message(WARNING "[CPACK MSIX] Couldn't include debug symbols in '.msixupload'...")
    endif()
    if(NOT UPLOAD_ZIP_RESULT EQUAL 0)
        message(FATAL_ERROR "[CPACK MSIX] Failed to generate a '.msixupload' file." ${UPLOAD_ZIP_OUTPUT} ${UPLOAD_ZIP_ERROR})
    else()
        message(STATUS "[CPACK MSIX] Generated an MSIXUpload file: ${CPACK_PACKAGE_DIRECTORY}/${CPACK_MSIX_PACKAGE_FILE_NAME}.msixupload")
    endif()
endif()

####################################################
## PACKAGE VERIFICATION
####################################################

# ...
