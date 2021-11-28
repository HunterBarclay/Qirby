using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Threading;

using Qirby.Serialization;

using Math = System.Math;

namespace Qirby.Mathematics { // Fucking C#
    public class Matrix {
        private int _rows_;
        public int Rows__ { get => _rows_; }
        private int _columns_;
        public int Columns__ { get => _columns_; }

        private Complex[][] _mat; // [column, row]

        public Matrix(int r, int c) {
            _columns_ = c;
            _rows_ = r;
            _mat = new Complex[r][];
            for (int r_ = 0; r_ < r; r_++) {
                _mat[r_] = new Complex[c];
                for (int c_ = 0; c_ < c; c_++) {
                    _mat[r_][c_] = 0;
                }
            }
        }

        public Matrix(MatrixData data) {
            _mat = new Complex[data.Mat.Length][];
            for (int r = 0; r < data.Mat.Length; r++) {
                _mat[r] = new Complex[data.Mat[0].Length];
                for (int c = 0; c < data.Mat[r].Length; c++) {
                    _mat[r][c] = new Complex(data.Mat[r][c].Magnitude, data.Mat[r][c].Phase);
                }
            }
            _rows_ = data.Mat.Length;
            _columns_ = data.Mat[0].Length;
        }

        public Matrix(Complex[][] mat) {
            _mat = mat;
            _rows_ = mat.Length;
            _columns_ = mat[0].Length;
        }

        public Matrix Copy() {
            return new Matrix(_mat);
        }

        public Complex Get(int r, int c)
            => _mat[r][c];

        internal void Set(int r, int c, Complex v)
            => _mat[r][c] = v;

        public List<Complex> GetRow(int r) {
            var res = new List<Complex>();
            for (int c = 0; c < _columns_; c++) {
                res.Add(_mat[r][c]);
            }
            return res;
        }

        public List<Complex> GetColumn(int c) {
            var res = new List<Complex>();
            for (int r = 0; r < _rows_; r++) {
                res.Add(_mat[r][c]);
            }
            return res;
        }

        public static Matrix TensorProduct(Matrix first, Matrix second) {
            var mats = new Matrix[first.Rows__][];
            for (int r = 0; r < first.Rows__; r++) {
                mats[r] = new Matrix[first.Columns__];
                for (int c = 0; c < first.Columns__; c++) {
                    mats[r][c] = first._mat[r][c] * second;
                }
            }
            var tensorMat = new Complex[second.Rows__ * first.Rows__][];
            int cf, cs, rf, rs;
            // EW EW EW EW EW EW EW EW EW EW EW EW EW EW EW EW
            for (int r = 0; r < first.Rows__ * second.Rows__; r++) {
                tensorMat[r] = new Complex[first.Columns__ * second.Columns__];
                for (int c = 0; c < first.Columns__ * second.Columns__; c++) {
                    cf = c / second.Columns__;
                    rf = r/ second.Rows__;
                    cs = c % second.Columns__;
                    rs = r % second.Rows__;
                    tensorMat[r][c] = mats[rf][cf]._mat[rs][cs];
                }
            }
            return new Matrix(tensorMat);
        }

        public static Matrix TensorProduct(params Matrix[] matrices) {
            Matrix tensor = matrices[0];
            for (int i = 1; i < matrices.Length; i++) {
                tensor = TensorProduct(tensor, matrices[i]);
            }
            return tensor;
        }

