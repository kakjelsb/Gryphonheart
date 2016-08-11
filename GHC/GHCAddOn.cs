﻿
namespace GHC
{
    using BlizzardApi.EventEnums;
    using BlizzardApi.Global;
    using CsLuaFramework;
    using CsLuaFramework.Attributes;
    using CsLuaFramework.Wrapping;
    using GH.Integration;
    using GH.Misc;
    using GH.Model;
    using GH.Utils.AddOnIntegration;
    using Lua;
    using Modules.AbilityActionBar;

    [CsLuaAddOn("GHC", "Gryphonheart Crime", 70000, Author = "The Gryphonheart Team", Dependencies = new []{"GH"})]
    public class GHCAddOn : ICsLuaAddOn
    {
        private IAddOnIntegration integration;

        public void Execute()
        {
            Misc.RegisterEvent(SystemEvent.ADDON_LOADED, this.OnAddOnLoaded);
            this.integration = (IAddOnIntegration)Global.Api.GetGlobal(AddOnIntegration.GlobalReference);

            this.integration.RegisterDefaultButton(new QuickButton(
                "ghcMain",
                6,
                true,
                "Gryphonheart Crime",
                "Interface/ICONS/Ability_Stealth",
                TempShowActionBar,
                AddOnReference.GHC));
        }

        private void OnAddOnLoaded(SystemEvent eventName, object addonName)
        {
            if (addonName.Equals("GHC"))
            {
                this.integration.RegisterAddOn(AddOnReference.GHC);
            }
        }

        private void TempShowActionBar()
        {
            var duration = 5;
            double? castTime = null;
            var bar = new ActionBar((frame) => new ActionButtonProxy(frame, new Wrapper()));
            bar.AddButton("test", "Interface/ICONS/INV_Misc_Bag_11", s =>
            {
                castTime = Global.Api.GetTime();
                Core.print("test");
            }, 
            (s, tooltip) => { tooltip.AddLine("Test"); },
                (s) => new CooldownInfo()
                {
                    Active = castTime != null && Global.Api.GetTime() < castTime + duration,
                    Duration = duration,
                    StartTime = castTime
                });
            bar.Show();
        }
    }
}
