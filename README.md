# Qirby
*"Anyone not shocked by quantum mechanics has not yet understood it." - Niels Bohr*

Hunter's, duct-taped together, Quantum Computation Simulator. The goal is to be able to build out small QPU programs for the purposes of testing and overall expanding my understanding of Quantum computation.

> [!IMPORTANT]
> **DISCLAIMER**: This project is not intended to be performant or in any way an improvement on existing alternatives, but rather a playground for me to learn.

## Usage

This was the project I decided to remake to learn Zig. That being said, during the middle of the remake, I really started to hate Zig and had other project ideas in mind, so the overall quality from a "Zig perspective" is pretty bad.

### Testing

I've been using the following command to test the code. Via unit tests, The "circuit amp [11]" test is a quantum circuit that amplifies the $\ket{11}$ state in a two qubit system:

```bash 
$ zig build test --summary all
```

### Fun notes
Because this is just a playground for me, this is not optimized at all. There are a number of memory leaks that aren't being addressed and the performance isn't great, that being said for a quantum sim with a useful amount of Qubits would take forever anyways.

## Resources References
Most of my references for logic gates and math is from [this wikipedia article](https://en.wikipedia.org/wiki/Quantum_logic_gate). That, in addition to YouTube video's and [IBM's Quantum Composer](https://quantum.ibm.com/composer/files/cc6d1bce43e28c38529b70c8d3e27c90f6b9f9625c81edb341d02bbafc3d589c).

## First Iteration (2021)
Wrote the whole thing in C#, was insanely slow. A 12 qubit, 4-bit adder circuit took about 7 hours to compile ~20%.

## Second Iteration (2024)
This is a pretty cool project, so I decided to rewrite the project in Zig as way to learn the language. Beginning to regret choosing Zig...