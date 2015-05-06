﻿namespace GH
{
    public class Color
    {
        public Color(double r, double b, double g)
        {
            this.R = r;
            this.B = b;
            this.G = g;
        }

        public double B;
        public double G;
        public double R;

        public bool Equals(Color obj)
        {
            return this.R == obj.R && this.B == obj.B && this.G == obj.G;
        }
    }
}