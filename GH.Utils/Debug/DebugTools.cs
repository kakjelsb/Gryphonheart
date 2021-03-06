﻿namespace GH.Utils.Debug
{
    using System;

    using BlizzardApi.Global;
    using BlizzardApi.WidgetEnums;
    using BlizzardApi.WidgetInterfaces;

    using Lua;

    public static class DebugTools
    {
        [Obsolete("Debug.Msg should only be used for debugging. Remember to remove this call.", false)] 
        public static void Msg(object obj1)
        {
            Core.print(obj1);
        }

        [Obsolete("Debug.Msg should only be used for debugging. Remember to remove this call.", false)]
        public static void Msg(object obj1, object obj2)
        {
            Core.print(obj1, obj2);
        }

        [Obsolete("Debug.Msg should only be used for debugging. Remember to remove this call.", false)]
        public static void Msg(object obj1, object obj2, object obj3)
        {
            Core.print(obj1, obj2, obj3);
        }

        [Obsolete("Debug.Msg should only be used for debugging. Remember to remove this call.", false)]
        public static void Msg(object obj1, object obj2, object obj3, object obj4)
        {
            Core.print(obj1, obj2, obj3, obj4);
        }

        [Obsolete("Debug.Msg should only be used for debugging. Remember to remove this call.", false)]
        public static void Msg(object obj1, object obj2, object obj3, object obj4, object obj5)
        {
            Core.print(obj1, obj2, obj3, obj4, obj5);
        }

        [Obsolete("Debug.FrameBg should only be used for debugging. Remember to remove this call.", false)] 
        public static void FrameBg(IFrame frame)
        {
            var bgFrame = (IFrame)Global.FrameProvider.CreateFrame(FrameType.Frame, null, frame);
            bgFrame.SetAllPoints(frame);
            bgFrame.SetFrameLevel(100);
            bgFrame.SetFrameStrata(FrameStrata.HIGH);
            var backdrop = new NativeLuaTable();
            backdrop["bgFile"] = "Interface\\DialogFrame\\UI-DialogBox-Gold-Background";
            backdrop["tile"] = false;
            backdrop["tileSize"] = 0;
            backdrop["edgeSize"] = 16;
            var inserts = new NativeLuaTable();
            backdrop["left"] = 4;
            backdrop["right"] = 4;
            backdrop["top"] = 4;
            backdrop["bottom"] = 0;
            backdrop["insets"] = inserts;
            bgFrame.SetBackdrop(backdrop);
            bgFrame.SetBackdropColor(LuaMath.random(100) / 100, LuaMath.random(100) / 100, LuaMath.random(100) / 100, 0.8);
            
        }
    }
}