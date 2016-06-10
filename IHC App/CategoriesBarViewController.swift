import Cocoa

private var KVOContext: Int = 0

class CategoriesBarViewController: NSViewController {
    // MARK: - Properties
    private let store = CategoryStore.sharedInstance
    
    // KVO for CategoryStore.selectedCategory
    // selectedCategory = CategoryStore.selectedCategory
    dynamic var selectedCategory: Category? {
        didSet {
            if selectedCategory == nil {
                addButton.enabled = false
                removeButton.enabled = false
                print("CategoriesBarViewController: No category is selected")
            } else {
                if numberOfLiveContacts == 0 {
                    addButton.enabled = true
                    removeButton.enabled = !selectedCategory!.hasSubcategories
                }
                refreshButton.enabled = true
                print("CategoriesBarViewController: selected category is \(selectedCategory!.name)")
            }
            
        }
    }
    
    // KVO for CategoryStore.Adapter.numberOfLiveContacts
    // numberOfLiveContacts = CategoryStore.Adapter.numberOfLiveContacts
    dynamic var numberOfLiveContacts: Int = 0 {
        didSet {
            if numberOfLiveContacts > 0 {
                progressIndicator.startAnimation(self)
                addButton.enabled = false
                removeButton.enabled = false
                refreshButton.enabled = false
            } else {
                progressIndicator.stopAnimation(self)
                refreshButton.enabled = true
                if selectedCategory != nil {
                    addButton.enabled = true
                    removeButton.enabled = !selectedCategory!.hasSubcategories
                }
            }
        }
    }
    
    // MARK: - Outlets
    @IBOutlet var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var addButton: NSButton!
    @IBOutlet weak var removeButton: NSButton!
    @IBOutlet weak var refreshButton: NSButton!
    
    // MARK: - NSViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        store.addObserver(self, forKeyPath: "selectedCategory", options: [.New], context: &KVOContext)
        store.adapter.addObserver(self, forKeyPath: "numberOfLiveContacts", options: [.New], context: &KVOContext)
    }
    
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "CreateCategorySegue" {
            let destinationViewController = segue.destinationController as! CreateCategoryViewController
            destinationViewController.parentCategory = selectedCategory!
        }
    }
    
    // MARK: - Actions
    @IBAction func delete(sender: NSButton) {
        store.deleteCategory(selectedCategory!)
    }
    
    @IBAction func reloadCategories(sender: NSButton) {
        store.loadCategories()
    }
    
    // MARK: KVO Methods
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard context == &KVOContext else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
            return
        }
        
        var newValue: AnyObject? = change![NSKeyValueChangeNewKey]
        if newValue is NSNull {
            newValue = nil
        }
        
        switch keyPath! {
        case "selectedCategory":
            selectedCategory = newValue as? Category
        case "numberOfLiveContacts":
            numberOfLiveContacts = (newValue as! NSNumber).integerValue
        default:
            break
        }
        
        return
    }
    
    // MARK: Deinit
    deinit {
        store.removeObserver(self, forKeyPath: "selectedCategory", context: &KVOContext)
        store.adapter.removeObserver(self, forKeyPath: "numberOfLiveContacts", context: &KVOContext)
    }
}
