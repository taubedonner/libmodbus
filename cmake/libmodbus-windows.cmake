if (NOT WIN32)
    return()
endif ()

# Generate config and version

set(LIBMODBUS_VERSION)
set(LIBMODBUS_VERSION_MAJOR)
set(LIBMODBUS_VERSION_MINOR)
set(LIBMODBUS_VERSION_MICRO)

set(version_file_path "${CMAKE_CURRENT_SOURCE_DIR}/configure.ac")
if (EXISTS "${version_file_path}")
    file(STRINGS "${version_file_path}" version REGEX "m4_define\\(\\[libmodbus_version_(major|minor|micro)\\]")
    string(REGEX REPLACE ".*_major\\], \\[([0-9]*)\\]\\).*" "\\1" major "${version}")
    string(REGEX REPLACE ".*_minor\\], \\[([0-9]*)\\]\\).*" "\\1" minor "${version}")
    string(REGEX REPLACE ".*_micro\\], \\[([0-9]*)\\]\\).*" "\\1" micro "${version}")
    if (NOT major STREQUAL "" AND NOT minor STREQUAL "" AND NOT micro STREQUAL "")
        set(LIBMODBUS_VERSION "${major}.${minor}.${micro}")
        set(LIBMODBUS_VERSION_MAJOR ${major})
        set(LIBMODBUS_VERSION_MINOR ${minor})
        set(LIBMODBUS_VERSION_MICRO ${micro})
    endif ()
endif ()

file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/src/win32/config.h.win32 DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/generated)
file(RENAME ${CMAKE_CURRENT_BINARY_DIR}/generated/config.h.win32 ${CMAKE_CURRENT_BINARY_DIR}/generated/config.h)
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/src/modbus-version.h.in ${CMAKE_CURRENT_BINARY_DIR}/generated-public/modbus-version.h)

# Setup public and private source files

set(public_headers modbus.h modbus-rtu.h modbus-tcp.h)
set(generated_public_headers)
foreach (file ${public_headers})
    file(COPY "${CMAKE_CURRENT_SOURCE_DIR}/src/${file}" DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/generated-public)
    list(APPEND generated_public_headers "${CMAKE_CURRENT_BINARY_DIR}/generated-public/${file}")
endforeach ()
list(APPEND generated_public_headers ${CMAKE_CURRENT_BINARY_DIR}/generated-public/modbus-version.h)

set(private_sources modbus.c modbus-private.h modbus-data.c modbus-rtu.c modbus-rtu-private.h modbus-tcp.c modbus-tcp-private.h)
set(generated_private_sources)
foreach (file ${private_sources})
    file(COPY "${CMAKE_CURRENT_SOURCE_DIR}/src/${file}" DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/generated)
    list(APPEND generated_private_sources "${CMAKE_CURRENT_BINARY_DIR}/generated/${file}")
endforeach ()
list(APPEND generated_private_sources ${CMAKE_CURRENT_BINARY_DIR}/generated/config.h)

# Create library target

add_library(modbus_shared SHARED)

set_target_properties(modbus_shared PROPERTIES OUTPUT_NAME libmodbus)
target_compile_definitions(modbus_shared PRIVATE DLLBUILD)
target_include_directories(modbus_shared PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/generated PUBLIC ${CMAKE_CURRENT_BINARY_DIR}/generated-public)
target_sources(modbus_shared PRIVATE ${generated_private_sources} PUBLIC ${generated_public_headers})

target_link_libraries(modbus_shared PRIVATE ws2_32)

if (MSVC)
    target_compile_options(modbus_shared PRIVATE /W0)
endif ()

add_library(modbus ALIAS modbus_shared)
