import Cocoa

private var KVOContext: Int = 0

class DiagnosisBarViewController: NSViewController {

    dynamic var addButtonEnabled = false
    
    dynamic var removeButtonEnabled = false
    
    dynamic var refreshButtonEnabled = false
    
    dynamic var isCategoryAdapterBusy = false {
        didSet {
            updateButtons()
        }
    }
    
    dynamic var isDiagnosisAdapterBusy = false {
        didSet {
            updateButtons()
        }
    }
    
    dynamic var selectedCategory: Category? {
        didSet {
            updateButtons()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CategoryStore.sharedInstance.addObserver(self, forKeyPath: "selectedCategory", options: [.New], context: &KVOContext)
        
        CategoryStore.sharedInstance.adapter.addObserver(self, forKeyPath: "numberOfLiveContacts", options: [.New], context: &KVOContext)
        
        DiagnosisStore.sharedInstance.adapter.addObserver(self, forKeyPath: "numberOfLiveContacts", options: [.New], context: &KVOContext)
    }
    
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "CreateDiagnosisSegue" {
            let destinationViewController = segue.destinationController as! CreateDiagnosisViewController
            destinationViewController.category = selectedCategory!
        }
    }
    
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
            let numberOfLiveContacts = (newValue as! NSNumber).integerValue
            if object is CategoryAPIAdapter {
                isCategoryAdapterBusy = numberOfLiveContacts > 0
            } else if object is DiagnosisAPIAdapter {
                isDiagnosisAdapterBusy = numberOfLiveContacts > 0
            }
        case "selectedCategory":
            selectedCategory = newValue as? Category
        default:
            break
        }
    }
    
    private func updateButtons() {
        guard let selectedCategory = selectedCategory else {
            addButtonEnabled = false
            removeButtonEnabled = false
            refreshButtonEnabled = false
            return
        }
        
        guard !isDiagnosisAdapterBusy else {
            addButtonEnabled = false
            removeButtonEnabled = false
            refreshButtonEnabled = false
            return
        }
        
        guard !isCategoryAdapterBusy else {
            addButtonEnabled = false
            removeButtonEnabled = false
            refreshButtonEnabled = false
            return
        }
        
        addButtonEnabled = !selectedCategory.hasSubcategories
        // Remove button should be enabled when a diagnosis is selected
        refreshButtonEnabled = true
    }
}
