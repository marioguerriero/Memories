project(memories)
cmake_minimum_required(VERSION 2.8.10)

# Instruct CMake to run moc automatically when needed.
set(CMAKE_AUTOMOC ON)
# Find includes in corresponding build directories
set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(MODULES_DIR "${CMAKE_INSTALL_PREFIX}/share/memories/modules")

# Include cmake modules
list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

# Find the QtWidgets library
find_package(Qt5Core            REQUIRED)
find_package(Qt5PrintSupport    REQUIRED)
find_package(Qt5Network         REQUIRED)
find_package(Qt5Quick           REQUIRED)

add_definitions(-DWITHQT5=1)

# build flags
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")

get_target_property(QMAKE_EXECUTABLE Qt5::qmake LOCATION)
exec_program(${QMAKE_EXECUTABLE} ARGS "-query QT_INSTALL_QML" OUTPUT_VARIABLE QT_IMPORTS_DIR)
file(TO_CMAKE_PATH "${QT_IMPORTS_DIR}" QT_IMPORTS_DIR)

add_subdirectory(modules)
add_subdirectory(qml)
add_subdirectory(resources)
add_subdirectory(po)
# TODO: add translations
