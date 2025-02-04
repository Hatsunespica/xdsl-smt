cmake_minimum_required(VERSION 3.23)
project(EvalEngine LANGUAGES CXX C)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

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
)

# Find LLVM
find_package(LLVM REQUIRED CONFIG)
message(STATUS "Found LLVM ${LLVM_PACKAGE_VERSION}")
include_directories(${LLVM_INCLUDE_DIRS})
add_definitions(${LLVM_DEFINITIONS})
link_directories(${LLVM_LIBRARY_DIRS})

# Find Clang
find_package(Clang REQUIRED CONFIG)
include_directories(${CLANG_INCLUDE_DIRS})

# Set LLVM and Clang components
llvm_map_components_to_libnames(LLVM_LIBS core)
set(CLANG_LIBS clang-cpp)

add_executable(eval_engine src/jit.cpp)

# Link against LLVM and Clang
target_link_libraries(eval_engine PRIVATE ${LLVM_LIBS} ${CLANG_LIBS})
