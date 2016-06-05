import Cocoa

class CategoriesViewController: NSViewController {
    @IBOutlet var outlineView: NSOutlineView!
    
    var categoryAPIAdapter: CategoryAPIAdapter = CategoryAPIAdapter(parser: CategoryJSONParser())
    var store = CategoryStore.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CategoriesViewController.CategoryDidCreated(_:)), name: CreateCategoryViewController.kCategoryDidCreatedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CategoriesViewController.CategoryDidDeleted(_:)), name: CategoriesBarViewController.kCategoryDeletedNotification, object: nil)
        
        categoryAPIAdapter.get {
            result in
            switch result {
            case let .Success(categories):
                let store = CategoryStore.sharedInstance
                store.truncate()
                for category in categories {
                    store.addCategory(category)
                }
                self.outlineView.reloadData()
            case let .Failure(error):
                print("Got error: \(error)")
            }
        }
    }
    
    func CategoryDidCreated(notification: NSNotification) {
        outlineView.reloadData()
    }
    
    func CategoryDidDeleted(notification: NSNotification) {
        outlineView.reloadData()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

extension CategoriesViewController: NSOutlineViewDataSource {
    func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
        if let category = item as? Category {
            return category.numberOfSubcategories
        }
        return CategoryStore.sharedInstance.count
    }
    
    func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
        if let category = item as? Category {
            return category.hasSubcategories
        }
        return false
    }
    
    func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
        if let category = item as? Category {
            return category.subcategories[index]
        }
        return CategoryStore.sharedInstance[index]!
    }
}

extension CategoriesViewController: NSOutlineViewDelegate {
    static var SelectedCategoryDidChangeNotification: String {
        return "com.kivi.CategoriesViewController.SelectedCategoryDidChangeNotification"
    }
    
    var notificationCenter: NSNotificationCenter {
        return NSNotificationCenter.defaultCenter()
    }
    
    func outlineView(outlineView: NSOutlineView, viewForTableColumn tableColumn: NSTableColumn?, item: AnyObject) -> NSView? {
        guard let view = outlineView.makeViewWithIdentifier("CategoryCell", owner: self) as? NSTableCellView else {
            return nil
        }
        
        guard let category = item as? Category else {
            return view
        }
        
        guard let textField = view.textField else {
            return view
        }
        
        textField.stringValue = category.name
        return view
    }
    
    func outlineViewSelectionDidChange(notification: NSNotification) {
        let outlineView = notification.object as! NSOutlineView
        
        notificationCenter.postNotificationName(CategoriesViewController.SelectedCategoryDidChangeNotification, object: outlineView)
    }
}