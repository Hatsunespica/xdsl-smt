# Artifact Evaluation for "Nice to Meet You: Synthesizing Practical Abstract Transformers for MLIR"

The URL to the artifact repository:
**TODO**

The commit hash of the artifact:
**TODO**

This document provides instructions for evaluating the artifact associated with the paper "Nice to Meet You: Synthesizing Practical Abstract Transformers for MLIR".
The artifact consists of NiceToMeetYou, the transformer synthesizer, the transformers which were synthesized for the paper, and scripts to evaluate these transformers.

**TODO** Add a note for which arches this artifact will run on

## Overview of Claims

### Claims Supported by the Artifact

This artifact contains our tool, NiceToMeetYou, and demonstrates how it can synthesize practical transformers for the KnownBits and ConstantRange domains.

Relative to the paper, the artifact demonstrates how to:

1. **Synthesize new transformers** for concrete operations in the abstract domains of _KnownBits_, and _ConstantRange_.

2. **Evaluate the precision** of synthesized transformers compared with LLVM's hand-written transformers
(See Section 6.1.1 of the paper for details on the comparison to LLVM's _ConstantRange_ domain).

3. **Evaluate the precision gain** on transformers of the _KnownBits_ domain,
compared to the reduced product of transformers in _KnownBits_ and transformers in _ConstantRange_.

### Claims Not Supported by the Artifact

The artifact does not support our meta-theory in
Section 3 (An Ideal Algorithm for the Transformer Synthesis Problem),
and Section 4 (Randomly Searching for Abstract Transformers using MCMC)

## Getting Started Guide

### Set Up the Environment

**TODO** add instructions for getting the docker image

### Running the Benchmark

**TODO** just add basic docker stuff, like where in the fs it should drop you

#### Synthesizing Transformers

First make a directory for our new transformers, run:

```bash
mkdir new-transformers
```

To synthesize a single transformer run:

```bash
synth-transfer tests/synth/Operations/And.mlir                  \
               -outputs_folder new-transformers/KnownBits_And   \
               -random_seed 50                                  \
               -domain KnownBits                                \
               -num_iters 1                                     \
               -total_rounds 150                                \
               -mbw 8,1000                                      \
               -hbw 16,2000,1000 32,2000,1000 64,2000,1000
```

This synthesizes an abstract bitwise and operation in the KnownBits domain
(The runtime of this command was 3 minutes on an Apple M1 Macbook Pro).
We expect this exact output on `stdout`:

```
init_solution	100.0000%	1.4320%
Iteration 0 starts...
Iteration 0 finished. Exact: 100.0000%, Size of the solution set: 2
Found a perfect solution
last_solution	100.00%	100.00%
```

And there should be a new directory, `new-transformers/KnownBits_And/`, which has these files:

* `KnownBits_And/debug.log`     : detailed debug info for each round the transformer synthesis
* `KnownBits_And/info.log`      : less detailed log file for synthesis parameters and result
* `KnownBits_And/iter0.mlir`    : sound transformers after the first iteration of synthesis
* `KnownBits_And/solution.mlir` : final transformer in mlir
* `KnownBits_And/solution.cpp`  : final transformer lowered to C++

---

Now let's synthesize a transformer in the UnsignedConstantRange (written as CR_U in the paper) domain, run:

```bash
synth-transfer tests/synth/Operations/AddNsw.mlir                    \
               -outputs_folder new-transformers/UConstRange_AddNsw   \
               -random_seed 50                                       \
               -domain UConstRange                                   \
               -num_iters 1                                          \
               -total_rounds 150                                     \
               -mbw 8,1000                                           \
               -hbw 16,2000,1000 32,2000,1000 64,2000,1000
```

This synthesizes an abstract addition with no signed wrap in the UnsignedConstantRange domain
(The runtime of this command was also 3 minutes on an Apple M1 Macbook Pro).
We expect this exact output on `stdout`:

```
init_solution	100.0000%	63.1206%
Iteration 0 starts...
Iteration 0 finished. Exact: 63.3619%, Size of the solution set: 1
last_solution	100.00%	63.36%
```

Also expect similar files as described above in `new-transformers/UConstRange_AddNsw`

---

To generate the exact transformers used in the evaluation section of the paper (tables 1, 2, and 3),
(note that copies of these transformers may also be found in the `synthesized-transformers/` directory), run:

```bash
benchmark-synth -outputs_folder outputs \
                -num_iters 3            \
                -total_rounds 1000      \
                -random_seed 23333      \
                -mbw 8,1000             \
                -hbw 16,2000,1000 32,2000,1000 64,2000,1000
```

**N.B.** this command takes about 55 hours to run on an Apple M1 Macbook Pro

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

To generate other concrete operations with other domains,
run `synth-transfer --help` to get information about which flags may be used for synthesis.
Here are a few notes to get started:

* Domain options are `KnownBits`, `UConstRange`, and `SConstRange`
* All concrete operations are stored in `tests/synth/Operations/`
* See Section 5.1 for more information about the *outer loop* of synthesis, this maps to the `-num_iters` flag.
* See Section 5.1 for more information about the *inner loop* of synthesis, this maps to the `-num_rounds` flag.
* See Section 5.1.4: "**Test generation by bitwidth**" for further explination on the flags `-lbw`, `-mbw`, and `-hbw`.

**N.B.** When running `synth-transfer` with low `-num_iters` or low `-num_rounds`,
it is quite likely that NiceToMeetYou will fail to find any valid solutions during synthesis.

#### Evaluating Transformers

Now that we have synthesied some transformers, lets evaluate their precision and compare with LLVM's transformer.

Run this command to evaluate the new transformers:

```bash
eval-final tests/synth/Operations/ \
           new-transformers/       \
           -random_seed 50         \
           -lbw                    \
           -mbw 8,1000             \
           -hbw 64,1000,1000
```

Which should result in the exact output on `stdout`:

```
#################################   KnownBits And   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 1000    | 619     | 0       | 0       | 0         ||   8+  | 00.00% | 100.0% | 100.0% | 100.0%
64* | 1000    | 624.328 | 0       | 0       | 0         ||   
#################################   UConstRange AddNsw   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 1000    | 319.125 | 309.375 | N/A     | N/A       ||   8+  | 66.80% | 66.80% | N/A    | N/A   
64* | 979     | 883.516 | 882.547 | N/A     | N/A       ||
```

For an explination of these results refer to Table 1, and Table 2 of the paper.

**N.B.** `eval-final` relies on the name of the directory to determine the domain and operation to use,
so misnamed directories will result in errors.

---

Now let's evaluate transformers synthesized by our tool (stored in `synthesized-transformers/`),
with the same seed used to generate the results in Table 1 and Table 2 of the paper, run:

```bash
eval-final tests/synth/Operations/    \
           synthesized-transformers/  \
           -random_seed 100           \
           -lbw                       \
           -mbw 8,25000               \
           -hbw 64,25000,5000
```

This command takes about 15 minutes to run on an Apple M1 MacBook Pro.
See the appendix for the exact output expected from this command,
and verify that the results match with those found in Table 1 and Table 2 of the paper.

**N.B. 1:** When comparing output note that the order of these results may differ slightly due to thread scheduling.

**N.B. 2:** When comparing results in Table 2
note that operations marked with an asterix in the paper use the SignedConstantRange domain (written as CR_S in the paper), while operations which are unmarked use the UnsignedConstantRange domain
(See Section 6.1 for more details on the ConstantRange comparisons).

**N.B. 3:** The no solution found messages are expected, and represent a few operations for which we weren't able to synthesized transformers for.

---

Now look at the KnownBits transformers which became more precise after reducing with a transformer from ConstantRange.
Using the same transformers from before (stored in `synthesized-transformers/`), run:

```bash
eval-final tests/synth/Operations/    \
           synthesized-transformers/  \
           -random_seed 100           \
           -reduced-product           \
           -lbw                       \
           -mbw 8,25000               \
           -hbw 64,25000,5000
```

This command takes about 3 minutes to run on an Apple M1 MacBook Pro.
See the appendix for the exact output expected from this command,
and verify that the results match with those found in Table 3 of the paper.

## Reusability

### Programibility

#### Adding a new operation

**TODO**
1. Add MLIR code for the op
2. Add SMT lowering for the op
3. Add C++ lowering for the op
4. Run?

#### Adding a new galios-connection abstract domain

**TODO**
1. Add C++ for the domain
2. Add MLIR for the domain
3. Add Python for the domain
4. Run?

### Algorithms

**TODO** this list is very incomplete
1. Algorithm 1. Can't really cite a specific line of code
2. Algorithm 2. MCMC
3. Soundness
4. prec

## Apendix

### Table 1 and Table 2 Evaluation Results

This is the expected output from running the `eval-final` command for Tables 1, and 2.

```
No solution file for: UConstRange SaddSat
No solution file for: UConstRange MulNswNuw
No solution file for: UConstRange MulNuw
No solution file for: UConstRange SshlSat
No solution file for: KnownBits SmulSat
No solution file for: SConstRange MulNsw
No solution file for: SConstRange MulNswNuw
No solution file for: KnownBits UmulSat
No solution file for: KnownBits SsubSat
No solution file for: SConstRange SaddSat
No solution file for: KnownBits MulNsw
No solution file for: SConstRange Mods
No solution file for: UConstRange MulNsw
No solution file for: SConstRange Mul
No solution file for: UConstRange SsubSat
No solution file for: UConstRange UmulSat
No solution file for: SConstRange MulNuw
No solution file for: UConstRange SmulSat
No solution file for: KnownBits SaddSat
No solution file for: SConstRange SmulSat
No solution file for: SConstRange UmulSat
No solution file for: SConstRange SsubSat
No solution file for: UConstRange Sub
No solution file for: KnownBits MulNswNuw
No solution file for: KnownBits MulNuw
#################################   KnownBits Abds   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 3903.5  | 1975.75 | 0       | 0         ||   8+  | 34.32% | 63.52% | 100.0% | 100.0%
64* | 25000   | 1491.09 | 1249.94 | 0       | 0         ||   
#################################   KnownBits Abdu   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 3923.38 | 1868.25 | 0       | 0         ||   8+  | 34.02% | 65.79% | 100.0% | 100.0%
64* | 25000   | 1491.58 | 1235.73 | 0       | 0         ||   
#################################   KnownBits Add   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 4757.5  | 1816.62 | 0       | 0         ||   8+  | 29.40% | 62.44% | 100.0% | 100.0%
64* | 25000   | 3520.5  | 2214.81 | 0       | 0         ||   
#################################   KnownBits AddNsw   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 5718.88 | 2391    | 0       | 0         ||   8+  | 23.76% | 52.28% | 100.0% | 100.0%
64* | 24141   | 3523.08 | 1706.16 | 0.09375 | 0.09375   ||   
#################################   KnownBits AddNswNuw   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 8386.5  | 2122.75 | 0       | 0         ||   8+  | 07.34% | 58.06% | 100.0% | 100.0%
64* | 18757   | 2980.88 | 1649.89 | 0.421875 | 0.421875   ||   
#################################   KnownBits AddNuw   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 6971.12 | 871.375 | 0       | 0         ||   8+  | 16.01% | 78.41% | 100.0% | 100.0%
64* | 20670   | 3150.23 | 1382.06 | 0.125   | 0.125     ||   
#################################   KnownBits And   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 15638.4 | 0       | 0       | 0         ||   8+  | 00.02% | 100.0% | 100.0% | 100.0%
64* | 25000   | 15614.6 | 0       | 0       | 0         ||   
#################################   KnownBits Ashr   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 10050   | 5726.75 | 3509.88 | 1471.88   ||   8+  | 28.54% | 42.20% | 87.33% | 87.33%
64* | 0       | 0       | 0       | 0       | 0         ||   
#################################   KnownBits AshrExact   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 12027.1 | 6390.62 | 0       | 0         ||   8+  | 10.79% | 39.07% | 100.0% | 100.0%
64* | 0       | 0       | 0       | 0       | 0         ||   
#################################   KnownBits AvgCeilS   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 4618    | 3972.88 | 0       | 0         ||   8+  | 32.78% | 40.05% | 100.0% | 100.0%
64* | 25000   | 3504.7  | 3422.47 | 0       | 0         ||   
#################################   KnownBits AvgCeilU   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 4602.12 | 3962    | 0       | 0         ||   8+  | 33.02% | 40.22% | 100.0% | 100.0%
64* | 25000   | 3503.59 | 3422.81 | 0       | 0         ||   
#################################   KnownBits AvgFloorS   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 4634.75 | 4029.62 | 0       | 0         ||   8+  | 32.79% | 39.52% | 100.0% | 100.0%
64* | 25000   | 3505.19 | 3428.75 | 0       | 0         ||   
#################################   KnownBits AvgFloorU   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 4619    | 3570.5  | 0       | 0         ||   8+  | 32.84% | 42.93% | 100.0% | 100.0%
64* | 25000   | 3504.08 | 3166.17 | 0       | 0         ||   
#################################   KnownBits Lshr   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 13084.9 | 6882    | 213.625 | 213.625   ||   8+  | 12.19% | 24.27% | 96.40% | 96.40%
64* | 0       | 0       | 0       | 0       | 0         ||   
#################################   KnownBits LshrExact   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 12773.5 | 6543.75 | 0       | 0         ||   8+  | 10.42% | 36.35% | 100.0% | 100.0%
64* | 0       | 0       | 0       | 0       | 0         ||   
#################################   KnownBits Mods   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 4888    | 2713.5  | 2177.62 | 2161.38   ||   8+  | 40.86% | 63.60% | 72.17% | 72.30%
64* | 25000   | 2204.31 | 1932.97 | 1866.19 | 1866.19   ||   
#################################   KnownBits Modu   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 6756.62 | 1475.75 | 3403.12 | 1253.38   ||   8+  | 18.22% | 68.62% | 53.55% | 72.34%
64* | 25000   | 3681.52 | 698.625 | 3259.44 | 669.969   ||   
#################################   KnownBits Mul   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 5043.75 | 1625.38 | 1165.38 | 1042.25   ||   8+  | 28.03% | 66.32% | 71.83% | 74.66%
64* | 25000   | 629.25  | 210.625 | 150.656 | 136.828   ||   
#################################   KnownBits Or   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 15639.6 | 0       | 0       | 0         ||   8+  | 00.05% | 100.0% | 100.0% | 100.0%
64* | 25000   | 15626.2 | 0       | 0       | 0         ||   
#################################   KnownBits Sdiv   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 6464.62 | 2939.38 | 2556.38 | 2057.75   ||   8+  | 64.56% | 73.95% | 84.91% | 84.91%
64* | 25000   | 8239.53 | 2689.66 | 2721.83 | 1860.52   ||   
#################################   KnownBits SdivExact   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 13965.8 | 13961.8 | 8348.5  | 8348.5    ||   8+  | 16.97% | 16.99% | 34.56% | 34.56%
64* | 0       | 0       | 0       | 0       | 0         ||   
#################################   KnownBits Shl   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 13115   | 3119.75 | 213.625 | 213.625   ||   8+  | 12.07% | 49.94% | 96.40% | 96.40%
64* | 0       | 0       | 0       | 0       | 0         ||   
#################################   KnownBits ShlNsw   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 13332.9 | 7234.5  | 0       | 0         ||   8+  | 05.69% | 22.99% | 100.0% | 100.0%
64* | 0       | 0       | 0       | 0       | 0         ||   
#################################   KnownBits ShlNswNuw   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 14138.1 | 7086.5  | 0       | 0         ||   8+  | 04.79% | 19.86% | 100.0% | 100.0%
64* | 0       | 0       | 0       | 0       | 0         ||   
#################################   KnownBits ShlNuw   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 12735   | 5994.38 | 0       | 0         ||   8+  | 10.26% | 37.75% | 100.0% | 100.0%
64* | 0       | 0       | 0       | 0       | 0         ||   
#################################   KnownBits Smax   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 10137.9 | 1900    | 0       | 0         ||   8+  | 06.55% | 74.98% | 100.0% | 100.0%
64* | 25000   | 8781.62 | 1648.39 | 0       | 0         ||   
#################################   KnownBits Smin   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 10170.5 | 2047.88 | 0       | 0         ||   8+  | 06.69% | 73.14% | 100.0% | 100.0%
64* | 25000   | 8780.75 | 1664.19 | 0       | 0         ||   
#################################   KnownBits SshlSat   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 14829.6 | 6230.12 | N/A     | N/A       ||   8+  | 37.18% | 49.48% | N/A    | N/A   
64* | 25000   | 15684   | 6278.56 | N/A     | N/A       ||   
#################################   KnownBits Sub   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 4738.75 | 1920.5  | 0       | 0         ||   8+  | 30.02% | 59.93% | 100.0% | 100.0%
64* | 25000   | 3520.67 | 2284.16 | 0       | 0         ||   
#################################   KnownBits SubNswNuw   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 8400.88 | 2360    | 0       | 0         ||   8+  | 07.56% | 54.36% | 100.0% | 100.0%
64* | 18678   | 2980.78 | 1879.8  | 0.15625 | 0.15625   ||   
#################################   KnownBits SubNuw   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 7004.25 | 795.125 | 0       | 0         ||   8+  | 16.19% | 79.83% | 100.0% | 100.0%
64* | 20715   | 3155.66 | 907.391 | 0.078125 | 0.078125   ||   
#################################   KnownBits UaddSat   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 8807.12 | 971     | 0       | 0         ||   8+  | 18.55% | 79.32% | 100.0% | 100.0%
64* | 25000   | 6330.88 | 983.75  | 0.125   | 0.125     ||   
#################################   KnownBits Udiv   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 17596.9 | 688.5   | 473.375 | 318.875   ||   8+  | 02.38% | 82.64% | 89.20% | 92.08%
64* | 25000   | 23994.1 | 80.9844 | 28.3594 | 21.6094   ||   
#################################   KnownBits UdivExact   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 18678.9 | 5683.12 | 4191.38 | 3973.38   ||   8+  | 02.27% | 28.86% | 33.32% | 40.30%
64* | 0       | 0       | 0       | 0       | 0         ||   
#################################   KnownBits Umax   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 10097.1 | 60.125  | 0       | 0         ||   8+  | 06.70% | 98.31% | 100.0% | 100.0%
64* | 25000   | 8753.88 | 7.79688 | 0       | 0         ||   
#################################   KnownBits Umin   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 10076.8 | 212.75  | 0       | 0         ||   8+  | 06.74% | 94.24% | 100.0% | 100.0%
64* | 25000   | 8755.91 | 28.8438 | 0       | 0         ||   
#################################   KnownBits UshlSat   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 23261.8 | 1283.88 | N/A     | N/A       ||   8+  | 03.22% | 91.78% | N/A    | N/A   
64* | 25000   | 25000   | 0       | N/A     | N/A       ||   
#################################   KnownBits UsubSat   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 8719.12 | 1600.38 | 0       | 0         ||   8+  | 19.00% | 67.34% | 100.0% | 100.0%
64* | 25000   | 6328    | 1662.09 | 0.109375 | 0.109375   ||   
#################################   KnownBits Xor   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 9787.62 | 0       | 0       | 0         ||   8+  | 01.86% | 100.0% | 100.0% | 100.0%
64* | 25000   | 9763.98 | 0       | 0       | 0         ||   
#################################   SConstRange Abds   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 9851    | 7638.75 | N/A     | N/A       ||   8+  | 60.60% | 64.50% | N/A    | N/A   
64* | 25000   | 22368.2 | 22096   | N/A     | N/A       ||   
#################################   SConstRange Abdu   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 8996.62 | 7931.75 | N/A     | N/A       ||   8+  | 60.02% | 60.48% | N/A    | N/A   
64* | 25000   | 22244.5 | 22119.8 | N/A     | N/A       ||   
#################################   SConstRange Add   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 9287.12 | 7520.25 | N/A     | N/A       ||   8+  | 60.24% | 66.73% | N/A    | N/A   
64* | 25000   | 22305.9 | 22093.4 | N/A     | N/A       ||   
#################################   SConstRange AddNsw   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 20760.6 | 0       | 0       | 0         ||   8+  | 06.62% | 100.0% | 100.0% | 100.0%
64* | 24458   | 23934.6 | 21640.5 | 21640.5 | 21640.5   ||   
#################################   SConstRange AddNswNuw   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 22629.4 | 0       | N/A     | N/A       ||   8+  | 00.27% | 100.0% | N/A    | N/A   
64* | 22648   | 22399.2 | 20134.4 | N/A     | N/A       ||   
#################################   SConstRange AddNuw   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 15241.1 | 1887.38 | N/A     | N/A       ||   8+  | 36.14% | 88.84% | N/A    | N/A   
64* | 22914   | 21439.7 | 20073.2 | N/A     | N/A       ||   
#################################   SConstRange And   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 22530.4 | 1059.5  | N/A     | N/A       ||   8+  | 00.16% | 91.54% | N/A    | N/A   
64* | 25000   | 24703.3 | 21446.4 | N/A     | N/A       ||   
#################################   SConstRange Ashr   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 24009   | 1195.75 | 216.75  | 156       ||   8+  | 00.00% | 92.83% | 97.90% | 98.26%
64* | 0       | 0       | 0       | 0       | 0         ||   
#################################   SConstRange AshrExact   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 23997.8 | 2369.88 | N/A     | N/A       ||   8+  | 00.00% | 79.39% | N/A    | N/A   
64* | 0       | 0       | 0       | N/A     | N/A       ||   
#################################   SConstRange AvgCeilS   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 24434.5 | 4372.12 | N/A     | N/A       ||   8+  | 00.00% | 67.52% | N/A    | N/A   
64* | 25000   | 24936   | 22641.4 | N/A     | N/A       ||   
#################################   SConstRange AvgCeilU   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 7537.12 | 6727.38 | N/A     | N/A       ||   8+  | 66.46% | 66.47% | N/A    | N/A   
64* | 25000   | 21598.1 | 21502.1 | N/A     | N/A       ||   
#################################   SConstRange AvgFloorS   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 24434.6 | 2616.38 | N/A     | N/A       ||   8+  | 00.00% | 76.82% | N/A    | N/A   
64* | 25000   | 24936   | 22422.3 | N/A     | N/A       ||   
#################################   SConstRange AvgFloorU   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 7537.62 | 6307.25 | N/A     | N/A       ||   8+  | 66.46% | 66.51% | N/A    | N/A   
64* | 25000   | 21598.1 | 21445.8 | N/A     | N/A       ||   
#################################   SConstRange Lshr   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 20865.8 | 7055.5  | N/A     | N/A       ||   8+  | 00.38% | 52.65% | N/A    | N/A   
64* | 0       | 0       | 0       | N/A     | N/A       ||   
#################################   SConstRange LshrExact   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 20832.4 | 20156.1 | N/A     | N/A       ||   8+  | 00.39% | 02.53% | N/A    | N/A   
64* | 0       | 0       | 0       | N/A     | N/A       ||   
#################################   SConstRange Modu   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 23302   | 3104.62 | N/A     | N/A       ||   8+  | 00.01% | 69.83% | N/A    | N/A   
64* | 25000   | 24797.4 | 21698   | N/A     | N/A       ||   
#################################   SConstRange Or   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 22571.6 | 918.375 | N/A     | N/A       ||   8+  | 00.25% | 91.46% | N/A    | N/A   
64* | 25000   | 24701.4 | 21432.1 | N/A     | N/A       ||   
#################################   SConstRange Sdiv   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 24977   | 22314.5 | 8006.5  | 0       | 0         ||   8+  | 00.30% | 50.64% | 100.0% | 100.0%
64* | 25000   | 25000   | 18870.5 | 12419.5 | 12419.5   ||   
#################################   SConstRange SdivExact   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 22188.6 | 22186.9 | N/A     | N/A       ||   8+  | 00.40% | 00.41% | N/A    | N/A   
64* | 0       | 0       | 0       | N/A     | N/A       ||   
#################################   SConstRange Shl   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 5661    | 5477.75 | N/A     | N/A       ||   8+  | 00.65% | 01.41% | N/A    | N/A   
64* | 0       | 0       | 0       | N/A     | N/A       ||   
#################################   SConstRange ShlNsw   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 15716.1 | 13392.8 | 265.625 | 123.75    ||   8+  | 00.32% | 01.54% | 98.68% | 99.37%
64* | 0       | 0       | 0       | 0       | 0         ||   
#################################   SConstRange ShlNswNuw   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 22340.6 | 5108.88 | N/A     | N/A       ||   8+  | 00.00% | 26.23% | N/A    | N/A   
64* | 0       | 0       | 0       | N/A     | N/A       ||   
#################################   SConstRange ShlNuw   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 11836.9 | 5541.25 | N/A     | N/A       ||   8+  | 00.52% | 25.73% | N/A    | N/A   
64* | 0       | 0       | 0       | N/A     | N/A       ||   
#################################   SConstRange Smax   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 24137.6 | 0       | 0       | 0         ||   8+  | 00.00% | 100.0% | 100.0% | 100.0%
64* | 25000   | 24897.4 | 20088.4 | 20088.4 | 20088.4   ||   
#################################   SConstRange Smin   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 24153.9 | 0       | 0       | 0         ||   8+  | 00.00% | 100.0% | 100.0% | 100.0%
64* | 25000   | 24895.8 | 20079   | 20079   | 20079     ||   
#################################   SConstRange SshlSat   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 12597.6 | 3696.75 | 0       | 0         ||   8+  | 49.61% | 80.70% | 100.0% | 100.0%
64* | 25000   | 12545   | 10961.9 | 6073.84 | 6073.84   ||   
#################################   SConstRange Sub   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 9307.75 | 8110.88 | N/A     | N/A       ||   8+  | 60.24% | 63.69% | N/A    | N/A   
64* | 25000   | 22286.7 | 22152.1 | N/A     | N/A       ||   
#################################   SConstRange SubNsw   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 20778.6 | 0       | 0       | 0         ||   8+  | 06.58% | 100.0% | 100.0% | 100.0%
64* | 24450   | 23922.5 | 21627.6 | 21627.6 | 21627.6   ||   
#################################   SConstRange SubNswNuw   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 22633.2 | 0       | N/A     | N/A       ||   8+  | 00.14% | 100.0% | N/A    | N/A   
64* | 22644   | 22391.1 | 20125.3 | N/A     | N/A       ||   
#################################   SConstRange SubNuw   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 15232   | 1596.38 | N/A     | N/A       ||   8+  | 36.11% | 90.84% | N/A    | N/A   
64* | 22924   | 21413.3 | 20063.8 | N/A     | N/A       ||   
#################################   SConstRange UaddSat   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 16048.2 | 4053.75 | N/A     | N/A       ||   8+  | 33.14% | 77.83% | N/A    | N/A   
64* | 25000   | 23519.8 | 20785.7 | N/A     | N/A       ||   
#################################   SConstRange Udiv   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 22784.9 | 4562.88 | N/A     | N/A       ||   8+  | 00.24% | 73.70% | N/A    | N/A   
64* | 25000   | 25000   | 17129.2 | N/A     | N/A       ||   
#################################   SConstRange UdivExact   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 22547.9 | 12803.1 | N/A     | N/A       ||   8+  | 00.24% | 27.22% | N/A    | N/A   
64* | 0       | 0       | 0       | N/A     | N/A       ||   
#################################   SConstRange Umax   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 23090.9 | 0       | N/A     | N/A       ||   8+  | 00.00% | 100.0% | N/A    | N/A   
64* | 25000   | 24762.9 | 20189.4 | N/A     | N/A       ||   
#################################   SConstRange Umin   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 23070.9 | 0       | N/A     | N/A       ||   8+  | 00.00% | 100.0% | N/A    | N/A   
64* | 25000   | 24765.9 | 20176.5 | N/A     | N/A       ||   
#################################   SConstRange UshlSat   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 18158.9 | 10796.2 | N/A     | N/A       ||   8+  | 00.25% | 25.56% | N/A    | N/A   
64* | 25000   | 25000   | 18761   | N/A     | N/A       ||   
#################################   SConstRange UsubSat   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 16036.1 | 5010.12 | N/A     | N/A       ||   8+  | 33.13% | 72.44% | N/A    | N/A   
64* | 25000   | 23494   | 20365.7 | N/A     | N/A       ||   
#################################   SConstRange Xor   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 12387.9 | 8033.75 | N/A     | N/A       ||   8+  | 41.96% | 56.36% | N/A    | N/A   
64* | 25000   | 22993.6 | 22205.5 | N/A     | N/A       ||   
#################################   UConstRange Abds   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 14843.1 | 7131.5  | N/A     | N/A       ||   8+  | 25.44% | 59.34% | N/A    | N/A   
64* | 25000   | 23837.7 | 22957.4 | N/A     | N/A       ||   
#################################   UConstRange Abdu   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 22845.9 | 1371.88 | N/A     | N/A       ||   8+  | 00.00% | 89.04% | N/A    | N/A   
64* | 25000   | 24743.2 | 22297.2 | N/A     | N/A       ||   
#################################   UConstRange Add   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 12557   | 7909.88 | 4738.25 | 0       | 0         ||   8+  | 33.86% | 40.91% | 100.0% | 100.0%
64* | 12503   | 11714.8 | 11343.7 | 10792.5 | 10792.5   ||   
#################################   UConstRange AddNsw   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 7614.25 | 5120.75 | N/A     | N/A       ||   8+  | 68.22% | 75.84% | N/A    | N/A   
64* | 24448   | 21382.6 | 21108.4 | N/A     | N/A       ||   
#################################   UConstRange AddNswNuw   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 23619.4 | 2020.25 | 2173.5  | 1084.62   ||   8+  | 00.01% | 86.40% | 84.67% | 92.40%
64* | 20594   | 20460.8 | 18443.5 | 18423.1 | 18339.1   ||   
#################################   UConstRange AddNuw   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 23593.6 | 289.25  | 0       | 0         ||   8+  | 00.01% | 98.75% | 100.0% | 100.0%
64* | 20853   | 20715.3 | 18516.1 | 18482.6 | 18482.6   ||   
#################################   UConstRange And   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 22951   | 1299.62 | 2017.62 | 846.5     ||   8+  | 00.00% | 87.99% | 84.57% | 90.36%
64* | 25000   | 24748.6 | 21419.4 | 21544.8 | 21336.2   ||   
#################################   UConstRange Ashr   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 12607.2 | 2896    | N/A     | N/A       ||   8+  | 49.26% | 70.68% | N/A    | N/A   
64* | 0       | 0       | 0       | N/A     | N/A       ||   
#################################   UConstRange AshrExact   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 16403.4 | 10896.2 | N/A     | N/A       ||   8+  | 00.42% | 32.63% | N/A    | N/A   
64* | 0       | 0       | 0       | N/A     | N/A       ||   
#################################   UConstRange AvgCeilS   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 7465.38 | 6746.62 | N/A     | N/A       ||   8+  | 66.75% | 66.75% | N/A    | N/A   
64* | 25000   | 21609.4 | 21527   | N/A     | N/A       ||   
#################################   UConstRange AvgCeilU   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 24434.9 | 24434.9 | N/A     | N/A       ||   8+  | 00.00% | 00.00% | N/A    | N/A   
64* | 25000   | 24934.9 | 24934.9 | N/A     | N/A       ||   
#################################   UConstRange AvgFloorS   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 7463    | 6743.38 | N/A     | N/A       ||   8+  | 66.78% | 66.78% | N/A    | N/A   
64* | 25000   | 21609.4 | 21524.3 | N/A     | N/A       ||   
#################################   UConstRange AvgFloorU   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 24436.1 | 2249.62 | N/A     | N/A       ||   8+  | 00.00% | 80.05% | N/A    | N/A   
64* | 25000   | 24934.9 | 22346.2 | N/A     | N/A       ||   
#################################   UConstRange Lshr   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 24419.1 | 2475.38 | 0       | 0         ||   8+  | 00.12% | 57.10% | 100.0% | 100.0%
64* | 0       | 0       | 0       | 0       | 0         ||   
#################################   UConstRange LshrExact   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 24321.8 | 2910.5  | N/A     | N/A       ||   8+  | 00.00% | 54.61% | N/A    | N/A   
64* | 0       | 0       | 0       | N/A     | N/A       ||   
#################################   UConstRange Mods   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 7541    | 2412.5  | N/A     | N/A       ||   8+  | 69.13% | 86.71% | N/A    | N/A   
64* | 25000   | 22734.7 | 21850.8 | N/A     | N/A       ||   
#################################   UConstRange Modu   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 22753.6 | 843.875 | 1628.75 | 640       ||   8+  | 00.00% | 86.94% | 90.08% | 93.28%
64* | 25000   | 24725.8 | 21148.7 | 21299.3 | 21148.7   ||   
#################################   UConstRange Mul   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 24984   | 545.625 | 527.75  | 529.5   | 513.75    ||   8+  | 90.34% | 90.55% | 90.41% | 90.61%
64* | 25000   | 20633.6 | 20633.6 | 20633.6 | 20633.6   ||   
#################################   UConstRange Or   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 22991.8 | 1526.75 | 2000.5  | 994.375   ||   8+  | 00.01% | 87.84% | 84.64% | 90.04%
64* | 25000   | 24750   | 21509   | 21546.3 | 21409.6   ||   
#################################   UConstRange Sdiv   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 6462.12 | 3380.5  | N/A     | N/A       ||   8+  | 70.63% | 73.52% | N/A    | N/A   
64* | 25000   | 6394.48 | 2137.66 | N/A     | N/A       ||   
#################################   UConstRange SdivExact   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 10930.6 | 10892   | N/A     | N/A       ||   8+  | 00.58% | 01.61% | N/A    | N/A   
64* | 0       | 0       | 0       | N/A     | N/A       ||   
#################################   UConstRange Shl   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 13696.6 | 11883.2 | 13659.8 | 11849.8   ||   8+  | 00.12% | 29.71% | 00.31% | 29.86%
64* | 0       | 0       | 0       | 0       | 0         ||   
#################################   UConstRange ShlNsw   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 24464.4 | 4410.75 | N/A     | N/A       ||   8+  | 00.00% | 66.65% | N/A    | N/A   
64* | 0       | 0       | 0       | N/A     | N/A       ||   
#################################   UConstRange ShlNswNuw   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 24444   | 2548.88 | 11350.6 | 729.25    ||   8+  | 00.00% | 80.73% | 48.34% | 93.89%
64* | 0       | 0       | 0       | 0       | 0         ||   
#################################   UConstRange ShlNuw   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 21244.9 | 985.375 | 0       | 0         ||   8+  | 00.00% | 95.64% | 99.72% | 99.72%
64* | 0       | 0       | 0       | 0       | 0         ||   
#################################   UConstRange Smax   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 23071.9 | 0       | N/A     | N/A       ||   8+  | 00.01% | 100.0% | N/A    | N/A   
64* | 25000   | 24759   | 20180.5 | N/A     | N/A       ||   
#################################   UConstRange Smin   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 23091.2 | 0       | N/A     | N/A       ||   8+  | 00.00% | 100.0% | N/A    | N/A   
64* | 25000   | 24761.3 | 20173.9 | N/A     | N/A       ||   
#################################   UConstRange SubNswNuw   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 23617.2 | 4633    | 2138    | 2138      ||   8+  | 00.00% | 65.89% | 84.90% | 84.90%
64* | 20536   | 20402.2 | 18609.4 | 18368.5 | 18368.5   ||   
#################################   UConstRange SubNuw   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 23586.5 | 861.25  | 0       | 0         ||   8+  | 00.00% | 95.14% | 100.0% | 100.0%
64* | 20689   | 20548.8 | 18433.8 | 18339.8 | 18339.8   ||   
#################################   UConstRange UaddSat   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 23832.5 | 0       | 0       | 0         ||   8+  | 00.01% | 100.0% | 100.0% | 100.0%
64* | 25000   | 24859.9 | 18409.1 | 18409.1 | 18409.1   ||   
#################################   UConstRange Udiv   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 24915   | 5053.25 | 0       | 0         ||   8+  | 00.00% | 38.45% | 100.0% | 100.0%
64* | 25000   | 25000   | 768.562 | 87.7188 | 87.7188   ||   
#################################   UConstRange UdivExact   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 24897.2 | 5343.75 | N/A     | N/A       ||   8+  | 00.00% | 27.19% | N/A    | N/A   
64* | 0       | 0       | 0       | N/A     | N/A       ||   
#################################   UConstRange Umax   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 24163.9 | 0       | 0       | 0         ||   8+  | 00.00% | 100.0% | 100.0% | 100.0%
64* | 25000   | 24894.5 | 20077.5 | 20077.5 | 20077.5   ||   
#################################   UConstRange Umin   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 24133.8 | 0       | 0       | 0         ||   8+  | 00.00% | 100.0% | 100.0% | 100.0%
64* | 25000   | 24893.6 | 20082.8 | 20082.8 | 20082.8   ||   
#################################   UConstRange UshlSat   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 24906   | 819.25  | 0       | 0         ||   8+  | 00.06% | 96.47% | 100.0% | 100.0%
64* | 25000   | 25000   | 0       | 0       | 0         ||   
#################################   UConstRange UsubSat   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 23822.8 | 542.75  | 0       | 0         ||   8+  | 00.00% | 96.61% | 100.0% | 100.0%
64* | 25000   | 24858.5 | 18552.5 | 18471.5 | 18471.5   ||   
#################################   UConstRange Xor   ############################
           ######  Dists  ######                        ||           ######  Exacts  ######         
bw  | Cases   | Top     | Synth   | LLVM    | Meet      ||   bw | Top    | Synth  | LLVM   | Meet   
----|---------|---------|---------|---------|--------   ||   ---|--------|--------|--------|--------
8+  | 25000   | 10866.9 | 4316.88 | 5821.5  | 3639      ||   8+  | 50.28% | 71.93% | 67.14% | 74.72%
64* | 25000   | 22583   | 21509.8 | 21642.1 | 21367.1   ||
```

### Table 3 Evaluation Results

This is the expected output from running the `eval-final` command for Table 3.

```
No solution file for: KnownBits SmulSat
No solution file for: KnownBits UmulSat
No solution file for: KnownBits SsubSat
No solution file for: KnownBits MulNsw
No solution file for: KnownBits SaddSat
No solution file for: KnownBits MulNswNuw
No solution file for: KnownBits MulNuw
#################################   KnownBits Abds   ############################
           ######  Dists  ######               ||        ######  Exacts  #####     
bw  | Cases   | Top     | Synth   | Reduced    ||   bw  | Top    | Synth  | Reduced
----|---------|---------|---------|---------   ||   ----|--------|--------|--------
8+  | 25000   | 10041.1 | 7062.75 | 5795.88    ||   8+  | 07.55% | 18.28% | 28.95%
64* | 25000   | 3082.58 | 2728.77 | 2597.62    ||   

#################################   KnownBits Abdu   ############################
           ######  Dists  ######               ||        ######  Exacts  #####     
bw  | Cases   | Top     | Synth   | Reduced    ||   bw  | Top    | Synth  | Reduced
----|---------|---------|---------|---------   ||   ----|--------|--------|--------
8+  | 25000   | 10060.4 | 6740.75 | 1396.5     ||   8+  | 07.26% | 20.30% | 70.95%
64* | 25000   | 3074.12 | 2692.5  | 2290.05    ||   

#################################   KnownBits AddNsw   ############################
           ######  Dists  ######               ||        ######  Exacts  #####     
bw  | Cases   | Top     | Synth   | Reduced    ||   bw  | Top    | Synth  | Reduced
----|---------|---------|---------|---------   ||   ----|--------|--------|--------
8+  | 25000   | 13058.5 | 4782.38 | 800.875    ||   8+  | 06.71% | 18.83% | 81.54%
64* | 25000   | 7166.12 | 2934.59 | 2234.05    ||   

#################################   KnownBits AddNswNuw   ############################
           ######  Dists  ######               ||        ######  Exacts  #####     
bw  | Cases   | Top     | Synth   | Reduced    ||   bw  | Top    | Synth  | Reduced
----|---------|---------|---------|---------   ||   ----|--------|--------|--------
8+  | 25000   | 18833.5 | 2158.75 | 463.75     ||   8+  | 00.25% | 44.26% | 88.53%
64* | 25000   | 13981.5 | 3043.83 | 1526.09    ||   

#################################   KnownBits AddNuw   ############################
           ######  Dists  ######               ||        ######  Exacts  #####     
bw  | Cases   | Top     | Synth   | Reduced    ||   bw  | Top    | Synth  | Reduced
----|---------|---------|---------|---------   ||   ----|--------|--------|--------
8+  | 25000   | 16904.1 | 1563.88 | 294.625    ||   8+  | 03.31% | 31.55% | 92.04%
64* | 25000   | 12263.3 | 2371.89 | 1463.69    ||   

#################################   KnownBits AvgCeilS   ############################
           ######  Dists  ######               ||        ######  Exacts  #####     
bw  | Cases   | Top     | Synth   | Reduced    ||   bw  | Top    | Synth  | Reduced
----|---------|---------|---------|---------   ||   ----|--------|--------|--------
8+  | 25000   | 10780   | 9114.88 | 6922.38    ||   8+  | 09.59% | 18.15% | 28.88%
64* | 25000   | 4162.5  | 3965.42 | 3793.38    ||   

#################################   KnownBits AvgFloorS   ############################
           ######  Dists  ######               ||        ######  Exacts  #####     
bw  | Cases   | Top     | Synth   | Reduced    ||   bw  | Top    | Synth  | Reduced
----|---------|---------|---------|---------   ||   ----|--------|--------|--------
8+  | 25000   | 10766.1 | 9303.12 | 3599.62    ||   8+  | 09.68% | 17.51% | 46.58%
64* | 25000   | 4161.78 | 3982.41 | 3511.27    ||   

#################################   KnownBits AvgFloorU   ############################
           ######  Dists  ######               ||        ######  Exacts  #####     
bw  | Cases   | Top     | Synth   | Reduced    ||   bw  | Top    | Synth  | Reduced
----|---------|---------|---------|---------   ||   ----|--------|--------|--------
8+  | 25000   | 10770   | 8315.88 | 3144.88    ||   8+  | 09.67% | 19.20% | 51.33%
64* | 25000   | 4163.97 | 3689.52 | 3325.33    ||   

#################################   KnownBits Mods   ############################
           ######  Dists  ######               ||        ######  Exacts  #####     
bw  | Cases   | Top     | Synth   | Reduced    ||   bw  | Top    | Synth  | Reduced
----|---------|---------|---------|---------   ||   ----|--------|--------|--------
8+  | 25000   | 12147.4 | 8928.75 | 8467.75    ||   8+  | 12.87% | 21.69% | 26.21%
64* | 25000   | 4716.58 | 4348.7  | 4315.88    ||   

#################################   KnownBits Modu   ############################
           ######  Dists  ######               ||        ######  Exacts  #####     
bw  | Cases   | Top     | Synth   | Reduced    ||   bw  | Top    | Synth  | Reduced
----|---------|---------|---------|---------   ||   ----|--------|--------|--------
8+  | 25000   | 13369.9 | 2904.62 | 2408.75    ||   8+  | 02.16% | 61.49% | 66.11%
64* | 25000   | 6588.5  | 983.5   | 918.453    ||   

#################################   KnownBits Sdiv   ############################
           ######  Dists  ######               ||        ######  Exacts  #####     
bw  | Cases   | Top     | Synth   | Reduced    ||   bw  | Top    | Synth  | Reduced
----|---------|---------|---------|---------   ||   ----|--------|--------|--------
8+  | 25000   | 18803   | 8655.75 | 7405.75    ||   8+  | 17.45% | 26.92% | 44.30%
64* | 25000   | 18466.2 | 6182.33 | 5530.73    ||   

#################################   KnownBits Smax   ############################
           ######  Dists  ######               ||        ######  Exacts  #####     
bw  | Cases   | Top     | Synth   | Reduced    ||   bw  | Top    | Synth  | Reduced
----|---------|---------|---------|---------   ||   ----|--------|--------|--------
8+  | 25000   | 17498.9 | 3840    | 844        ||   8+  | 00.48% | 59.07% | 83.20%
64* | 25000   | 12429.5 | 2352.66 | 2100.5     ||   

#################################   KnownBits Smin   ############################
           ######  Dists  ######               ||        ######  Exacts  #####     
bw  | Cases   | Top     | Synth   | Reduced    ||   bw  | Top    | Synth  | Reduced
----|---------|---------|---------|---------   ||   ----|--------|--------|--------
8+  | 25000   | 17528.6 | 4024.75 | 836.5      ||   8+  | 00.44% | 58.71% | 83.46%
64* | 25000   | 12437.5 | 2384.39 | 2104.84    ||   

#################################   KnownBits SshlSat   ############################
           ######  Dists  ######               ||        ######  Exacts  #####     
bw  | Cases   | Top     | Synth   | Reduced    ||   bw  | Top    | Synth  | Reduced
----|---------|---------|---------|---------   ||   ----|--------|--------|--------
8+  | 25000   | 24031.8 | 8329.5  | 7002.75    ||   8+  | 03.75% | 33.93% | 43.89%
64* | 25000   | 23855   | 8134.64 | 7970.17    ||   

#################################   KnownBits SubNswNuw   ############################
           ######  Dists  ######               ||        ######  Exacts  #####     
bw  | Cases   | Top     | Synth   | Reduced    ||   bw  | Top    | Synth  | Reduced
----|---------|---------|---------|---------   ||   ----|--------|--------|--------
8+  | 25000   | 18713.5 | 2192.38 | 567        ||   8+  | 00.30% | 39.64% | 77.77%
64* | 25000   | 13889.8 | 3210.55 | 1809.72    ||   

#################################   KnownBits SubNuw   ############################
           ######  Dists  ######               ||        ######  Exacts  #####     
bw  | Cases   | Top     | Synth   | Reduced    ||   bw  | Top    | Synth  | Reduced
----|---------|---------|---------|---------   ||   ----|--------|--------|--------
8+  | 25000   | 16816.8 | 1367    | 342.25     ||   8+  | 03.31% | 35.18% | 91.01%
64* | 25000   | 12165.2 | 1970.22 | 1208.84    ||   

#################################   KnownBits UaddSat   ############################
           ######  Dists  ######               ||        ######  Exacts  #####     
bw  | Cases   | Top     | Synth   | Reduced    ||   bw  | Top    | Synth  | Reduced
----|---------|---------|---------|---------   ||   ----|--------|--------|--------
8+  | 25000   | 16524.6 | 2838.75 | 744        ||   8+  | 03.62% | 60.14% | 83.04%
64* | 25000   | 11546.1 | 2264.22 | 1199.53    ||   

#################################   KnownBits Udiv   ############################
           ######  Dists  ######               ||        ######  Exacts  #####     
bw  | Cases   | Top     | Synth   | Reduced    ||   bw  | Top    | Synth  | Reduced
----|---------|---------|---------|---------   ||   ----|--------|--------|--------
8+  | 25000   | 22690   | 2072.5  | 1489.12    ||   8+  | 00.05% | 67.96% | 74.80%
64* | 25000   | 24607.3 | 336.25  | 165.828    ||   

#################################   KnownBits UdivExact   ############################
           ######  Dists  ######               ||        ######  Exacts  #####     
bw  | Cases   | Top     | Synth   | Reduced    ||   bw  | Top    | Synth  | Reduced
----|---------|---------|---------|---------   ||   ----|--------|--------|--------
8+  | 25000   | 24627.9 | 3868.75 | 3011       ||   8+  | 00.02% | 03.64% | 05.91%
64* | 25000   | 25000   | 691.156 | 487.641    ||   

#################################   KnownBits Umax   ############################
           ######  Dists  ######               ||        ######  Exacts  #####     
bw  | Cases   | Top     | Synth   | Reduced    ||   bw  | Top    | Synth  | Reduced
----|---------|---------|---------|---------   ||   ----|--------|--------|--------
8+  | 25000   | 17519.4 | 252.5   | 6.625      ||   8+  | 00.49% | 95.34% | 99.80%
64* | 25000   | 12419.3 | 39.7188 | 4.54688    ||   

#################################   KnownBits Umin   ############################
           ######  Dists  ######               ||        ######  Exacts  #####     
bw  | Cases   | Top     | Synth   | Reduced    ||   bw  | Top    | Synth  | Reduced
----|---------|---------|---------|---------   ||   ----|--------|--------|--------
8+  | 25000   | 17526.6 | 382.75  | 18         ||   8+  | 00.49% | 92.72% | 99.46%
64* | 25000   | 12426.8 | 61.8594 | 8.875      ||   

#################################   KnownBits UsubSat   ############################
           ######  Dists  ######               ||        ######  Exacts  #####     
bw  | Cases   | Top     | Synth   | Reduced    ||   bw  | Top    | Synth  | Reduced
----|---------|---------|---------|---------   ||   ----|--------|--------|--------
8+  | 25000   | 16426.4 | 3669.5  | 1950.88    ||   8+  | 03.60% | 55.21% | 72.35%
64* | 25000   | 11396   | 2767.16 | 1732.62    || 
```