        public static Matrix operator *(Matrix a, Complex b) {
            var newMat = new Complex[a.Rows__][];
            for (int r = 0; r < a.Rows__; r++) {
                newMat[r] = new Complex[a.Columns__];
                for (int c = 0; c < a.Columns__; c++) {
                    newMat[r][c] = b * a._mat[r][c];
                }
            }
            return new Matrix(newMat);
        }
        public static Matrix operator *(Complex b, Matrix a)
            => a * b;
        public static Matrix operator *(Matrix a, Matrix b) {

            if (a.Columns__ != b.Rows__)
                throw new Exception("Mismatched matricies");

            var tasks = new List<Task>();

            var product = new Complex[a.Rows__][];
            for (int _r = 0; _r < a.Rows__; _r++) {

                int r = _r;

                tasks.Add(Task.Factory.StartNew(() => {

                    product[r] = new Complex[b.Columns__];
                    for (int c = 0; c < b.Columns__; c++) {

                        Complex sum = new Complex(0);
                        for (int i = 0; i < a.Columns__; i++) {
                            sum += a._mat[r][i] * b._mat[i][c];
                        }
                        product[r][c] = sum;
                    }

                }));
            }

            bool done = false;
            while (!done) {
                Thread.Sleep(50);
                int i = tasks.Count;
                foreach (var t in tasks) {
                    if (t.IsCompleted)
                        i -= 1;
                }
                if (i == 0)
                    done = true;
                // else
                //     Console.WriteLine(i);
            }

            return new Matrix(product);
        }

        private static readonly double FIFTY_FIFTY = 1 / Math.Sqrt(2);

        public static readonly Matrix
            I = new Matrix(new Complex[][] {
                new Complex[] { 1, 0 },
                new Complex[] { 0, 1 }
            }),
            H = new Matrix(new Complex[][] {
                new Complex[] { FIFTY_FIFTY,  FIFTY_FIFTY },
                new Complex[] { FIFTY_FIFTY, -FIFTY_FIFTY }
            }),
            X = new Matrix(new Complex[][] {
                new Complex[] { 0, 1 },
                new Complex[] { 1, 0 }
            }),
            Z = new Matrix(new Complex[][] {
                new Complex[] { 1,  0 },
                new Complex[] { 0, -1 }
            }),
            Y = new Matrix(new Complex[][] {
                new Complex[] {                       0, new Complex(1, 3 / 2.0) }, // [0, -i]
                new Complex[] { new Complex(1, 1 / 2.0),                       0 } //  [i,  0]
            }),
            SWAP = new Matrix(new Complex[][] {
                new Complex[] { 1, 0, 0, 0 },
                new Complex[] { 0, 0, 1, 0 },
                new Complex[] { 0, 1, 0, 0 },
                new Complex[] { 0, 0, 0, 1 }
            }),
            CX = new Matrix(new Complex[][] {
                new Complex[] { 1, 0, 0, 0 },
                new Complex[] { 0, 1, 0, 0 },
                new Complex[] { 0, 0, 0, 1 },
                new Complex[] { 0, 0, 1, 0 }
            }),
            CCX = new Matrix(new Complex[][] {
                new Complex[] { 1, 0, 0, 0, 0, 0, 0, 0 },
                new Complex[] { 0, 1, 0, 0, 0, 0, 0, 0 },
                new Complex[] { 0, 0, 1, 0, 0, 0, 0, 0 },
                new Complex[] { 0, 0, 0, 1, 0, 0, 0, 0 },
                new Complex[] { 0, 0, 0, 0, 1, 0, 0, 0 },
                new Complex[] { 0, 0, 0, 0, 0, 1, 0, 0 },
                new Complex[] { 0, 0, 0, 0, 0, 0, 0, 1 },
                new Complex[] { 0, 0, 0, 0, 0, 0, 1, 0 }
            });

        public void Print() {
            string output = "[";
            for (int r = 0; r < Rows__; r++) {
                output += r == 0 ? "[ " : " [ ";
                for (int c = 0; c < Columns__; c++) {
                    output += c + 1 == Columns__ ? $"{_mat[r][c]} " : $"{_mat[r][c]}, ";
                }
                output += "]";
                if (r + 1 == Rows__)
                    output += "]";
                output += "\n";
            }
            Console.WriteLine(output);
        }

        public override bool Equals(object obj) {
            if (ReferenceEquals(obj, null) || obj.GetType() != typeof(Matrix))
                return false;
            return GetHashCode() == (obj as Matrix).GetHashCode();
        }
        public override int GetHashCode() {
            int sum = 0;
            for (int r = 0; r < _rows_; r++) {
                for (int c = 0; c < _columns_; c++) {
                    sum += _mat[r][c].GetHashCode() * (r.GetHashCode() * c.GetHashCode());
                }
            }
            return sum;
        }

