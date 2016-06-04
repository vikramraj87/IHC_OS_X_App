import Cocoa

class CategoriesViewController: NSViewController {
    @IBOutlet var outlineView: NSOutlineView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fetcher = CategoryAPI.sharedInstance
        
        fetcher.allCategories {
            (result) in
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
}