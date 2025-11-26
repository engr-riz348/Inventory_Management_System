using System.Drawing;
using System.Drawing.Drawing2D;
using System.Windows.Forms;

namespace InventoryManagementSystem.UI.Controls
{
    public class Button3D : Button
    {
        private Color _buttonColor = Color.FromArgb(6, 174, 212);
        private Color _shadowColor = Color.FromArgb(6, 174, 212, 100);
        private bool _isHovering = false;

        public Button3D()
        {
            this.FlatStyle = FlatStyle.Flat;
            this.FlatAppearance.BorderSize = 0;
            this.ForeColor = Color.White;
            this.Font = new Font("Arial", 12, FontStyle.Bold);
        }

        protected override void OnPaint(PaintEventArgs e)
        {
            base.OnPaint(e);
            e.Graphics.SmoothingMode = SmoothingMode.AntiAlias;

            // Draw shadow
            if (_isHovering)
            {
                e.Graphics.FillRectangle(new SolidBrush(_shadowColor), new Rectangle(5, 5, this.Width - 1, this.Height - 1));
            }

            // Draw button
            using (var path = new GraphicsPath())
            {
                path.AddRectangle(new Rectangle(0, 0, this.Width - 5, this.Height - 5));
                e.Graphics.FillPath(new SolidBrush(_buttonColor), path);
            }

            // Draw text
            TextRenderer.DrawText(e.Graphics, this.Text, this.Font, this.ClientRectangle, this.ForeColor, TextFormatFlags.HorizontalCenter | TextFormatFlags.VerticalCenter);
        }

        protected override void OnMouseEnter(System.EventArgs e)
        {
            base.OnMouseEnter(e);
            _isHovering = true;
            this.Invalidate();
        }

        protected override void OnMouseLeave(System.EventArgs e)
        {
            base.OnMouseLeave(e);
            _isHovering = false;
            this.Invalidate();
        }
    }
}
