using System.Drawing;
using System.Windows.Forms;
using InventoryManagementSystem.UI.Controls;
using InventoryManagementSystem.UI.Models;

namespace InventoryManagementSystem.UI
{
    public partial class MainForm : Form
    {
        private Inventory _inventory = new Inventory();
        private DataGridView _productsGridView;

        public MainForm()
        {
            InitializeComponent();
            this.Text = "Inventory Management System";
            this.Size = new Size(1200, 800);
            this.StartPosition = FormStartPosition.CenterScreen;
            this.BackColor = Color.FromArgb(18, 18, 18);

            // Title Label
            var titleLabel = new Label
            {
                Text = "Inventory Management System",
                Font = new Font("Arial", 24, FontStyle.Bold),
                ForeColor = Color.White,
                TextAlign = ContentAlignment.MiddleCenter,
                Dock = DockStyle.Top,
                Height = 100
            };
            this.Controls.Add(titleLabel);

            // Menu Buttons
            var addButton = new Button3D { Text = "Add Product", Location = new Point(50, 150), Size = new Size(200, 50) };
            addButton.Click += (sender, e) => {
                var addProductForm = new AddProductForm(_inventory);
                addProductForm.ShowDialog();
            };
            var searchButton = new Button3D { Text = "Search Product", Location = new Point(50, 220), Size = new Size(200, 50) };
            var searchTextBox = new TextBox { Location = new Point(300, 120), Size = new Size(200, 20) };
            this.Controls.Add(searchTextBox);
            searchButton.Click += (sender, e) => {
                if (int.TryParse(searchTextBox.Text, out int productId))
                {
                    var product = _inventory.SearchProduct(productId);
                    if (product != null)
                    {
                        _productsGridView.DataSource = new List<Product> { product };
                    }
                    else
                    {
                        MessageBox.Show("Product not found.");
                    }
                }
                else
                {
                    MessageBox.Show("Invalid Product ID.");
                }
            };
            var displayButton = new Button3D { Text = "Display Products", Location = new Point(50, 290), Size = new Size(200, 50) };
            displayButton.Click += (sender, e) => {
                _productsGridView.DataSource = null;
                _productsGridView.DataSource = _inventory.GetProducts();
            };
            var updateButton = new Button3D { Text = "Update Quantity", Location = new Point(50, 360), Size = new Size(200, 50) };
            updateButton.Click += (sender, e) => {
                if (_productsGridView.SelectedRows.Count > 0)
                {
                    var selectedProduct = (Product)_productsGridView.SelectedRows[0].DataBoundItem;
                    var newQuantityForm = new Form
                    {
                        Size = new Size(300, 150),
                        StartPosition = FormStartPosition.CenterParent,
                        BackColor = Color.FromArgb(18, 18, 18)
                    };
                    var quantityTextBox = new TextBox { Location = new Point(50, 20), Size = new Size(200, 20) };
                    var okButton = new Button3D { Text = "OK", Location = new Point(100, 50), Size = new Size(100, 30) };
                    okButton.Click += (s, a) => {
                        if (int.TryParse(quantityTextBox.Text, out int newQuantity))
                        {
                            selectedProduct.Quantity = newQuantity;
                            _inventory.UpdateProduct(selectedProduct);
                            _productsGridView.DataSource = null;
                            _productsGridView.DataSource = _inventory.GetProducts();
                            newQuantityForm.Close();
                        }
                        else
                        {
                            MessageBox.Show("Invalid quantity.");
                        }
                    };
                    newQuantityForm.Controls.Add(quantityTextBox);
                    newQuantityForm.Controls.Add(okButton);
                    newQuantityForm.ShowDialog();
                }
                else
                {
                    MessageBox.Show("Please select a product to update.");
                }
            };
            var deleteButton = new Button3D { Text = "Delete Product", Location = new Point(50, 430), Size = new Size(200, 50) };
            deleteButton.Click += (sender, e) => {
                if (_productsGridView.SelectedRows.Count > 0)
                {
                    var selectedProduct = (Product)_productsGridView.SelectedRows[0].DataBoundItem;
                    var confirmResult = MessageBox.Show("Are you sure you want to delete this product?", "Confirm Delete", MessageBoxButtons.YesNo);
                    if (confirmResult == DialogResult.Yes)
                    {
                        _inventory.DeleteProduct(selectedProduct.ProductID);
                        _productsGridView.DataSource = null;
                        _productsGridView.DataSource = _inventory.GetProducts();
                    }
                }
                else
                {
                    MessageBox.Show("Please select a product to delete.");
                }
            };

            this.Controls.Add(addButton);
            this.Controls.Add(searchButton);
            this.Controls.Add(displayButton);
            this.Controls.Add(updateButton);
            this.Controls.Add(deleteButton);

            // Products Grid View
            _productsGridView = new DataGridView
            {
                Location = new Point(300, 150),
                Size = new Size(850, 500),
                BackgroundColor = Color.FromArgb(30, 30, 30),
                ForeColor = Color.White,
                GridColor = Color.FromArgb(6, 174, 212),
                ColumnHeadersHeightSizeMode = DataGridViewColumnHeadersHeightSizeMode.AutoSize,
                AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill
            };
            this.Controls.Add(_productsGridView);
        }
    }
}
