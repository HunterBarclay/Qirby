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

            // Matrix.TensorProduct(Matrix.H, Matrix.I).Print();
        }
    }
}
