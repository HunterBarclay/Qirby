using System;
using System.Collections.Generic;
using System.Linq;

using Qirby.Mathematics;

namespace Qirby.Simulation {
    public struct Instruction {
        public Matrix Operation;
        public int[] Parameters;
    }

    public class State {
        public int NumQubits { get; private set; }

        private Matrix _stateVector;
        internal Matrix StateVector => _stateVector;

        public State(int numQubits) {
            NumQubits = numQubits;

            _stateVector = new Matrix((int)Math.Pow(2, numQubits), 1);
            _stateVector.Set(0, 0, 1); // Set all qubits to be in 0 position
        }

        public Matrix MakeIdentity() {
            Matrix m = Matrix.I;
            for (int i = 1; i < NumQubits; i++) {
                m = Matrix.TensorProduct(m, Matrix.I);
            }
            return m;
        }

        public Matrix MakeShiftOperator(int current, int target) {
            if (current == target)
                return MakeIdentity();

            Matrix m = null;
            
            int dist = Math.Abs(target - current);
            int dir = (target - current) / dist;
            if (dist > 1) {
                m = MakeShiftOperator(current, target - dir);
                current = target - dir;
            }

            int lowest = current < target ? current : target;
            Matrix newM = lowest == 0 ? Matrix.SWAP : Matrix.I;
            for (int i = 1; i < NumQubits - 1; i++) {
                if (i == lowest)
                    newM = Matrix.TensorProduct(newM, Matrix.SWAP);
                else
                    newM = Matrix.TensorProduct(newM, Matrix.I);
            }
            if (m == null)
                m = newM;
            else
                m = newM * m; // Ye?
            return m;
        }

        public Matrix MakeOperation(Matrix op, params int[] qubits) {

            Matrix operation = MakeIdentity();

            // Shift all qubits
            Matrix shift = MakeIdentity();
            var shifts = new int[qubits.Length];
            for (int i = 0; i < qubits.Length; i++) {
                shifts[i] = i - qubits[i];
                var sop = MakeShiftOperator(i - shifts[i], i);
                shift = sop * shift;
                for (int j = i + 1; j < qubits.Length; j++) {
                    if (qubits[j] < qubits[i])
                        qubits[j] = qubits[j] + 1;
                }
            }

            operation = shift * operation;
            if (qubits.Length > 0) {
                Matrix m = op;
                int numQubitsInOp = (int)Math.Log2(op.Columns__);
                for (int i = 1; i <= NumQubits - numQubitsInOp; i++) {
                    m = Matrix.TensorProduct(m, Matrix.I);
                }
                operation = m * operation;
            } else {
                operation = op * operation;
            }

            // Shift all qubits back
            Matrix unshift = MakeIdentity();
            for (int i = shifts.Length - 1; i >= 0; i--) {
                unshift = MakeShiftOperator(i, i - shifts[i]) * unshift;
            }
            operation = unshift * operation;

            return operation;
        }

        public void ApplyOperation(Matrix op, params int[] qubits) {
            _stateVector = MakeOperation(op, qubits) * _stateVector;
        }

        public Matrix CompileInstructionSet(params object[] instructionSet) {
            Matrix compiledInstructions = MakeIdentity();
            Matrix op = MakeIdentity(); // Just to make the error go away
            List<int> parameters = new List<int>();
            for (int i = 0; i < instructionSet.Length; i++) {
                object p = instructionSet[i];
                if (p is Matrix) {
                    if (i != 0) {
                        if (parameters.Any()) // Not sure if I need to break this out into two calls but just to be safe
                            compiledInstructions = MakeOperation(op, parameters.ToArray()) * compiledInstructions;
                        else
                            compiledInstructions = MakeOperation(op) * compiledInstructions;
                        parameters.Clear();
                    }
                    op = p as Matrix;
                } else {
                    parameters.Add((int)p);
                }
            }
            if (parameters.Count() > 0) { // Idk just in case
                compiledInstructions = MakeOperation(op, parameters.ToArray()) * compiledInstructions;
            } else {
                compiledInstructions = MakeOperation(op) * compiledInstructions;
            }
            return compiledInstructions;
        }
    }

    public class Qubit {
        private State _state;
        private int _qubit;

        public Qubit(State state, int qubit) {
            _state = state;
            _qubit = qubit;
        }
    }
}