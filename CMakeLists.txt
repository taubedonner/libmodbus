cmake_minimum_required(VERSION 3.27)

project(libmodbus LANGUAGES C)

if (WIN32)
    include(cmake/libmodbus-windows.cmake)
else ()
    include(cmake/libmodbus-linux.cmake)
endif ()
