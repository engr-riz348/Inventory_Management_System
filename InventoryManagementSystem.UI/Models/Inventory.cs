using System.Collections.Generic;
using System.Linq;

namespace InventoryManagementSystem.UI.Models
{
    public class Inventory
    {
        private static int nextProductId = 1;
        private List<Product> products = new List<Product>();

        public void AddProduct(Product product)
        {
            products.Add(product);
        }

        public void DeleteProduct(int productId)
        {
            var product = products.FirstOrDefault(p => p.ProductID == productId);
            if (product != null)
            {
                products.Remove(product);
            }
        }

        public void UpdateProduct(Product updatedProduct)
        {
            var product = products.FirstOrDefault(p => p.ProductID == updatedProduct.ProductID);
            if (product != null)
            {
                product.Name = updatedProduct.Name;
                product.Quantity = updatedProduct.Quantity;
                product.Price = updatedProduct.Price;
                product.Supplier = updatedProduct.Supplier;

                if (product is ElectronicProduct electronicProduct && updatedProduct is ElectronicProduct updatedElectronicProduct)
                {
                    electronicProduct.WarrantyMonths = updatedElectronicProduct.WarrantyMonths;
                }
                else if (product is GroceryProduct groceryProduct && updatedProduct is GroceryProduct updatedGroceryProduct)
                {
                    groceryProduct.ExpiryDate = updatedGroceryProduct.ExpiryDate;
                }
            }
        }

        public Product SearchProduct(int productId)
        {
            return products.FirstOrDefault(p => p.ProductID == productId);
        }

        public List<Product> GetProducts()
        {
            return products;
        }

        public List<string> GetAlerts()
        {
            var alerts = new List<string>();
            foreach (var product in products)
            {
                if (product.Quantity < 10)
                {
                    alerts.Add($"Low stock: {product.Name} ({product.Quantity})");
                }

                if (product is GroceryProduct groceryProduct && groceryProduct.ExpiryDate < System.DateTime.Now.AddDays(7))
                {
                    alerts.Add($"Expiring soon: {groceryProduct.Name} ({groceryProduct.ExpiryDate.ToShortDateString()})");
                }
            }
            return alerts;
        }
    }
}
