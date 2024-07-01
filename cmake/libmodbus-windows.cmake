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

# Setup public and private source files

set(public_headers_source_dir ${CMAKE_CURRENT_SOURCE_DIR}/src)
set(public_headers_dest_dir ${CMAKE_CURRENT_BINARY_DIR}/generated-public)
set(private_sources_source_dir ${CMAKE_CURRENT_SOURCE_DIR}/src)
set(private_sources_dest_dir ${CMAKE_CURRENT_BINARY_DIR}/generated)

set(generated_public_headers)
set(generated_private_sources)

set(public_headers modbus.h modbus-rtu.h modbus-tcp.h)
set(private_sources modbus.c modbus-private.h modbus-data.c modbus-rtu.c modbus-rtu-private.h modbus-tcp.c modbus-tcp-private.h)

file(COPY ${private_sources_source_dir}/win32/config.h.win32 DESTINATION ${private_sources_dest_dir})
file(RENAME ${private_sources_dest_dir}/config.h.win32 ${private_sources_dest_dir}/config.h)
list(APPEND generated_private_sources ${private_sources_dest_dir}/config.h)
configure_file(${public_headers_source_dir}/modbus-version.h.in ${public_headers_dest_dir}/modbus/modbus-version.h)
list(APPEND generated_public_headers ${public_headers_dest_dir}/modbus/modbus-version.h)

foreach (file ${public_headers})
    file(COPY "${public_headers_source_dir}/${file}" DESTINATION ${public_headers_dest_dir}/modbus)
    list(APPEND generated_public_headers "${public_headers_dest_dir}/modbus/${file}")
endforeach ()

foreach (file ${private_sources})
    file(COPY "${private_sources_source_dir}/${file}" DESTINATION ${private_sources_dest_dir})
    list(APPEND generated_private_sources "${private_sources_dest_dir}/${file}")
endforeach ()

# Create library target

add_library(modbus_shared SHARED)

set_target_properties(modbus_shared PROPERTIES OUTPUT_NAME libmodbus)
target_compile_definitions(modbus_shared PRIVATE DLLBUILD)
target_include_directories(modbus_shared PRIVATE ${private_sources_dest_dir} ${public_headers_dest_dir}/modbus PUBLIC ${public_headers_dest_dir})
target_sources(modbus_shared PRIVATE ${generated_private_sources} PUBLIC ${generated_public_headers})

target_link_libraries(modbus_shared PRIVATE ws2_32)

if (MSVC)
    target_compile_options(modbus_shared PRIVATE /W0)
endif ()

add_library(modbus ALIAS modbus_shared)
