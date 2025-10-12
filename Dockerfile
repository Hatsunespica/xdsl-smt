# syntax=docker/dockerfile:1.7

# ======================================================================
# STAGE 0: Base build image with toolchain
# ======================================================================
FROM python:3.11-slim AS build-base

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_NO_CACHE_DIR=1 PIP_DISABLE_PIP_VERSION_CHECK=1 PYTHONDONTWRITEBYTECODE=1

# System deps to build LLVM + CMake projects + Python wheels
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential cmake ninja-build git curl ca-certificates \
    python3-dev pkg-config lld xxd vim-tiny vim nano \
    zlib1g-dev libxml2-dev libedit-dev libffi-dev libncurses-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/src

# ======================================================================
# STAGE 1: Build LLVM (shared) from source at a pinned commit
# ======================================================================
FROM build-base AS llvm-build

# 1) binutils headers (LLVM_gold needs this include dir)
RUN git clone --depth 1 git://sourceware.org/git/binutils-gdb.git /opt/src/binutils-gdb

# Bring in your local llvm-project checkout as a named build context
# You MUST pass: --build-context llvmsrc=/path/to/llvm-project
RUN mkdir -p /opt/src/llvm-project
# TODO uncomment
COPY --from=llvmsrc /llvm /opt/src/llvm-project/llvm
COPY --from=llvmsrc /clang /opt/src/llvm-project/clang
COPY --from=llvmsrc /mlir /opt/src/llvm-project/mlir
COPY --from=llvmsrc /cmake /opt/src/llvm-project/cmake

ARG JOBS=2
ENV JOBS=${JOBS}

# 3) Configure + build
WORKDIR /opt/src/llvm-project/build
RUN cmake -GNinja \
  -DLLVM_ENABLE_RTTI=ON \
  -DLLVM_ENABLE_EH=ON \
  -DBUILD_SHARED_LIBS=ON \
  -DLLVM_BINUTILS_INCDIR=/opt/src/binutils-gdb/include \
  -DCMAKE_BUILD_TYPE=Release \
  -DLLVM_TARGETS_TO_BUILD="X86;AArch64" \
  -DLLVM_ENABLE_ASSERTIONS=ON \
  -DLLVM_ENABLE_PROJECTS="llvm;clang" \
  -DLLVM_INCLUDE_BENCHMARKS=OFF \
  -DLLVM_INCLUDE_TESTS=OFF \
  -DLLVM_INCLUDE_DOCS=OFF \ 
  -DLLVM_INCLUDE_EXAMPLES=OFF \
  -DLLVM_USE_LINKER=lld \
  ../llvm

# This is the long step
RUN ninja -j${JOBS}

# Convenience env for downstream stages
ENV LLVM_BUILD_PREFIX=/opt/src/llvm-project/build
ENV LLVM_CLANGXX=/opt/src/llvm-project/build/bin/clang++

# ======================================================================
# STAGE 2: Project build (clone xdsl-smt@artifact → build eval_engine → wheel)
# ======================================================================
FROM llvm-build AS project-build
WORKDIR /app

RUN git clone --branch artifact --single-branch https://github.com/Hatsunespica/xdsl-smt.git /app/xdsl_smt

# Python builder bootstrap
RUN python -m pip install --upgrade pip wheel setuptools

# ---- Build the Eval Engine using the freshly built LLVM toolchain ----
WORKDIR /app/xdsl_smt/xdsl_smt/eval_engine
RUN mkdir -p build && cd build && \
    cmake .. \
      -DCMAKE_CXX_COMPILER=${LLVM_CLANGXX} \
      -DCMAKE_PREFIX_PATH=${LLVM_BUILD_PREFIX} && \
    make

# Build ONLY your wheel (no deps), then build a wheelhouse of runtime deps
WORKDIR /app/xdsl_smt
RUN mkdir -p /app/dist /app/wheelhouse \
 && python -m pip wheel . --no-deps -w /app/dist \
 && python -m pip download --only-binary=:all: -d /app/wheelhouse \
      "z3-solver>=4.12.2,<4.16" \
      "xdsl==0.41.0" \
      "immutabledict<4.2.2" \
      "ordered-set==4.1.0" \
      "typing-extensions<5,>=4.7"

# Put your wheel into the wheelhouse too (so we can install with --no-index)
RUN cp /app/dist/*.whl /app/wheelhouse/


# ======================================================================
# STAGE 3: Runtime image (slim) — install wheel + LLVM .so’s
# ======================================================================
FROM python:3.11-slim AS runtime

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_NO_CACHE_DIR=1 PIP_DISABLE_PIP_VERSION_CHECK=1 PYTHONDONTWRITEBYTECODE=1

# Minimal runtime OS deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash libstdc++6 zlib1g libxml2 libedit2 libffi8 libncurses6 \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/llvm/lib
COPY --from=llvm-build /opt/src/llvm-project/build/lib /opt/llvm/lib
ENV LD_LIBRARY_PATH=/opt/llvm/lib:${LD_LIBRARY_PATH}
RUN printf "/opt/llvm/lib\n" > /etc/ld.so.conf.d/llvm.conf && ldconfig

# Bring the entire project SOURCE into the container's DEFAULT dir
# (This is now the working directory when the container starts)
WORKDIR /xdsl-smt
COPY --from=project-build /app/xdsl_smt /xdsl-smt

# Copy the wheelhouse (deps + your wheel)
COPY --from=project-build /app/wheelhouse /wheelhouse

# Install from the wheelhouse ONLY (no network, no source builds)
RUN python -m pip install --no-index --find-links /wheelhouse \
    z3-solver xdsl immutabledict ordered-set typing-extensions \
 && python -m pip install -e /xdsl-smt

ENV TERM=xterm-256color
CMD ["/bin/bash"]
