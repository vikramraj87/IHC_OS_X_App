import Cocoa

class CreateCategoryViewController: NSViewController {
    static let kCategoryDidCreatedNotification = "com.kivi.CategoryDidCreatedNotification"
    static let kParentCategoryKey = "com.kivi.ParentCategoryKey"
    
    dynamic var parentCategory: Category!
    dynamic var categoryName: String?
    var categoryAPIAdapter: CategoryAPIAdapter = CategoryAPIAdapter(parser: CategoryJSONParser())
    
    @IBOutlet var progressIndicator: NSProgressIndicator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func addCategory(sender: NSButton) {
        progressIndicator.startAnimation(self)
        categoryAPIAdapter.create(categoryName!, parentCategoryId: parentCategory.id) {
            result in
            switch result {
            case let .Success(categories):
                let category = categories[0]
                self.parentCategory.subcategories.append(category)
                let userInfo = [CreateCategoryViewController.kParentCategoryKey: self.parentCategory]
                NSNotificationCenter.defaultCenter().postNotificationName(CreateCategoryViewController.kCategoryDidCreatedNotification, object: self, userInfo: userInfo)
            case let .Failure(error):
                print("Got error: \(error)")
            }
            self.progressIndicator.stopAnimation(self)
            self.dismissController(self)
        }
    }
}

