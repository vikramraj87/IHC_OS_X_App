import Cocoa

private var KVOContext: Int = 0

class CategoriesViewController: NSViewController {
    @IBOutlet var outlineView: NSOutlineView!
    
    var store = CategoryStore.sharedInstance
    
    // KVO for CategoryStore.Adapter.numberOfLiveContacts
    // numberOfLiveContacts = CategoryStore.Adapter.numberOfLiveContacts
    dynamic var numberOfLiveContacts: Int = 0
    
    private let notificationCenter = NSNotificationCenter.defaultCenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Adding observers
        notificationCenter.addObserver(self, selector: #selector(CategoriesViewController.categoryStoreDidLoadedCategories(_:)), name: CategoryStoreCategoriesLoadedNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(CategoriesViewController.categoryStoreNewCategoryAdded(_:)), name: CategoryStoreNewCategoryAddedNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(CategoriesViewController.categoryStoreCategoryRemoved(_:)), name: CategoryStoreCategoryRemovedNotification, object: nil)
        
        store.loadCategories()
        store.adapter.addObserver(self, forKeyPath: "numberOfLiveContacts", options: [.New], context: &KVOContext)
        outlineView.registerForDraggedTypes([Category.CATEGORY_UTI])
    }
    
    func categoryStoreDidLoadedCategories(notification: NSNotification) {
        outlineView.reloadData()
        if store.count > 0 {
            outlineView.expandItem(store[0], expandChildren: true)
        }
        
    }
    
    func categoryStoreNewCategoryAdded(notification: NSNotification) {
        let userInfo = notification.userInfo!
        let addedIndexInt = userInfo[CategoryStoreCategoryIndexKey] as! Int
        let addedIndex = NSIndexSet(index: addedIndexInt)
        guard let parentCategory = userInfo[CategoryStoreParentCategoryKey] as? Category else {
            return
        }
        
        // Insert the new category into the view
        outlineView.insertItemsAtIndexes(addedIndex, inParent: parentCategory, withAnimation: NSTableViewAnimationOptions.SlideRight)
        
        // Expand the parent to make the newly added category visible
        outlineView.expandItem(parentCategory)
        
        // Find the newly added category and select it
        let addedCategory = parentCategory.subcategories[addedIndexInt]
        let newItemIndexInt = outlineView.rowForItem(addedCategory)
        guard newItemIndexInt != -1 else {
            return
        }
        outlineView.selectRowIndexes(NSIndexSet(index: newItemIndexInt), byExtendingSelection: false)
    }
    
    func categoryStoreCategoryRemoved(notification: NSNotification) {
        let userInfo = notification.userInfo!
        let parentCategory = userInfo[CategoryStoreParentCategoryKey] as? Category
        let removedIndex = NSIndexSet(index: userInfo[CategoryStoreCategoryIndexKey] as! Int)
        
        outlineView.removeItemsAtIndexes(removedIndex, inParent: parentCategory, withAnimation: NSTableViewAnimationOptions.SlideLeft)
        if(!parentCategory!.hasSubcategories) {
            outlineView.reloadItem(parentCategory, reloadChildren: true)
        }
    }
    // MARK: Actions
    @IBAction func categoryNameChanged(sender: NSTextField) {
        let newName = sender.stringValue
        
        // get the selected category
        guard let selectedCategory = selectedCategoryFromOutlineview(outlineView) else {
            return
        }
        
        // store the previous name
        let currentName = selectedCategory.name
        
        // prevent contacting server if the name is not changed
        guard newName != currentName else {
            return
        }
        
        // validate the name
        guard newName.characters.count > 0 else {
            sender.stringValue = currentName
            return
        }
        
        // Update the model to reflect the change
        selectedCategory.name = newName
        
        // Contact the server
        store.renameCategory(selectedCategory, withName: newName) {
            // Error handler
            // API returned error
            
            // Restore the previous state in model
            selectedCategory.name = currentName
            
            // and view
            sender.stringValue = currentName
        }
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
        case "numberOfLiveContacts":
            numberOfLiveContacts = (newValue as! NSNumber).integerValue
        default:
            break
        }
    }
    
    // MARK: - Helpers
    private func selectedCategoryFromOutlineview(outlineView: NSOutlineView) -> Category? {
        let selectedRow = outlineView.selectedRow
        guard selectedRow != -1 else {
            return nil
        }
        
        guard let selectedCategory = outlineView.itemAtRow(selectedRow) as? Category else {
            return nil
        }
        
        return selectedCategory
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        store.adapter.removeObserver(self, forKeyPath: "numberOfLiveContacts", context: &KVOContext)
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
    
    func outlineView(outlineView: NSOutlineView, writeItems items: [AnyObject], toPasteboard pasteboard: NSPasteboard) -> Bool {
        pasteboard.declareTypes([Category.CATEGORY_UTI], owner: self)
        return numberOfLiveContacts == 0
    }
    
    func outlineView(outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: AnyObject?, proposedChildIndex index: Int) -> NSDragOperation {
        guard numberOfLiveContacts == 0 else { return NSDragOperation.None }
        
        guard let selectedCategory = selectedCategoryFromOutlineview(outlineView) else { return NSDragOperation.None }
        
        guard let currentParentCategory = selectedCategory.parent else { return NSDragOperation.None }
        
        guard let newParentCategory = item as? Category else { return NSDragOperation.None }
        
        guard newParentCategory !== currentParentCategory else { return NSDragOperation.None }
        
        return NSDragOperation.Move
    }
    
    func outlineView(outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: AnyObject?, childIndex index: Int) -> Bool {
        guard numberOfLiveContacts == 0 else { return false }
        
        guard let selectedCategory = selectedCategoryFromOutlineview(outlineView) else { return false }
        
        guard let currentParentCategory = selectedCategory.parent else { return false }
        
        guard let newParentCategory = item as? Category else { return false }
        
        guard newParentCategory !== currentParentCategory else { return false }
        
        store.moveCategory(selectedCategory, fromParentCategory: currentParentCategory, toParentCategory: newParentCategory)
        return true
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
    
    func outlineViewSelectionDidChange(notification: NSNotification) {
        let outlineView = notification.object as! NSOutlineView
        store.selectedCategory = selectedCategoryFromOutlineview(outlineView)
    }
    
    func outlineView(outlineView: NSOutlineView, shouldEditTableColumn tableColumn: NSTableColumn?, item: AnyObject) -> Bool {
        return false
    }
}

extension CategoriesViewController: NSTextFieldDelegate {
    func control(control: NSControl, textShouldBeginEditing fieldEditor: NSText) -> Bool {
        return numberOfLiveContacts == 0
    }
}