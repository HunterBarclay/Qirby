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
        private Matrix _identity = null;
        public Matrix Identity {
            get {
                if (_identity == null)
                    _identity = MakeIdentity(NumQubits);
                return _identity;
            }
        }
        public int NumQubits { get; private set; }

        private Matrix _stateVector;
        internal Matrix StateVector => _stateVector;

        public State(int numQubits) {
            NumQubits = numQubits;

            _stateVector = new Matrix((int)Math.Pow(2, numQubits), 1);
            _stateVector.Set(0, 0, 1); // Set all qubits to be in 0 position
        }

        public static Matrix MakeIdentity(int numQubits) {
            Matrix m = Matrix.I;
            for (int i = 1; i < numQubits; i++) {
                m = Matrix.TensorProduct(m, Matrix.I);
            }
            return m;
        }

        public Matrix MakeShiftOperator(int current, int target) {
            if (current == target)
                return Identity;

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

            Matrix operation = Identity;

            // Shift all qubits
            Matrix shift = Identity;
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
            Matrix unshift = Identity;
            for (int i = shifts.Length - 1; i >= 0; i--) {
                unshift = MakeShiftOperator(i, i - shifts[i]) * unshift;
            }
            operation = unshift * operation;

            return operation;
        }

        public void ApplyOperation(Instruction i) {
            _stateVector = MakeOperation(i.Operation, i.Parameters) * _stateVector;
        }

        public void ApplyOperation(Matrix op, params int[] qubits) {
            _stateVector = MakeOperation(op, qubits) * _stateVector;
        }

        public Matrix CompileInstructionSet(params object[] instructionSet) {
            Matrix op = Identity;
            List<int> param = new List<int>();
            List<Instruction> instructions = new List<Instruction>();
            for (int i = 0; i < instructionSet.Length; i++) {
                object a = instructionSet[i];
                if (a is Matrix) {
                    if (i != 0) {
                        instructions.Add(new Instruction { Operation = op, Parameters = param.Count == 0 ? new int[0] : param.ToArray() });
                        param.Clear();
                    }
                    op = a as Matrix;
                } else {
                    param.Add((int)a);
                }
            }
            if (op != null)
                instructions.Add(new Instruction { Operation = op, Parameters = param.Count == 0 ? new int[0] : param.ToArray() });
            
            return CompileInstructionSet(instructions.ToArray());
        }

        public Matrix CompileInstructionSet(params Instruction[] instructions) {
            Matrix op = Identity;
            for (int i = 0; i < instructions.Length; i++) {
                op = MakeOperation(instructions[i].Operation, instructions[i].Parameters) * op;
            }
            return op;
        }

        public Dictionary<int[], double> GetProbabilities() {
            var dict = new Dictionary<int[], double>();
            for (int i = 0; i < Math.Pow(2, NumQubits); i++) {
                dict.Add(GetStateRepFromIndex(i), (_stateVector.Get(i, 0) * _stateVector.Get(i, 0)).Magnitude);
            }
            return dict;
        }

        public int[] GetStateRepFromIndex(int a) {
            List<int> l = new List<int>();
            for (int i = 0; i < a; i++) {
                l.Add(i == 0 ? 0 : a % i);
            }
            return l.ToArray();
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