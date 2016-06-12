import Cocoa

/// Context for KVO
private var KVOContext: Int = 0

/// View controller for managing Categories Outline View
class CategoriesViewController: NSViewController {
    // MARK: - Properties
    /// Only subview - outline view to be managed
    @IBOutlet var outlineView: NSOutlineView!
    
    /// Singleton instance of CategoryStore, data container for outline view
    let store = CategoryStore.sharedInstance
    
    /// Number of server contacts made by CategoryAPIAdapter
    dynamic var numberOfLiveContacts: Int = 0
    
    /// Notification center
    private let notificationCenter = NSNotificationCenter.defaultCenter()
    
    // MARK: - NSViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Adding observers
        notificationCenter.addObserver(self, selector: #selector(CategoriesViewController.categoryStoreDidLoadedCategories(_:)), name: CategoryStoreCategoriesLoadedNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(CategoriesViewController.categoryStoreNewCategoryAdded(_:)), name: CategoryStoreNewCategoryAddedNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(CategoriesViewController.categoryStoreCategoryRemoved(_:)), name: CategoryStoreCategoryRemovedNotification, object: nil)
        
        // Add KVO for CategoryAPIAdapter.numberOfLiveContacts
        store.adapter.addObserver(self, forKeyPath: "numberOfLiveContacts", options: [.New], context: &KVOContext)
        
        // Register drag types for outline view
        outlineView.registerForDraggedTypes([Category.CATEGORY_UTI])
        
        // Load all categories from API
        store.loadCategories()
    }
    
    // MARK: - Observers
    
    /**
        Observer for CategoryStoreCategoriesLoadedNotification
 
        - Parameter notification: NSNotification object
     */
    func categoryStoreDidLoadedCategories(notification: NSNotification) {
        // Reload data of outline view
        outlineView.reloadData()
        if store.count > 0 {
            // Expand all the items initially
            outlineView.expandItem(store[0], expandChildren: true)
        }
        
    }
    
    /**
        Observer for CategoryStoreNewCategoryAddedNotification
     
        - Parameter notification: NSNotification object
     */
    func categoryStoreNewCategoryAdded(notification: NSNotification) {
        // Grab the userInfo dictionary
        let userInfo = notification.userInfo!
        
        // Grab the newly added index
        let addedIndexInt = userInfo[CategoryStoreCategoryIndexKey] as! Int
        let addedIndex = NSIndexSet(index: addedIndexInt)
        
        // Get the parent of newly added category from userInfo
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
    
    /**
        Observer for CategoryStoreCategoryRemovedNotification

        - Parameter notification: NSNotification object
     */
    func categoryStoreCategoryRemoved(notification: NSNotification) {
        // Grab the userInfo dictionary
        let userInfo = notification.userInfo!
        
        // Grab the parent category
        let parentCategory = userInfo[CategoryStoreParentCategoryKey] as? Category
        
        // Grab the removed index
        let removedIndex = NSIndexSet(index: userInfo[CategoryStoreCategoryIndexKey] as! Int)
        
        // Remove the item from view
        outlineView.removeItemsAtIndexes(removedIndex, inParent: parentCategory, withAnimation: NSTableViewAnimationOptions.SlideLeft)
        
        // Reload the parent category if it has no subcategories
        // to remove the disclosure button
        // TODO: Find a better solution for removing disclosure button
        if(!parentCategory!.hasSubcategories) {
            outlineView.reloadItem(parentCategory, reloadChildren: true)
        }
    }
    
    // MARK: - Actions
    
    /**
        Action method to be called when a category name is changed
 
        - Parameter sender: NSTextField whose text is changed
     */
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
        
        // TODO: Validate name to check whether it has already been taken
        
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
        // Check for context
        guard context == &KVOContext else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
            return
        }
        
        // Get the new value
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
    
    /**
         Returns the selected item of outline view as Category
         
         - Parameter outlineView: outline view from which to get the selected category
         
         - Returns: Selected category if an item is selected else nil
     */
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
        // Remove observers
        NSNotificationCenter.defaultCenter().removeObserver(self)
        store.adapter.removeObserver(self, forKeyPath: "numberOfLiveContacts", context: &KVOContext)
    }
}

// MARK: - Extensions
extension CategoriesViewController: NSOutlineViewDataSource {
    func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
        // If a category is selected, return the number of selected categories
        if let category = item as? Category {
            return category.numberOfSubcategories
        }
        
        // Else return the number of top level categories
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
    
    // MARK: Drag and Drop
    func outlineView(outlineView: NSOutlineView, writeItems items: [AnyObject], toPasteboard pasteboard: NSPasteboard) -> Bool {
        pasteboard.declareTypes([Category.CATEGORY_UTI], owner: self)
        
        // Allow drag n drop only when the server is not being contacted
        return numberOfLiveContacts == 0
    }
    
    func outlineView(outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: AnyObject?, proposedChildIndex index: Int) -> NSDragOperation {
        
        // Allow drag n drop only when the server is not being contacted
        guard numberOfLiveContacts == 0 else { return NSDragOperation.None }
        
        // Allow only when a category is selected (which is dragged)
        guard let selectedCategory = selectedCategoryFromOutlineview(outlineView) else { return NSDragOperation.None }
        
        // Allow only when current parent category is available
        guard let currentParentCategory = selectedCategory.parent else { return NSDragOperation.None }
        
        // Allow the drop when new category (where drop is propoesed) is also
        // a valid category
        guard let newParentCategory = item as? Category else { return NSDragOperation.None }
        
        // Allow drop only the new parent is different from current parent
        // Else no meaning for the drop
        // No reordering within a category is supported
        guard newParentCategory !== currentParentCategory else { return NSDragOperation.None }
        
        return NSDragOperation.Move
    }
    
    func outlineView(outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: AnyObject?, childIndex index: Int) -> Bool {
        // Allow drag n drop only when the server is not being contacted
        guard numberOfLiveContacts == 0 else { return false }
        
        // Allow only when a category is selected (which is dragged)
        guard let selectedCategory = selectedCategoryFromOutlineview(outlineView) else { return false }
        
        // Allow only when current parent category is available
        guard let currentParentCategory = selectedCategory.parent else { return false }
        
        // Allow the drop when new category (where drop is propoesed) is also
        // a valid category
        guard let newParentCategory = item as? Category else { return false }
        
        // Allow drop only the new parent is different from current parent
        // Else no meaning for the drop
        // No reordering within a category is supported
        guard newParentCategory !== currentParentCategory else { return false }
        
        // Update the model
        store.moveCategory(selectedCategory, fromParentCategory: currentParentCategory, toParentCategory: newParentCategory)
        return true
    }
    
    
}

// MARK: -
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
        
        // Update the model with the selected item of the view
        store.selectedCategory = selectedCategoryFromOutlineview(outlineView)
    }
}

// MARK: -
extension CategoriesViewController: NSTextFieldDelegate {
    func control(control: NSControl, textShouldBeginEditing fieldEditor: NSText) -> Bool {
        // Allow editing when API is not contacted
        return numberOfLiveContacts == 0
    }
}