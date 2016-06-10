import Cocoa

class Category: NSObject {
    // Id will be nil when a new category is created and not
    // reached the API server
    let id: Int?
    
    dynamic var name: String
    private var _subcategories: [Category] = []
    
    // parent is null when the category is a top level category
    weak var parent: Category?
    
    // subcategories is an empty array when a category does
    // not have subcategories
    var subcategories: [Category] {
        return _subcategories
    }
    
    let createdAt: NSDate?
    let updatedAt: NSDate?
    
    var hasSubcategories: Bool {
        return subcategories.count > 0
    }
    
    var numberOfSubcategories: Int {
        return subcategories.count
    }
    
    // MARK: - Initializers
    required init?(coder aDecoder: NSCoder) {
        guard let name = aDecoder.decodeObjectForKey("name") as? String,
            let subcategories = aDecoder.decodeObjectForKey("subcategories") as? [Category]
            else {
                return nil
        }
        
        self.name = name
        _subcategories = subcategories
        id = aDecoder.decodeIntegerForKey("id")
        parent = aDecoder.decodeObjectForKey("parent") as? Category
        createdAt = aDecoder.decodeObjectForKey("createdAt") as? NSDate
        updatedAt = aDecoder.decodeObjectForKey("updatedAt") as? NSDate
    }
    
    init(id: Int?, name: String, parent: Category?, createdAt: NSDate?, updatedAt: NSDate?) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.parent = parent
        super.init()
    }
    
    convenience init(name: String, parent: Category?) {
        self.init(id: nil, name: name, parent: parent, createdAt: nil, updatedAt: nil)
    }
    
    required init?(pasteboardPropertyList propertyList: AnyObject, ofType type: String) {
        return nil
    }
    
    // return index of newly added category
    // return nil if category already exists
    func addSubcategory(category: Category) -> Int? {
        guard _subcategories.indexOf(category) == nil else {
            // Category already exists
            // No need to add subcategory
            return nil
        }
        _subcategories.append(category)
        category.parent = self
        return _subcategories.indexOf(category)
    }
    
    // return index of newly removed category
    // return nil if category does not exist
    func removeSubcategory(category: Category) -> Int? {
        guard let index = _subcategories.indexOf(category) else {
            return nil
        }
        _subcategories.removeAtIndex(index)
        return index
    }
    
    // MARK: - Validation
    func validateName(nameStringPointer: AutoreleasingUnsafeMutablePointer<NSString?>, error outError: NSErrorPointer) -> Bool {
        let nameString = nameStringPointer.memory
        
        guard let untrimmedName = nameString as? String else {
            outError.memory = getValidationErrorWithMessage("Category name cannot be nil")
            return false
        }
        
        let name = untrimmedName.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        guard name.characters.count > 0 else {
            outError.memory = getValidationErrorWithMessage("Category name cannot be empty")
            return false
        }
        
        guard name.characters.count > 3 else {
            outError.memory = getValidationErrorWithMessage("Category name must be more than three characters long")
            return false
        }
        
        nameStringPointer.memory = name
        return true
    }
    
    // MARK: - Helper methods
    private func getValidationErrorWithMessage(message: String) -> NSError {
        let domain = "Category.InputValidationError"
        let code = 0
        let userInfo = [NSLocalizedDescriptionKey: message]
        return NSError(domain: domain, code: code, userInfo: userInfo)
    }
}

extension Category: NSCoding {
    func encodeWithCoder(aCoder: NSCoder) {
        if let id = id {
            aCoder.encodeInteger(id, forKey: "id")
        }
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(_subcategories, forKey: "subcategories")
        if let parent = parent {
            print("Encoding parent \(parent.name)")
            aCoder.encodeConditionalObject(parent, forKey: "parent")
        }
        if let createdAt = createdAt {
            aCoder.encodeObject(createdAt, forKey: "createdAt")
        }
        if let updatedAt = updatedAt {
            aCoder.encodeObject(updatedAt, forKey: "updatedAt")
        }
    }
}

extension Category: NSPasteboardWriting, NSPasteboardReading {
    // MARK: - Pasteboard
    static var CATEGORY_UTI: String {
        return "com.kivi.ihcapp.category"
    }
    
    func writableTypesForPasteboard(pasteboard: NSPasteboard) -> [String] {
        return [Category.CATEGORY_UTI]
    }
    
    func pasteboardPropertyListForType(type: String) -> AnyObject? {
        guard type == Category.CATEGORY_UTI else {
            return nil
        }
        return NSKeyedArchiver.archivedDataWithRootObject(self)
    }
    
    static func readableTypesForPasteboard(pasteboard: NSPasteboard) -> [String] {
        return [Category.CATEGORY_UTI]
    }
    
    static func readingOptionsForType(type: String, pasteboard: NSPasteboard) -> NSPasteboardReadingOptions {
        return NSPasteboardReadingOptions.AsKeyedArchive
    }
}