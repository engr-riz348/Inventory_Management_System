namespace InventoryManagementSystem.UI.Models
{
    public class Product
    {
        public int ProductID { get; set; }
        public string Name { get; set; }
        public int Quantity { get; set; }
        public double Price { get; set; }
        public Supplier Supplier { get; set; }
    }
}
