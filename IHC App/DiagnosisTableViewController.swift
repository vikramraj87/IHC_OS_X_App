import Cocoa

/// KVOContext
private var KVOContext: Int = 0

/// View controller for managing Diagnoses Table View
class DiagnosisTableViewController: NSViewController {
    /// Singleton instance of DiagnosisStore, data container for tableView
    private let store = DiagnosisStore.sharedInstance
    
    /// Singleton instance of CategoryStore
    private let categoryStore = CategoryStore.sharedInstance
    
    /// Boolean to indicate whether the diagnoses are loaded
    var diagnosesLoaded = false
    
    /// Outlet for table view
    @IBOutlet weak var tableView: NSTableView!
    
    /// Selected category. Observed from CategoryStore
    dynamic var selectedCategory: Category? {
        didSet {
            if let category = selectedCategory {
                print("DiagnosisTableViewController: Selected category is \(category.name)")
            } else {
                print("DiagnosisTableViewController: No category is selected.")
            }
            store.selectedCategory = selectedCategory
            tableView.reloadData()
        }
    }
    
    /// Notification center
    private let notificationCenter = NSNotificationCenter.defaultCenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryStore.addObserver(self, forKeyPath: "selectedCategory", options: [.New], context: &KVOContext)
        
        store.loadAllDiagnoses()
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
        default:
            break
        }
        
        return
    }
    
    // MARK: Deinit
    deinit {
        categoryStore.removeObserver(self, forKeyPath: "selectedCategory", context: &KVOContext)
    }
}

extension DiagnosisTableViewController: NSTableViewDataSource {
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return store.diagnosesUnderSelectedCategory.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        return store.diagnosesUnderSelectedCategory[row]
    }
    
    
}
