cmake_minimum_required(VERSION 3.20)

project(libmodbus LANGUAGES C)

if (WIN32)
    include(cmake/libmodbus-windows.cmake)
else ()
    include(cmake/libmodbus-unix.cmake)
endif ()

#add_executable(modbus_test)
#target_sources(modbus_test PRIVATE main.c)
#target_link_libraries(modbus_test modbus)
