cmake_minimum_required(VERSION 3.4.3)

set(PACKAGE wuppercodegen-examples)
set(PACKAGE_VERSION 0.7.2)

include(FELIX)

set(CMAKE_DISABLE_IN_SOURCE_BUILD ON)
set(CMAKE_DISABLE_SOURCE_CHANGES  OFF)

SET_DIRECTORY_PROPERTIES(PROPERTIES CLEAN_NO_CUSTOM 1)

set(CMAKE_VERBOSE_MAKEFILE OFF)
set(CMAKE_COLOR_MAKEFILE   ON)

set(WUPPER_CODE_GEN ./../wuppercodegen/cli.py)

add_custom_command(
    OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/simple_vhdl/simple_vhdl.vhd
    COMMAND ${WUPPER_CODE_GEN} simple_vhdl/simple_vhdl.yaml simple_vhdl/simple_vhdl.vhd.template simple_vhdl/simple_vhdl.vhd
    DEPENDS ${WUPPER_CODE_GEN} simple_vhdl/simple_vhdl.yaml simple_vhdl/simple_vhdl.vhd.template
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)
add_custom_target(simple_vhdl ALL DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/simple_vhdl/simple_vhdl.vhd)

add_custom_command(
    OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/register_list/register_list.txt
    COMMAND ${WUPPER_CODE_GEN} register_list/register_list.yaml register_list/register_list.txt.template register_list/register_list.txt
    DEPENDS ${WUPPER_CODE_GEN} register_list/register_list.yaml register_list/register_list.txt.template
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)
add_custom_target(register_list ALL DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/register_list/register_list.txt)
