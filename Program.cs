using System;
using System.Collections.Generic;
using System.Linq;

namespace FuckCunt
{
    public class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("Hello World!");
        }
    }

    public class Matrix {
        private int _columns;
        public int Columns { get => _columns; }
        private int _rows;
        public int Rows { get => _rows; }

        private double[,] _mat;

        public Matrix(int c, int r) {

        }

        public Matrix(double[,] mat) {

        }

        public Matrix(Matrix mat) {

        }

        public double[] this[int i] {
            get => (new List<double>()).
        }

        public Matrix BuildReflection() {

        }

        public static Matrix Identity(int c, int r) {
            double[,] m = new double[c, r];
            for (int i = 0; i < c && i < r; i++) {
                m[i, i] = 1;
            }
        }

        public static Matrix operator *(Matrix a, Matrix b) {
            return new Matrix(0, 0);
        }
    }
}
