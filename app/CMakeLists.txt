cmake_minimum_required(VERSION 3.0 FATAL_ERROR)
project(testbench)

# Set source and include folder ###########################################
set(SRC_FOLDER "${CMAKE_CURRENT_LIST_DIR}/src")

# Include universal (posits) ##############################################
include_directories("~/Documents/libs/universal/include")

add_executable(gen_FP_testbench ${SRC_FOLDER}/gen_FP_tb.cpp)
set_property(TARGET gen_FP_testbench PROPERTY CXX_STANDARD 17)

add_executable(gen_half_testbench ${SRC_FOLDER}/gen_half_tb.cpp)
set_property(TARGET gen_half_testbench PROPERTY CXX_STANDARD 17)

#add_executable(gen_testbench ${SRC_FOLDER}/gen_tb.cpp)
#set_property(TARGET gen_testbench PROPERTY CXX_STANDARD 17)
