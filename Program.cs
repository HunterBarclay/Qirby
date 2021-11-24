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
            var q = new Matrix(new Complex[][] {
                new Complex[] { 0 },
                new Complex[] { 1 }
            });

            var res = Matrix.H * q;
            res.Print();
            res = Matrix.H * res;
            res.Print();

            // Matrix.TensorProduct(Matrix.H, Matrix.I).Print();
        }
    }

    
}
