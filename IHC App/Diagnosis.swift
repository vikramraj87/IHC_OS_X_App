import Cocoa

class Diagnosis: NSObject {
    /// ID of the category. Nil when a new category is created and not sent
    /// to the server
    let id: Int?
    
    /// Name of the diagnosis
    var name: String
    
    /// TODO: Struct ICDOCode
    
    /// Cateogory of the diagnosis
    unowned var category: Category
    
    /// Created at timestamp
    let createdAt: NSDate?
    
    /// Updated at timestamp
    let updatedAt: NSDate?
    
    init(id: Int?, name: String, category: Category, createdAt: NSDate?, updatedAt: NSDate?) {
        self.id = id
        self.name = name
        self.category = category
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        
        super.init()
    }
    
}
