cmake_minimum_required(VERSION 3.23)
project(EvalEngine LANGUAGES CXX C)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION TRUE)

add_compile_options(
    -Wall
    -Wextra
    -Wpedantic
    -Werror
    -Wshadow
    -Wconversion
    -Wsign-conversion
    -Wold-style-cast
    -Wcast-qual
    -Wformat=2
    -O3
    -march=native
    -flto
    -DNDEBUG
)

# Find LLVM
find_package(LLVM REQUIRED CONFIG)
message(STATUS "Found LLVM ${LLVM_PACKAGE_VERSION}")
message(STATUS "CMAKE_PREFIX_PATH: ${CMAKE_PREFIX_PATH}")
message(STATUS "Using LLVMConfig.cmake in: ${LLVM_DIR}")
include_directories(${LLVM_INCLUDE_DIRS})
add_definitions(${LLVM_DEFINITIONS})
link_directories(${LLVM_LIBRARY_DIRS})

# Find Clang
find_package(Clang REQUIRED CONFIG)
include_directories(${CLANG_INCLUDE_DIRS})

# Set LLVM and Clang components
llvm_map_components_to_libnames(LLVM_LIBS core)
set(CLANG_LIBS clang-cpp)

# Convert text file to a header file using xxd
set(GENERATED_HEADER ${CMAKE_BINARY_DIR}/APInt_bin_string.h)

add_custom_command(
    OUTPUT ${GENERATED_HEADER}
    COMMAND xxd -i ../src/APInt.cpp > ${GENERATED_HEADER}
    COMMENT "Generating header file from text file"
)

# Add the generated file to the build
add_executable(eval_engine src/main.cpp)
target_include_directories(eval_engine PRIVATE ${CMAKE_BINARY_DIR})

add_custom_target(generate_header DEPENDS ${GENERATED_HEADER})
add_dependencies(eval_engine generate_header)

# Link against LLVM and Clang
target_link_libraries(eval_engine PRIVATE ${LLVM_LIBS} ${CLANG_LIBS})
target_link_options(eval_engine PRIVATE
    -Wl,--copy-dt-needed-entries
)
