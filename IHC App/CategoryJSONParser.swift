import Foundation

struct CategoryJSONParser: JSONParser {
    let dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    // MARK: - Conformance to JSONParser
    typealias ObjectType = Category
    
    func objectFromDictionary(dictionary: NSDictionary) -> Category? {
        return categoryFromDictionary(dictionary, parentCategory: nil)
    }
    
    // MARK: - Helpers
    // Creates category from NSDictionary
    // Recursive function
    // Returns nil if the data cannot be parsed to Category
    private func categoryFromDictionary(categoryDict: NSDictionary, parentCategory: Category?) -> Category? {
        // Check whether keys for dictionary exist
        guard let id = categoryDict["id"] as? Int,
            let name = categoryDict["name"] as? String,
            let createdAtString = categoryDict["created_at"] as? String,
            let updatedAtString = categoryDict["updated_at"] as? String,
            let createdAt = dateFormatter.dateFromString(createdAtString),
            let updatedAt = dateFormatter.dateFromString(updatedAtString) else {
                return nil
        }
        
        // Create new category from data
        let category = Category(id: id, name: name, parent: parentCategory, createdAt: createdAt, updatedAt: updatedAt)
        
        // Create subcategories
        var subcategories = [Category]()
        if let subcategoriesDict = categoryDict["subcategories"] as? [NSDictionary] {
            for subcategoryDict in subcategoriesDict {
                if let subcategory = categoryFromDictionary(subcategoryDict, parentCategory: category) {
                    subcategories.append(subcategory)
                }
            }
        }
        
        // Set subcategories for category
        category.subcategories = subcategories
        return category
    }
}