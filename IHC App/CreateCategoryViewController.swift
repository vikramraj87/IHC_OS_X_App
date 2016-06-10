import Cocoa

class CreateCategoryViewController: NSViewController {
    dynamic var parentCategory: Category!
    dynamic var newCategory: Category!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newCategory = Category(name: "", parent: parentCategory)
    }
    
    @IBAction func addCategory(sender: NSButton) {
        CategoryStore.sharedInstance.createCategory(newCategory)
        self.dismissController(self)
    }
}

