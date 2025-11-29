cmake_minimum_required(VERSION 3.10)
project(prospectius LANGUAGES CXX)

set(BINARY_NAME "prospectius")
set(BINARY_NAME_UPPER "PROSPECTIUS")

cmake_policy(SET CMP0063 NEW)

set(CMAKE_CXX_VISIBILITY_PRESET hidden)
set(CMAKE_C_VISIBILITY_PRESET hidden)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Configure the Windows version to be as new as possible by default.
if(NOT CMAKE_SYSTEM_VERSION)
  set(CMAKE_SYSTEM_VERSION 10.0.19041.0)
endif()

set(PROJECT_BUILD_DIR "${CMAKE_BINARY_DIR}" CACHE STRING "")
set(DART_LIB_OUT_DIR  "${CMAKE_BINARY_DIR}/$<CONFIG>" CACHE STRING "")

# Root filesystem for target environment
set(FLUTTER_TARGET_PLATFORM "windows")

# Define build variant
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE "Debug")
endif()

file(TO_CMAKE_PATH "$ENV{FLUTTER_ROOT}" FLUTTER_ROOT)
message(STATUS "Flutter root: ${FLUTTER_ROOT}")

set(FLUTTER_VERSION "${FLUTTER_VERSION}" CACHE STRING "Flutter version number")
if (NOT FLUTTER_VERSION)
  message(STATUS "Flutter version not specified, using default: 1.0.0")
  set(FLUTTER_VERSION "1.0.0")
endif()

set(FLUTTER_VERSION_MAJOR 1)
set(FLUTTER_VERSION_MINOR 0)
set(FLUTTER_VERSION_PATCH 0)
set(FLUTTER_VERSION_PRERELEASE "")
set(FLUTTER_VERSION_BUILD_METADATA "")

set(PRODUCT_BUNDLE_IDENTIFIER "com.prospectius")

file(TO_CMAKE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/../.." SOURCE_DIR)
set(DART_LIB_OUT_DIR  "${CMAKE_BINARY_DIR}/$<CONFIG>/intermediates/dart" CACHE STRING "")

# Umbrella target to build all the Windows build files.
add_custom_target(flutter_assemble DEPENDS
  flutter_windows
)

# Properties to define for the Windows application.
define_property(TARGET PROPERTY FLUTTER_LIBRARY
  BRIEF_DOCS "The Flutter library"
  FULL_DOCS "The Flutter library")

# Add Flutter sub project.
add_subdirectory("${FLUTTER_ROOT}/packages/flutter_tools/bin/windows" flutter)

# Application build; not yet implemented.
project(${BINARY_NAME}_windows LANGUAGES CXX)

list(APPEND FLUTTER_PLUGIN_LIST
)

list(APPEND FLUTTER_FFI_PLUGIN_LIST
)

set(FLUTTER_PLUGIN_COUNT 0)
foreach(plugin ${FLUTTER_PLUGIN_LIST})
  math(EXPR FLUTTER_PLUGIN_COUNT "${FLUTTER_PLUGIN_COUNT} + 1")
endforeach(plugin)

if(FLUTTER_PLUGIN_COUNT GREATER 0)
  # Placeholder for future plugin registration.
endif()

add_executable(${BINARY_NAME}
  "runner.cpp"
  "utils.cpp"
  "utils.h"
  "win32_window.cpp"
  "win32_window.h"
  "flutter_window.cpp"
  "flutter_window.h"
  "${FLUTTER_MANAGED_DIR}/generated_plugins.cmake"
)

apply_standard_settings(${BINARY_NAME})

target_compile_definitions(${BINARY_NAME} PRIVATE
  "FLUTTER_VERSION=\"${FLUTTER_VERSION}\""
  "FLUTTER_VERSION_MAJOR=${FLUTTER_VERSION_MAJOR}"
  "FLUTTER_VERSION_MINOR=${FLUTTER_VERSION_MINOR}"
  "FLUTTER_VERSION_PATCH=${FLUTTER_VERSION_PATCH}"
  "FLUTTER_VERSION_PRERELEASE=\"${FLUTTER_VERSION_PRERELEASE}\""
  "FLUTTER_VERSION_BUILD_METADATA=\"${FLUTTER_VERSION_BUILD_METADATA}\""
  "PRODUCT_BUNDLE_IDENTIFIER=\"${PRODUCT_BUNDLE_IDENTIFIER}\""
)

target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}")

target_link_libraries(${BINARY_NAME} PRIVATE flutter flutter_wrapper_app)

add_dependency_subdir(flutter/ephemeral/.plugin_symlinks)

# Copy the .so/.dll/.dylib to the out directory for the respective platform
# as well as the flutter pubspec.yaml and assets and packages directories.
set(FLUTTER_LIBRARY "${FLUTTER_BUILD_DIR}/${FLUTTER_TARGET_PLATFORM}-${FLUTTER_BUILD_MODE}/${DART_LIB_OUT_DIR}/libflutter.so")

foreach(bundled_library ${FLUTTER_PLUGIN_LIST})
  list(APPEND FLUTTER_LIBRARIES
    "${FLUTTER_BUILD_DIR}/${FLUTTER_TARGET_PLATFORM}-${FLUTTER_BUILD_MODE}/${DART_LIB_OUT_DIR}/${bundled_library}"
  )
endforeach(bundled_library)
