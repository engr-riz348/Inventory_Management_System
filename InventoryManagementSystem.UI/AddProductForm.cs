using System;
using System.Drawing;
using System.Windows.Forms;
using InventoryManagementSystem.UI.Controls;
using InventoryManagementSystem.UI.Models;

namespace InventoryManagementSystem.UI
{
    public class AddProductForm : Form
    {
        private TextBox _nameTextBox;
        private TextBox _quantityTextBox;
        private TextBox _priceTextBox;
        private ComboBox _supplierComboBox;
        private Button3D _addButton;
        private Inventory _inventory;

        public AddProductForm(Inventory inventory)
        {
            _inventory = inventory;
            this.Text = "Add Product";
            this.Size = new Size(400, 500);
            this.StartPosition = FormStartPosition.CenterParent;
            this.BackColor = Color.FromArgb(18, 18, 18);

            // Name
            _nameTextBox = new TextBox { Location = new Point(50, 50), Size = new Size(300, 20) };
            this.Controls.Add(new Label { Text = "Name:", ForeColor = Color.White, Location = new Point(50, 30) });
            this.Controls.Add(_nameTextBox);

            // Quantity
            _quantityTextBox = new TextBox { Location = new Point(50, 100), Size = new Size(300, 20) };
            this.Controls.Add(new Label { Text = "Quantity:", ForeColor = Color.White, Location = new Point(50, 80) });
            this.Controls.Add(_quantityTextBox);

            // Price
            _priceTextBox = new TextBox { Location = new Point(50, 150), Size = new Size(300, 20) };
            this.Controls.Add(new Label { Text = "Price:", ForeColor = Color.White, Location = new Point(50, 130) });
            this.Controls.Add(_priceTextBox);

            // Supplier
            _supplierComboBox = new ComboBox { Location = new Point(50, 200), Size = new Size(300, 20) };
            this.Controls.Add(new Label { Text = "Supplier:", ForeColor = Color.White, Location = new Point(50, 180) });
            this.Controls.Add(_supplierComboBox);

            // Add Button
            _addButton = new Button3D { Text = "Add", Location = new Point(150, 250), Size = new Size(100, 40) };
            _addButton.Click += (sender, e) => {
                if (int.TryParse(_quantityTextBox.Text, out int quantity) && double.TryParse(_priceTextBox.Text, out double price))
                {
                    var newProduct = new Product
                    {
                        ProductID = _inventory.GetProducts().Count + 1,
                        Name = _nameTextBox.Text,
                        Quantity = quantity,
                        Price = price,
                        Supplier = (Supplier)_supplierComboBox.SelectedItem
                    };
                    _inventory.AddProduct(newProduct);
                    this.Close();
                }
                else
                {
                    MessageBox.Show("Invalid quantity or price.");
                }
            };
            this.Controls.Add(_addButton);
        }
    }
}
