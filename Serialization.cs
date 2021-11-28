using System;

using Qirby.Mathematics;

namespace Qirby.Serialization {

    public struct MatrixData {
        public ComplexData[][] Mat;
    }

    public struct ComplexData {
        public double Magnitude;
        public double Phase;
    }

}