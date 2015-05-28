﻿
namespace CsLuaTest
{
    using TryCatchFinally;
    using AmbigousMethods;
    using CsLua.Collection;
    using DefaultValues;
    using General;
    using Interfaces;
    using Lua;
    using Override;
    using Serialization;
    using Wrap;

    class Program
    {
        static void Main(string[] args)
        {
            var tests = new CsLuaList<ITestSuite>()
            {
                new TryCatchFinallyTests(),
                new GeneralTests(),
                new AmbigousMethodsTests(),
                new OverrideTest(),
                new SerializationTests(),
                new DefaultValuesTests(),
                new InterfacesTests(),
                new WrapTests(),
            };

            tests.Foreach(test => test.PerformTests());
            Core.print("CsLua test completed.");
        }
    }
}
