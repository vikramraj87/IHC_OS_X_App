import Cocoa

class CategoriesBarViewController: NSViewController {
    // MARK: - Properties
    var notificationCenter: NSNotificationCenter {
        return NSNotificationCenter.defaultCenter()
    }
    
    static let kCategoryDeletedNotification = "com.kivi.CategoryDeletedNotification"
    
    var categoryAPIAdapter: CategoryAPIAdapter = CategoryAPIAdapter(parser: CategoryJSONParser())
    dynamic var selectedCategory: Category?
    
    @IBOutlet var progressIndicator: NSProgressIndicator!
    
    // MARK: - Notification Observers
    func selectedCategoryDidChange(notification: NSNotification) {
        let outlineView = notification.object as! NSOutlineView
        let selectedRow = outlineView.selectedRow
        guard selectedRow != -1 else {
            selectedCategory = nil
            return
        }
        selectedCategory = outlineView.itemAtRow(selectedRow) as? Category
        return
    }
    
    // MARK: - NSViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notificationCenter.addObserver(self, selector: #selector(CategoriesBarViewController.selectedCategoryDidChange(_:)), name: CategoriesViewController.SelectedCategoryDidChangeNotification, object: nil)
    }
    
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "CreateCategorySegue" {
            let destinationViewController = segue.destinationController as! CreateCategoryViewController
            destinationViewController.parentCategory = selectedCategory!
        }
    }
    
    // MARK: - Actions
    @IBAction func delete(sender: NSButton) {
        progressIndicator.startAnimation(self)
        categoryAPIAdapter.delete(selectedCategory!.id) {
            result in
            switch result {
            case .Success:
                let index = self.selectedCategory!.parent!.subcategories.indexOf(self.selectedCategory!)!
                self.selectedCategory!.parent!.subcategories.removeAtIndex(index)
                self.notificationCenter.postNotificationName(CategoriesBarViewController.kCategoryDeletedNotification, object: self, userInfo: nil)
            case let .Failure(error):
                print("Got error: \(error)")
            }
            self.progressIndicator.stopAnimation(self)
        }
    }
    
    // MARK: - Deinitializer
    deinit {
        notificationCenter.removeObserver(self)
    }
}
