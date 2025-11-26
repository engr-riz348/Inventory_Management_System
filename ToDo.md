## 📝 Project To-Do List: Inventory Management System (IMS)

---

### 1.  planificación del proyecto (Fase 1) 🗓️

* **Define Scope & Requirements:**
  * [ ] Finalize **Product Attributes** for all types.
  * [ ] Detail **Supplier** information required (ID, Name, Contact).
  * [ ] Define **Low Stock Threshold** (e.g., quantity **$< 10$**).
  * [ ] Define **Expiry Alert Window** (e.g., within 30 days).
* **Architectural Planning:**
  * [ ] Sketch the basic **Inheritance structure** (Base `Product` **$\rightarrow$** Derived `ElectronicProduct`, `GroceryProduct`).
  * [ ] Plan the `Inventory` class's internal structure (e.g., using a `List<Product>` or `Dictionary<int, Product>`).
  * [ ] Draft the  **Requirements Specification Document** .

---

### 2. System Design (Fase 2) 📐

* **UML & Flow Diagrams:**
  * [ ] Draw the **Use Case Diagram** for key actors (Store Manager).
  * [ ] Create the **Class Diagram** (must include `Product`, `Supplier`, `ElectronicProduct`, `GroceryProduct`, `Inventory`).
  * [ ] Design the **Main Menu Flow** (System Navigation Diagram).
* **Function Detail:**
  * [ ] Write **Pseudocode** for `AddProduct()`, `UpdateQuantity()`, and `DisplayLowStock()`.
  * [ ] Outline the **Input Validation Strategy** (e.g., checking for negative quantity, non-numeric ID input).

---

### 3. Code Setup & Architecture (Fase 3) 🏗️

* **Project Setup:**
  * [ ] Create the C# **Console Application** project.
* **Base Classes:**
  * [ ] Code the **`Supplier`** class (Properties, Constructor).
  * [ ] Code the **`Product`** base class (Properties: ID, Name, Price, Quantity).
  * [ ] Implement **Encapsulation** (private fields, public properties) in base classes.
* **Derived Classes (Inheritance):**
  * [ ] Code **`ElectronicProduct`** (inherits `Product`, adds `WarrantyMonths`).
  * [ ] Code **`GroceryProduct`** (inherits `Product`, adds `ExpiryDate`).
* **Core Inventory Class:**
  * [ ] Implement the **`Inventory`** class (stores the list of products).
* **Helper Functions:**
  * [ ] Code a reusable function for **safe numeric input** and basic validation.
  * [ ] Code a function for **formatted product output** (displaying product details neatly).

---

### 4. Core Functionality Development (Fase 4) ⚙️

* **CRUD Operations:**
  * [ ] Implement **`AddProduct()`** (handles category selection and unique ID generation).
  * [ ] Implement **`SearchProduct()`** by ID.
  * [ ] Implement  **`UpdateQuantity()`** .
  * [ ] Implement  **`DeleteProduct()`** .
  * [ ] Implement **`DisplayProducts()`** (shows all products and their categories).
* **Alerts & Validation:**
  * [ ] Implement **`CheckLowStock()`** logic.
  * [ ] Implement **`CheckExpiry()`** logic for grocery items.
  * [ ] Integrate **Input Validation** into all user interaction points.

---

### 5. Menu Development & Integration (Fase 5) 🖥️

* **Menu Interface:**
  * [ ] Develop the **Main Menu loop** and `switch-case` structure.
  * [ ] Create the **Product Addition Sub-menu** (to select Electronic or Grocery).
* **Integration:**
  * [ ] **Connect** all `Inventory` methods to the corresponding menu options.
  * [ ] Implement the **Navigation Logic** (`Press Enter to return to Main Menu...`).
  * [ ] Ensure **Polymorphism** is used when displaying product details (e.g., calling a virtual `DisplayDetails()` method).

---

### 6. Testing & Debugging (Fase 6) 🐞

* **Unit Testing:**
  * [ ] Test `AddProduct()` with  **both product types** .
  * [ ] Test **ID validation** (search/delete with non-existent ID).
  * [ ] Test **Quantity Update** (e.g., adding negative amount, setting to zero).
  * [ ] Test **Low Stock alert trigger** (add product below the defined threshold).
  * [ ] Test **Expiry alert trigger** (add a product with an expiry date *near* the current date).
* **System Testing:**
  * [ ] Perform an **end-to-end integration test** of a complete user session.
  * [ ] **Fix all identified bugs** and refine input prompts.

---

### 7. Documentation & Report Creation (Fase 7) 📄

* **Report Sections:**
  * [ ] Finalize the  **Project Proposal** .
  * [ ] Document the **System Design** (UML explanation, class relationships).
  * [ ] Write the **User Manual** (how to run the program and use all features).
  * [ ] Add **Final Output Screenshots** to the report.
  * [ ] **Format** the complete document according to academic standards.

---

### 8. Finalization (Fase 8) 🚀

* [ ] **Code Cleanup** (comments, formatting, variable naming).
* [ ] **Generate Project Files** ZIP folder for submission.
* [ ] Create the **PowerPoint Presentation** outline/slides.
* [ ] Prepare the **Verbal Demo Script** and practice the flow.
* [ ] **Submit** all final deliverables.
