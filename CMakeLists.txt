cmake_minimum_required(VERSION 3.27)

project(libmodbus LANGUAGES C)

if (WIN32)
    include(cmake/libmodbus-windows.cmake)
else ()
    include(cmake/libmodbus-linux.cmake)
endif ()

#add_executable(modbus_test)
#target_sources(modbus_test PRIVATE main.cpp)
#target_link_libraries(modbus_test modbus)
