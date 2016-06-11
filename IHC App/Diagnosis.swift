import Cocoa

class Diagnosis: NSObject {
    /// ID of the category. Nil when a new category is created and not sent
    /// to the server
    let id: Int?
    
    /// Name of the diagnosis
    var name: String
    
    /// ICD-O code for the diagnosis
    var icdoCode: ICDOCode
    
    /// Category ID
    let categoryId: Int
    
    /// Cateogory of the diagnosis
    weak var category: Category?
    
    /// Created at timestamp
    let createdAt: NSDate?
    
    /// Updated at timestamp
    let updatedAt: NSDate?
    
    init(id: Int?, name: String, icdoCode: ICDOCode, categoryId: Int, category: Category?, createdAt: NSDate?, updatedAt: NSDate?) {
        self.id = id
        self.name = name
        self.icdoCode = icdoCode
        self.categoryId = categoryId
        self.category = category
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        
        super.init()
    }
    
    convenience init(name: String, icdoCode: ICDOCode, categoryId: Int) {
        self.init(id: nil, name: name, icdoCode: icdoCode, categoryId: categoryId, category: nil, createdAt: nil, updatedAt: nil)
    }
    
    convenience init(id: Int?, name: String, icdoCode: ICDOCode, categoryId: Int, createdAt: NSDate?, updatedAt: NSDate?) {
        self.init(id: id, name: name, icdoCode: icdoCode, categoryId: categoryId, category: nil, createdAt: createdAt, updatedAt: updatedAt)
    }
    
}
