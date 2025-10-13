# Artifact Evaluation for "Nice to Meet You: Synthesizing Practical Abstract Transformers for MLIR"

The URL to the artifact repository:
[https://github.com/Hatsunespica/xdsl-smt/tree/artifact](https://github.com/Hatsunespica/xdsl-smt/tree/artifact)

This document provides instructions for evaluating the artifact associated with the paper #814 "Nice to Meet You: Synthesizing Practical Abstract Transformers for MLIR".
The artifact consists of NiceToMeetYou, the transformer synthesizer, the transformers which were synthesized for the paper, and scripts to evaluate these transformers.

## List of claims

### Claims Supported by the Artifact

This artifact contains our tool, NiceToMeetYou, and demonstrates how it can synthesize practical transformers for the KnownBits and ConstantRange domains.

Relative to the paper, the artifact demonstrates how to:

1. **Synthesize new transformers** for concrete operations in the abstract domains of _KnownBits_, and _ConstantRange_
(needed to fully reproduce tables 1, 2, and 3).

2. **Evaluate the precision** of synthesized transformers compared with LLVM's hand-written transformers
(needed for tables 1 and 2).

3. **Evaluate the precision gain** on transformers of the _KnownBits_ domain,
compared to the reduced product of transformers in _KnownBits_ and _ConstantRange_
(needed for table 3).

### Claims Not Supported by the Artifact

The artifact does not support our meta-theory in
Section 3 (An Ideal Algorithm for the Transformer Synthesis Problem)
and Section 4 (Randomly Searching for Abstract Transformers using MCMC).
We have only a tool that implements the algorithms from these sections,
no mechanized proofs.

## Getting Started: Download, installation, and sanity-testing

### Set Up the Environment

Prereqs: You must be on an arm64 or x86-64 machine with a recent version of Docker installed.
(We have tested on AArch64 Macbooks and an x86/Linux workstation.)

1. Download the compressed artifact, unzip it, and load it into your Docker registry via:

```bash
gunzip -c xdsl-smt-arm64.tar.gz | docker load
# or
gunzip -c xdsl-smt-amd64.tar.gz | docker load
# depending on your machine architeture
```

2. Run the Docker container interactivly via:

```bash
docker run -it --rm xdsl-smt:arm64
# or
docker run -it --rm xdsl-smt:amd64
```

3. This should give you a bash shell in the container. Once here, check that you're in the correct directory:

```bash
pwd
```

Expected output: `/xdsl_smt`

```bash
ls -lh
```

Expected output:

```
-rw-r--r--   1 root root 6.8K Oct 11 16:43 README.md
drwxr-xr-x   4 root root 4.0K Oct 11 16:45 build
drwxr-xr-x   2 root root 4.0K Oct 11 16:43 mlir-fuzz
-rw-r--r--   1 root root 1.5K Oct 11 16:43 pyproject.toml
drwxr-xr-x   3 root root 4.0K Oct 11 16:43 scripts
-rw-r--r--   1 root root  32K Oct 11 16:43 synth.png
drwxr-xr-x 116 root root 4.0K Oct 11 16:43 synthesized-transformers
drwxr-xr-x   8 root root 4.0K Oct 11 16:43 tests
drwxr-xr-x  12 root root 4.0K Oct 11 16:43 xdsl_smt
drwxr-xr-x   1 root root 4.0K Oct 11 16:45 xdsl_smt.egg-info
```

as a quick overview of some important files and dirs:

* `README.md`: The document you're reading now
* `synthesized-transformers/`: MLIR code for transformers synthesized with NiceToMeetYou, and used in the paper
* `tests/synth/Operations`: MLIR code for the concrete operations to be synthesized
* `tests/synth/KnownBits`: MLIR code specifing the KnownBits abstract domain
* `tests/synth/SConstRange`: MLIR code specifing the Signed Constant Range abstract domain
* `xdsl_smt/`: Python source code for NiceToMeetYou
* `xdsl_smt/eval_engine/src/`: C++ source code for NiceToMeetYou's evaluation engine

### Synthesizing Transformers

First let's make a new directory for some new transformers, run:

```bash
mkdir new-transformers
```

To synthesize a single transformer, run:

```bash
synth-transfer tests/synth/Operations/And.mlir                \
               -outputs_folder new-transformers/KnownBits_And \
               -random_seed 50                                \
               -domain KnownBits                              \
               -num_iters 1                                   \
               -total_rounds 25                               \
               -mbw 8,1000                                    \
               -hbw 32,2000,1000 64,2000,1000
```

This command takes about 30 seconds to run on an Apple M1 MacBook Pro.
This command synthesizes an abstract bitwise and operation in the KnownBits domain.
We expect this exact output on `stdout`:

```
init_solution	100.0000%	1.4439%
Iteration 0 starts...
Iteration 0 finished. Exact: 100.0000%, Size of the solution set: 2
Found a perfect solution
last_solution	100.00%	100.00%
```

And there should be a new directory, `new-transformers/KnownBits_And/`, which has these files:

* `KnownBits_And/debug.log`:     detailed debug info for each round the transformer synthesis
* `KnownBits_And/info.log`:      less detailed log file for synthesis parameters and result
* `KnownBits_And/iter0.mlir`:    sound transformers after the each iteration of synthesis (since we passed `-num_iters 1` then there'll just be one of these)
* `KnownBits_And/solution.mlir`: final transformer in mlir
* `KnownBits_And/solution.cpp`:  final transformer lowered to C++

Finally run this to make sure that the synthesized transformer matches the one we expect:

```bash
diff new-transformers/KnownBits_And/solution.mlir \
     artifact-outputs/kb-and-synth.mlir
```

We expect no output from this command.

---

Now let's synthesize a transformer in the UnsignedConstantRange (written as CR_U in the paper) domain, run:

```bash
synth-transfer tests/synth/Operations/AddNsw.mlir                  \
               -outputs_folder new-transformers/UConstRange_AddNsw \
               -random_seed 233                                    \
               -domain UConstRange                                 \
               -num_iters 1                                        \
               -total_rounds 150                                   \
               -mbw 8,1500                                         \
               -hbw 16,2000,1500 32,2000,1500 64,2000,1500
```

This command takes about 3 minutes to run on an Apple M1 MacBook Pro.
This command synthesizes an abstract addition with no signed wrap in the UnsignedConstantRange domain.
We expect this exact output on `stdout`:

```
init_solution	100.0000%	63.3292%
Iteration 0 starts...
Iteration 0 finished. Exact: 63.3484%, Size of the solution set: 2
last_solution	100.00%	63.35%
```

Expect similar files as described above in, but now in the dir, `new-transformers/UConstRange_AddNsw`.

Finally, run this to make sure that the synthesized transformer matches the one we expect:

```bash
diff new-transformers/UConstRange_AddNsw/solution.mlir \
     artifact-outputs/cr-add-synth.mlir
```

We expect no output from this command.


### Evaluating Transformers

Now that we have synthesized some transformers, let's evaluate their precision and compare with LLVM's transformer.

Run this command to evaluate the new transformers:

```bash
eval-final tests/synth/Operations/ \
           new-transformers/       \
           -random_seed 75         \
           -lbw                    \
           -mbw 8,5000             \
           -hbw 64,5000,5000
```

This command takes about 1 minutes to run on an Apple M1 MacBook Pro.
Expected output:

```
#################################   KnownBits And   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 5000    | 3131.38 | 0       | 0       | 0         ||   8+  | 00.04% | 100.0% | 100.0% | 100.0%
64* | 5000    | 3125.52 | 0       | 0       | 0         ||   
#################################   UConstRange AddNsw   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 5000    | 1546    | 1509.12 | N/A     | N/A       ||   8+  | 67.82% | 67.82% | N/A    | N/A   
64* | 4917    | 4305.81 | 4300.92 | N/A     | N/A       ||
```

There is one table for each concrete operation and domain being evaluated (e.g. KnownBits And).
Each table includes the number of abstract values uses for testing (cases),
the measurement for a transformer which always returns top (sound and maximally imprecise),
the measurement for the synthesized transformer,
the measurement for LLVM's transformer (marked N/A if LLVM doesn't have a transformer),
and the meet between LLVM's transformer and the synthesized transformer.

On the left side of the table, the measurment is a sum of the "Dists" (or "norm" as its called in the paper).
This is measured at all bitwidths.
On the right side of the table the measurment is a sum of the "Exacts": the number of times the transformer had a maximally precise output.
This is only measured at bitwidths for which it is computationally tractable to enumerate all concrete values in an abstract value.
For a detailed explanation of how to interpret these numbers, refer to Tables 1 and 2 in the paper.

**N.B.** `eval-final` relies on the name of the directory to determine the domain and operation to use,
so misnamed directories will result in errors.


## Evaluation instructions (Functionality)

### Evaluating Transformers

Let's evaluate transformers that were previously synthesized by our tool (stored in `synthesized-transformers/`)
with the same seed used to generate Table 1 and Table 2 in the paper:

```bash
eval-final tests/synth/Operations/    \
           synthesized-transformers/  \
           -random_seed 100           \
           -lbw                       \
           -mbw 8,25000               \
           -hbw 64,25000,5000         \
           > table-1-2-results.txt
```

This command takes about 15 minutes to run on an Apple M1 MacBook Pro.
You can run `cat table-1-2-results.txt` and verify that the results match with those found in Table 1 and Table 2 of the paper.
Or run:

```bash
diff table-1-2-results.txt \
     artifact-outputs/eval-results.txt
```

And expect no output.

**N.B.:** One of our artifact testers saw a one-line diff due to unexpected whitespace.
If this happens to you, try again with `diff -w` (ignore whitespace) or even `diff -Z` (ignore trailing whitespace).
Any non-whitespace diff is a bug, please report it to us!

**N.B.:** When comparing results gathered to those in Table 2,
note that operations marked with an asterisk in the paper use the SignedConstantRange domain (written as CR_S in the paper), while operations which are unmarked use the UnsignedConstantRange domain.

(See Section 6.1.1 of the paper for details on how CR_U and CR_S relate to LLVM's _ConstantRange_ domain.)

---

Now, for table 3, let's evaluate the KnownBits transformers which became more precise after reducing with a transformer from ConstantRange.
We will use the same transformers from before (stored in `synthesized-transformers/`), run:

```bash
eval-final tests/synth/Operations/    \
           synthesized-transformers/  \
           -random_seed 100           \
           -reduced-product           \
           -lbw                       \
           -mbw 8,25000               \
           -hbw 64,25000,5000         \
           > table-3-results.txt
```

This command takes about 3 minutes to run on an Apple M1 MacBook Pro.
Check that the results match with those found in Table 3 of the paper.
You can run `cat table-3-results.txt` and verify that the results match with those found in Table 1 and Table 2 of the paper.
Or run:

```bash
diff table-3-results.txt \
     artifact-outputs/rp-results.txt
```

And expect no output.

**N.B.** Same as above, one of our testers saw a diff due to trailing whitespace.
Re-run with `diff -Z` if this happens to you.


### Synthesizing One Off Transformers

To generate a single transformers for a single concrete operations in a single domain,
run `synth-transfer --help` to get information about which flags may be used for synthesis.
Here are a few notes to get started:

* Domain options are `KnownBits`, `UConstRange`, and `SConstRange`
* All concrete operations are stored in `tests/synth/Operations/`
* The `-num_iters` flag sets the number of *outer loops* (see Section 5.1 for more information)
* The `-num_rounds` flag sets the number of *inner loops* (see Section 5.1 for more information)
* See Section 5.1.4: "**Test generation by bitwidth**" for further explanation on the flags `-lbw`, `-mbw`, and `-hbw`.

**N.B.** When running `synth-transfer` with low `-num_iters` or low `-num_rounds`,
it is quite likely that NiceToMeetYou will fail to find any valid solutions during synthesis.

### Synthesizing All Transformers

**N.B.** While creating this artifact, we discovered that we could not perfectly reproduce the evaluation.
We can synthesize transformers, and we can use the new transformers to make tables that are very similar to
the paper. But, the tables are not an exact match. We believe the difference is due to changes in Python's random
number generation, specifically `randint`. At any rate, for the final version of the paper, we are planning
to generate tables via the Docker image to get an exact match.

This is the exact command we used to generate all transformers, which will run in this Docker container and produce similar transformers.

**N.B.** this command takes >60 hours to run on an Apple M1 Macbook Pro

```bash
benchmark-synth -outputs_folder outputs \
                -num_iters 3            \
                -total_rounds 1000      \
                -random_seed 23333      \
                -mbw 8,1000             \
                -hbw 16,2000,1000 32,2000,1000 64,2000,1000
```

Expect similar output to this on `stdout` with slight variations depending on thread scheduling/number of cores:

```
Running KnownBits Abds
Running KnownBits AddNsw
Running KnownBits And
Running KnownBits AvgCeilS
Running KnownBits AvgFloorU

etc...

init_solution	100.0000%	1.4320%
Iteration 0 starts...
init_solution	100.0000%	1.4320%
Iteration 0 starts...
init_solution	100.0000%	30.9666%
Iteration 0 starts...
init_solution	100.0000%	39.7613%
Iteration 0 starts...
init_solution	100.0000%	39.7733%

etc...
```

And in the `outputs/` dir expect to see subfolders for each domain and concrete operation (e.g. `SConstRange_AvgCeilS/`).
Each of these folders will have the list of files as described above for `KnownBits_And/`.

## Additional Artifact Description (Reproducibility)

### Programmibility

#### Adding a new operation

Let's create a transformer for a fused multiply add operation.
Let's assume that our operation does something like this:

```python
def fma(a: int, b: int) -> int:
    mul = a * b
    add = mul + a
    return add
```

First we must define our concrete operation in mlir, so we make `tests/synth/Operations/fma.mlir`

```mlir
module {
  // Definition of the concrete operation itself
  func.func @concrete_op(%arg0: !transfer.integer, %arg1: !transfer.integer) -> !transfer.integer {
    %0 = "transfer.mul"(%arg0, %arg1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %1 = "transfer.add"(%0, %arg0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    return %1 : !transfer.integer
  }

  // Function signature of an abstract transformer of our concrete operation
  func.func @FMAImpl(%arg0: !transfer.abs_value<[!transfer.integer,!transfer.integer]>, %arg1: !transfer.abs_value<[!transfer.integer,!transfer.integer]>) -> !transfer.abs_value<[!transfer.integer,!transfer.integer]> attributes {CPPCLASS = ["circt::comb::XXXOp"], applied_to = ["comb.xx"], is_forward = true} {
    return %arg0 : !transfer.abs_value<[!transfer.integer,!transfer.integer]>
  }
}
```

Then synthesize a KnownBits transformer by running:

```bash
synth-transfer tests/synth/Operations/fma.mlir \
               -domain KnownBits               \
               -random_seed 50                 \
               -num_iters 1                    \
               -total_rounds 250
```

Output (after about 5 mins) should be similar to the following:

```
init_solution	100.0000%	24.9458%
Iteration 0 starts...
Iteration 0 finished. Exact: 49.8103%, Size of the solution set: 3
last_solution	100.00%	49.81%
```

Thus showing the ease of adding new concrete operations and synthesizing transformers for them.


#### Adding a new Galois-connection abstract domain

This is a bit more involved, but still feasible for a determined researcher

1. Add a new class in `xdsl_smt/eval_engine/src/AbstVal.h` which inherits from `AbstVal` and fufils the `AbstractDomain` concept requirment.
2. Add calls to the new domain in `xdsl_smt/eval_engine/src/main.cpp` and `xdsl_smt/eval_engine/src/xfer_enum/xfer_enum.cpp`
3. Rebuild the C++ project (instructions for this are in `README.md`)
4. Add the domain to the `AbstractDomain` class in `xdsl_smt/eval_engine/eval.py`
5. Create a new directory in `tests/synth/` with the name of the new domain
6. In this directory make the files:
    * `get_constraint.mlir`          : An mlir definition of a valid abstract value
    * `get_instance_constraint.mlir` : An mlir definition of whether or not a given concrete value resides in a given abstract value
    * `meet.mlir`                    : An mlir definition of the meet between two abstract values
    * `top.mlir`                     : An mlir definition of the top element in your domain
7. Finally synthesize transformers in your new domain by running: `synth-transfer tests/synth/Operations/Add.mlir -domain YourNewDomain`

### Algorithms, Definitions, and Equations From the Paper

| Paper Sec. | Section Heading                 | Source File or Directory                             | Line Number(s)                            |
|------------|---------------------------------|------------------------------------------------------|-------------------------------------------|
| Sec. 2.1.1 | Concrete Transformers           | `tests/synth/Operations`                             | all                                       |
| Sec. 2.1.2 | Abstract Domains                | `xdsl_smt/eval_engine/src/AbstVal.h`                 | 113-257(KB), 259-389(UCR), 391-521(SCR)   |
| Sec. 2.1.3 | DSL Operations                  | `xdsl_smt/dialects/transfer.py`                      | 796-853                                   |
| Def. 2.1   | Meet of Transformers            | `xdsl_smt/eval_engine/src/AbstVal.h`                 | 152-154(KB), 288-294(UCR), 420-426(SCR)   |
| Def. 2.2   | Soundness of Transformers       | `xdsl_smt/eval_engine/src/Eval.h`                    | 104                                       |
| Def. 2.3   | Transformer-synthesis Problem   | `xdsl_smt/eval_engine/src/Eval.h`                    | 97-113, 121-135                           |
| Algo. 1    | IdealSynthesizeBestTransformers | `xdsl_smt/cli/synth_transfer.py`                     | 463-635                                   |
| Equation 1 | Minimization of Norm            | `xdsl_smt/eval_engine/src/Eval.h`                    | 106                                       |
| Algo. 2    | MCMCBestTransformer             | `xdsl_smt/cli/synth_one_iteration.py`                | 96-317                                    |
| Equation 5 | Soundness(f)                    | `xdsl_smt/utils/synthesizer_utils/cost_model.py`     | 14-17                                     |
| Equation 6 | Improvement(f, g)               | `xdsl_smt/utils/synthesizer_utils/cost_model.py`     | 14-17                                     |
| Algo. 3    | Initialize and mutate programs  | `xdsl_smt/utils/synthesizer_utils/mcmc_sampler.py`   | 141-247, 249-279                          |
| Algo. 4    | Initialize and mutate conds     | `xdsl_smt/utils/synthesizer_utils/mcmc_sampler.py`   | 141-247, 249-279                          |
| Sec. 5.1.4 | Bitvector representation        | `xdsl_smt/eval_engine/src/APInt.h`                   | all                                       |
| Sec. 5.1.4 | Test generation by bitwidth     | `xdsl_smt/eval_engine/src/xfer_enum/enum_domain.cpp` | 23-29(lo bw), 31-42(mid bw), 44-58(hi bw) |
| Sec. 5.1.5 | Size Functions                  | `xdsl_smt/eval_engine/src/AbstVal.h`                 | 187-198(KB), 323-336(UCR), 455-468(SCR)   |
| Sec. 5.1.7 | Verifier                        | `xdsl_smt/utils/synthesizer_utils/verifier_utils.py` | all                                       |
| Sec. 5.2.2 | LLVM's LLJIT                    | `xdsl_smt/eval_engine/src/jit.h`                     | all                                       |
| Sec. 6     | LLVM Domains                    | `xdsl_smt/eval_engine/src/llvm_tests.h`              | all                                       |
| Sec. 6     | Reduced Product                 | `xdsl_smt/eval_engine/src/reduced_prod/RPEval.h`     | all                                       |