        public static explicit operator MatrixData(Matrix m) {
            ComplexData[][] data = new ComplexData[m.Rows__][];
            for (int r = 0; r < m.Rows__; r++) {
                data[r] = new ComplexData[m.Columns__];
                for (int c = 0; c < m.Columns__; c++) {
                    data[r][c] = new ComplexData { Magnitude = m._mat[r][c].Magnitude, Phase = m._mat[r][c].Phase };
                }
            }
            return new MatrixData { Mat = data };
        }
    }

    #region Complex Number Class
    public class Complex {
        // When measurement occurs this will be the square root of the probability
        public double Magnitude { get; private set; }
        // Phase will be 0 <= x < 2.
        // This will be multiplied by pi to create a phase in radians
        private double _phase = 0;
        public double Phase {
            get => _phase;
            private set {
                _phase = value;
                while (_phase < 0) _phase += 2;
                while (_phase >= 2) _phase -= 2;
            }
        }
        // Incase you don't want to be confused when you print out the phase of a complex number
        public double PhaseAngle {
            get => _phase * Math.PI;
        }

        // Incase you like rectangular coordinates you fucking nerd
        public double Real {
            get => Magnitude * Math.Cos(PhaseAngle);
        }
        public double Imaginary {
            get => Magnitude * Math.Sin(PhaseAngle);
        }
        // TODO: Did I ever need this?
        public Complex Normalized => new Complex(1, _phase);

        // For convenience.
        public Complex(double real) {
            Magnitude = Math.Abs(real);
            if (real < 0)
                _phase = 1;
        }
        // Main constructor for making a complex number.
        public Complex(double magnitude, double phase, bool phaseInRadians = false) {
            Magnitude = magnitude;
            Phase = phaseInRadians ? phase / Math.PI : phase;
        }
        // Copy constructor to avoid weirdness though I think I solved that by making Matricies and Complex Numbers basically immutable.
        // TODO: Do I need this still?
        public Complex(Complex c) {
            Magnitude = c.Magnitude;
            _phase = Phase;
        }

        public static Complex MakeFromRectCoord(double real, double imag) {
            double mag = Math.Sqrt((real * real) + (imag * imag));
            double phase = Math.Atan2(imag, real);
            return new Complex(mag, phase, true);
        }

        // Basic Multiplication of Complex Numbers. // TODO: Verify this actually works
        public static Complex operator *(Complex a, Complex b) {
            return new Complex(a.Magnitude * b.Magnitude, a.Phase + b.Phase);
        }
        public static Complex operator +(Complex a, Complex b) {
            return Complex.MakeFromRectCoord(a.Real + b.Real, a.Imaginary + b.Imaginary);
        }

        // For the convenience of creating gates with a bit more grace.
        public static implicit operator Complex(double a) => new Complex(a);
        public static implicit operator Complex(int a) => new Complex(a);

        public override string ToString() {
            string output = "";
            double r = (double)Decimal.Round((decimal)Real, 2);
            double i = (double)Decimal.Round((decimal)Imaginary, 2);
            if (i == 0) {
                output += r;
            } else {
                if (r != 0) {
                    output += r;
                    if (i < 0)
                        output += $" - {-1 * i}i";
                    else
                        output += $" + {i}i";
                } else {
                    if (i < 0)
                        output += $"-{-1 * i}i";
                    else
                        output += $"{i}i";
                }
            }
            return output;
        }
        public override bool Equals(object obj) {
            if (ReferenceEquals(obj, null) || obj.GetType() != typeof(Complex))
                return false;
            return GetHashCode() == (obj as Complex).GetHashCode();
        }
        public override int GetHashCode()
            => Magnitude.GetHashCode() * 345672439
            + Phase.GetHashCode() * 123453287;
    }
    #endregion
}