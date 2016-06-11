import Foundation

/// Parses JSON data to Category
struct CategoryJSONParser: JSONParser {
    /// Date formatter to parse the timestamps
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
    
    /**
        Creates Category object from NSDictionary. Recursive function
        creates subcategories else well.
 
         - Parameter categoryDict: NSDictionary containing the data for object.
         - Parameter parentCategory: Optional category object as parameter.
         - Returns: `Category` if successful, else `nil`.
     */
    private func categoryFromDictionary(categoryDict: NSDictionary, parentCategory: Category?) -> Category? {
        // Check whether the dictionary contains all the keys
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
        if let subcategoriesDict = categoryDict["subcategories"] as? [NSDictionary] {
            for subcategoryDict in subcategoriesDict {
                if let subcategory = categoryFromDictionary(subcategoryDict, parentCategory: category) {
                    category.addSubcategory(subcategory)
                }
            }
        }
        
        return category
    }
}