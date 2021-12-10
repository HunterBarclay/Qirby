using System;
using System.Collections.Generic;
using System.Linq;
using System.IO;
using Newtonsoft.Json;

using Qirby.Simulation;
using Qirby.Mathematics;
using Qirby.Serialization;

/// <summary>
/// Please note that I'm sidelining basically every thought of optimization until I've completed my self assigned
/// goal of creating a working quantum computing simulator and have successfully found the numbers than can be added
/// to create the sum 13.
/// </summary>
namespace Qirby {
    public class Program {
        static void Main(string[] args) {

            // string json = JsonConvert.SerializeObject((MatrixData)Matrix.I);
            // Console.WriteLine(json);
            // Matrix m = new Matrix(JsonConvert.DeserializeObject<MatrixData>(json));
            // m.Print();

            // var state = new State(3);
            // for (int i = 0; i < 8; i++) {
            //     var rep = state.GetStateRepFromIndex(i);
            //     string a = "";
            //     for (int j = 0; j < rep.Length; j++) {
            //         a += rep[j];
            //     }
            //     Console.WriteLine(a);
            // }

            var start = DateTime.Now;
            var c = UngodlyAdditionTest(3, 2);
            Console.WriteLine(c);
            var time = DateTime.Now - start;
            Console.WriteLine($"Elapsed Minutes: {time.Minutes}");

            // for (int i = 2; i < 5; i++) {
            //     (new State(i)).MakeShiftOperator(0, i - 1).Print();
            //     Console.WriteLine();
            // }

            // NewschoolTest();
            // FuckIThinkItsBroken();
        }

        static void FuckIThinkItsBroken() {
            var state = new State(6);
            state.ApplyOperation(Matrix.X, 0);
            state.ApplyOperation(Matrix.X, 2);
            PrintStateVector(state);
            state.ApplyOperation(Matrix.CCX, 0, 2, 5);
            PrintStateVector(state);
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

            var state = new State(9); // 6 for input, 3 for output, 1 for selection
            int[] a = GetBits(A);
            int[] b = GetBits(B);

            const int A_OFFSET = 0;
            const int B_OFFSET = 3;
            const int O_OFFSET = 6;

            // Load parameters
            for (int i = 0; i < 3; i++) {
                if (a[i] == 1)
                    state.ApplyOperation(Matrix.X, i);
            }
            // for (int i = 3; i < 6; i++) {
            //     if (b[i - 3] == 1)
            //         state.ApplyOperation(Matrix.X, i);
            // }
            state.ApplyOperation(Matrix.TensorProduct(Matrix.H, Matrix.H, Matrix.H), 3, 4, 5);

            PrintStateVector(state);

            Console.WriteLine("Parameters loaded");
            // Make 3-bit adder operation

            // First Bits
            var operation = State.CompileInstructionSet(9,
                // Sum O_0
                Matrix.CX, A_OFFSET, O_OFFSET,
                Matrix.CX, B_OFFSET, O_OFFSET,
                // Carry O_1
                Matrix.CCX, A_OFFSET, B_OFFSET, O_OFFSET + 1
            );

            // {
            //     var newState = state.Copy();
            //     newState.ApplyOperation(operation);
            //     PrintStateVector(newState);
            // }

            Console.WriteLine("First Op Compiled");

            for (int i = 1; i < 3; i++) {
                if (i < 2) { // Next Carry
                    operation = State.CompileInstructionSet(9,
                        Matrix.X, A_OFFSET + i,
                        Matrix.X, B_OFFSET + i,
                        Matrix.X, O_OFFSET + i,
                        Matrix.X, O_OFFSET + i + 1,
                        Matrix.CCX, A_OFFSET + i, O_OFFSET + i, O_OFFSET + i + 1,
                        Matrix.CCX, B_OFFSET + i, O_OFFSET + i, O_OFFSET + i + 1,
                        Matrix.CCX, A_OFFSET + i, B_OFFSET + i, O_OFFSET + i + 1,
                        Matrix.X, A_OFFSET + i,
                        Matrix.X, B_OFFSET + i,
                        Matrix.X, O_OFFSET + i
                    ) * operation;
                }

                // Finish Sum
                operation = State.CompileInstructionSet(9,
                    Matrix.CX, A_OFFSET + i, O_OFFSET + i,
                    Matrix.CX, B_OFFSET + i, O_OFFSET + i
                ) * operation;

                Console.WriteLine($"[{i}] Op Compiled");
            }

            var op_json = JsonConvert.SerializeObject((MatrixData)operation);
            File.WriteAllLines("4_bit_adder.json", new string[] { op_json });

            // Execute Operation

            Console.WriteLine("Running Operation");
            state.ApplyOperation(operation, 0, 1, 2, 3, 4, 5, 6, 7, 8);
            Console.WriteLine("Operation Complete");
            
            PrintStateVector(state);
            
            return 0;
        }

        static void PrintStateVector(State state) {
            Console.WriteLine("\nFirst to Last\n");
            for (int r = 0; r < state.StateVector.Rows__; r++) {
                if (state.StateVector.Get(r, 0).Magnitude > 0) {
                    var stateRep = state.GetStateRepFromIndex(r).Reverse().ToArray();
                    string rep = "";
                    for (int i = 0; i < stateRep.Length; i++) {
                        rep += stateRep[i];
                    }
                    Console.WriteLine($"{rep} => {state.StateVector.Get(r, 0)}");
                }
            }
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
