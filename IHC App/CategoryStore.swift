import Foundation

class CategoryStore {
    // MARK: - Singleton pattern
    static let sharedInstance = CategoryStore()
    private init() {
        
    }
    
    // MARK: - Private properties
    private var categories: [Category] = []
    
    // MARK: - Computed properties
    var count: Int {
        return categories.count
    }
    
    // MARK: - Methods
    func addCategory(category: Category) {
        categories.append(category)
    }
    
    func truncate() {
        categories.removeAll()
    }
    
    
    // MARK: - Subscript
    subscript(index: Int) -> Category? {
        if index < categories.count {
            return categories[index]
        }
        return nil
    }
}