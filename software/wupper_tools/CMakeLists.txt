cmake_minimum_required(VERSION 2.8.12)
project (wuppertools)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} --pedantic -Wall -fPIC ")


# TODO: Remove dependency on libpacketformat
include_directories("." "../drivers/" "../rcc_error/" "../DFDebug" "../regmap")

set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DDEBUG_LEVEL=1")

add_subdirectory(../drivers ./drivers)
add_subdirectory(../regmap ./regmap)

add_library(Wupper STATIC src/WupperCard.cpp src/WupperException.cpp )
target_link_libraries (Wupper regmap rt cmem_rcc DFDebug rcc_error)

add_executable(wupper-reset src/wupper-reset.cpp)
target_link_libraries (wupper-reset Wupper)

add_executable(wupper-config src/wupper-config.cpp)
target_link_libraries (wupper-config Wupper)

add_executable(wupper-dma-transfer src/wupper-dma-transfer.cpp)
target_link_libraries (wupper-dma-transfer Wupper)

add_executable(wupper-dump-blocks src/wupper-dump-blocks.cpp)
target_link_libraries (wupper-dump-blocks Wupper)

add_executable(wupper-throughput src/wupper-throughput.cpp)
target_link_libraries (wupper-throughput Wupper)

add_executable(wupper-info src/wupper-info.cpp)
target_link_libraries (wupper-info Wupper)

add_executable(wupper-irq-test src/wupper-irq-test.cpp)
target_link_libraries (wupper-irq-test Wupper pthread)

add_executable(wupper-dma-stat src/wupper-dma-stat.cpp)
target_link_libraries (wupper-dma-stat Wupper)

add_executable(wupper-wishbone src/wupper-wishbone.cpp)
target_link_libraries (wupper-wishbone Wupper)
