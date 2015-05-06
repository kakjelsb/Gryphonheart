﻿
namespace GH.Presenter
{
    using BlizzardApi.WidgetEnums;
    using BlizzardApi.WidgetInterfaces;

    public class RoundButton : DragableButton
    {
        private ITexture icon;

        public RoundButton(double size) : base(size)
        {
            var overlay = this.Button.CreateTexture(null, Layer.OVERLAY);
            overlay.SetWidth(size);
            overlay.SetHeight(size);
            overlay.SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder");
            overlay.SetTexCoord(0, 0.62, 0, 0.62);
            overlay.SetPoint(FramePoint.TOPLEFT, 0, 0);

            this.icon = this.Button.CreateTexture(null, Layer.BACKGROUND);
            this.icon.SetWidth(0.58 * size);
            this.icon.SetHeight(0.58 * size);
            this.icon.SetTexture("Interface/ICONS/ABILITY_MOUNT_GOLDENGRYPHON");
            this.icon.SetPoint(FramePoint.TOPLEFT, 0.19 * size, -0.19 * size);
            this.icon.SetTexCoord(.075, .925, .075, .925);
        }

        public void SetIcon(string texture)
        {
            this.icon.SetTexture(texture);
        }
    }
}
