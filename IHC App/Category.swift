import Cocoa

class Category: NSObject {
    let id: Int
    var name: String
    
    // parent is null when the category is a top level category
    weak var parent: Category?
    
    // subcategories is an empty array when a category does
    // not have subcategories
    var subcategories: [Category] = []
    
    let createdAt: NSDate
    let updatedAt: NSDate
    
    var hasSubcategories: Bool {
        return subcategories.count > 0
    }
    
    var numberOfSubcategories: Int {
        return subcategories.count
    }
    
    init(id: Int, name: String, parent: Category?, createdAt: NSDate, updatedAt: NSDate) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.parent = parent
        super.init()
    }
    
    func validateName(namePointer: AutoreleasingUnsafeMutablePointer<NSString?>, error outError: NSErrorPointer) -> Bool {
        let nameValue = namePointer.memory
        
        guard var name = nameValue as? String else {
            outError.memory = getInputValidationErrorWithCode(0, message: "Catergory name must be a non-nil String")
            return false
        }
        
        name = name.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        guard name.characters.count > 0 else {
            outError.memory = getInputValidationErrorWithCode(0, message: "Category name must not be empty")
            return false
        }
        
        guard name.characters.count > 3 else {
            outError.memory = getInputValidationErrorWithCode(0, message: "Category name must be atleast 4 characters long")
            return false
        }
        
        return true
    }
    
    private func getInputValidationErrorWithCode(code: Int, message: String) -> NSError {
        let domain = "UserInputValidationErrorDomain"
        let userInfo = [NSLocalizedDescriptionKey: message]
        return NSError(domain: domain, code: code, userInfo: userInfo)
    }
}
