using System;
using System.Collections.Generic;
using System.Linq;

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
            state.StateVector.Print();
            var shift = state.MakeShiftOperator(0, 1);
            state.ApplyOperation(shift);
            state.StateVector.Print();

            // Matrix.TensorProduct(Matrix.H, Matrix.I).Print();
        }
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

        public Matrix MakeShiftOperator(int current, int target) {
            if (current == target)
                return Matrix.I;

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

        public void ApplyOperation(Matrix op, params int[] qubits) {
            if (!qubits.InSequence())
                throw new Exception("Not supported yet. Underlying code is kinda done but I'm really fucking lazy");
            if (qubits.Length > 0) {
                int lowest = qubits.Min();
                Matrix m = lowest == 0 ? op : Matrix.I;
                int numQubitsInOp = (int)Math.Log2(op.Columns__);
                for (int i = 1; i <= NumQubits - numQubitsInOp; i++) {
                    if (i == lowest)
                        m = Matrix.TensorProduct(m, op);
                    else
                        m = Matrix.TensorProduct(m, Matrix.I);
                }
                _stateVector = m * _stateVector;
            } else {
                _stateVector = op * _stateVector;
            }
        }
    }

    public class Qubit {
        public State State;

        public Qubit() {

        }
    }
}
