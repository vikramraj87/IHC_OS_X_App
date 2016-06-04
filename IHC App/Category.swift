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
    
    
}
