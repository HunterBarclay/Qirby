using System;
using System.Collections.Generic;
using System.Linq;

using Qirby.Simulation;
using Qirby.Mathematics;

/// <summary>
/// Please note that I'm sidelining basically every thought of optimization until I've completed my self assigned
/// goal of creating a working quantum computing simulator and have successfully found the numbers than can be added
/// to create the sum 13.
/// </summary>
namespace Qirby {
    public class Program {
        static void Main(string[] args) {
            var c = UngodlyAdditionTest(1, 2);
            Console.WriteLine(c);
        }

        static void NewschoolTest() {
            var state = new State(3);
            state.ApplyOperation(Matrix.H, 0);
            state.ApplyOperation(state.MakeShiftOperator(0, 1));
            state.StateVector.Print();

            // New school way of doing it. TODO: Needs to be tested more. Probably need to start
            // comparisons to other simulators cuz hand written matrix math is getting fucking old
            var state2 = new State(3);
            var op = state2.CompileInstructionSet(
                Matrix.H, 0,
                state2.MakeShiftOperator(0, 1)
            );
            state2.ApplyOperation(op);
            state2.StateVector.Print();
        }

        static int UngodlyAdditionTest(int A, int B) {

            if (A > 0x7 || B > 0x7)
                throw new Exception("3-bits only");

            var state = new State(9);
            int[] a = GetBits(A);
            int[] b = GetBits(B);

            const int A_OFFSET = 0;
            const int B_OFFSET = 4;
            const int O_OFFSET = 8;

            // Load parameters
            for (int i = 0; i < 3; i++) {
                if (a[i] == 1)
                    state.ApplyOperation(Matrix.X, i);
            }
            for (int i = 3; i < 6; i++) {
                if (b[i - 3] == 1)
                    state.ApplyOperation(Matrix.X, i);
            }

            // Make 4-bit adder operation

            // First Bits
            var operation = state.CompileInstructionSet(
                // Sum O_0
                Matrix.CX, A_OFFSET, O_OFFSET,
                Matrix.CX, B_OFFSET, O_OFFSET,
                // Carry O_1
                Matrix.X, A_OFFSET,
                Matrix.X, B_OFFSET,
                Matrix.X, O_OFFSET + 1,
                Matrix.CCX, A_OFFSET, B_OFFSET, O_OFFSET + 1
            );

            Console.WriteLine("First Op Compiled");

            for (int i = 1; i < 3; i++) {
                if (i < 2) { // Next Carry
                    operation = state.CompileInstructionSet(
                        Matrix.X, A_OFFSET + i,
                        Matrix.X, B_OFFSET + i,
                        Matrix.X, O_OFFSET + i,
                        Matrix.CCX, A_OFFSET + i, O_OFFSET + i, O_OFFSET + i + 1,
                        Matrix.CCX, B_OFFSET + i, O_OFFSET + i, O_OFFSET + i + 1,
                        Matrix.CCX, A_OFFSET + i, B_OFFSET + i, O_OFFSET + i + 1,
                        Matrix.X, A_OFFSET + i,
                        Matrix.X, B_OFFSET + i,
                        Matrix.X, O_OFFSET + i
                    ) * operation;
                }

                // Finish Sum
                operation = state.CompileInstructionSet(
                    Matrix.CX, A_OFFSET + i, O_OFFSET + i,
                    Matrix.CX, B_OFFSET + i, O_OFFSET + i
                ) * operation;

                Console.WriteLine($"[{i}] Op Compiled");
            }

            // Execute Operation

            Console.WriteLine("Running Operation");
            state.ApplyOperation(operation);
            Console.WriteLine("Operation Complete");
            var probs = state.GetProbabilities();
            var collapsedState = Measure(probs);

            return ParseBits(collapsedState.Skip(6).ToArray());
        }

        static int[] Measure(Dictionary<int[], double> probs) {
            Random r = new Random(DateTime.Now.Millisecond);
            double rand = r.NextDouble();
            double accum = 0;
            foreach (var kvp in probs) {
                accum += kvp.Value;
                if (rand <= accum)
                    return kvp.Key;
            }
            throw new Exception("Uhhh, this shouldn't happen?");
        }

        static int[] GetBits(int a) {
            return new int[] {
                a & 0x0001,
                (a >> 1) & 0x0001,
                (a >> 2) & 0x0001,
                (a >> 3) & 0x0001
            };
        }

        static int ParseBits(int[] a) {
            return a[0]
                + a[1] << 1
                + a[2] << 2
                + a[3] << 3;
        }
    }
}
