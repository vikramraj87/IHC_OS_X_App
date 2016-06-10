import Foundation

let CategoryStoreNewCategoryAddedNotification = "com.kivi.ihcapp.CategoryStoreNewCategoryAddedNotification"
let CategoryStoreCategoryRemovedNotification = "com.kivi.ihcapp.CategoryStoreCategoryRemovedNotification"
let CategoryStoreCategoriesLoadedNotification = "com.kivi.ihcapp.CategoryStoreCategoriesLoadedNotification"

let CategoryStoreParentCategoryKey = "com.kivi.ihcapp.CategoryStoreParentCategoryKey"
let CategoryStoreCategoryIndexKey = "com.kivi.ihcapp.CategoryStoreCategoryIndexKey"

class CategoryStore: NSObject {
    var adapter: CategoryAPIAdapter
    
    // MARK: - Singleton pattern
    static let sharedInstance = CategoryStore()
    
    private override init() {
        adapter = CategoryAPIAdapter(parser: CategoryJSONParser())
        
        super.init()
    }
    
    // MARK: - Stored properties
    private var categories: [Category] = []
    
    private var notificationCenter: NSNotificationCenter = NSNotificationCenter.defaultCenter()
    
    // Selected category: Will be observed by KVO
    dynamic var selectedCategory: Category?
    
    // MARK: - Computed properties
    var count: Int {
        return categories.count
    }
    
    // MARK: - Helper Methods
    // Add category to the store and post notification
    private func addCategory(category: Category) {
        guard let parentCategory = category.parent else {
            categories.append(category)
            let userInfo = [CategoryStoreCategoryIndexKey: categories.count - 1]
            notificationCenter.postNotificationName(CategoryStoreNewCategoryAddedNotification, object: self, userInfo: userInfo)
            return
        }
        if let addedIndex = parentCategory.addSubcategory(category) {
            let userInfo = [
                CategoryStoreCategoryIndexKey: addedIndex,
                CategoryStoreParentCategoryKey: parentCategory
            ]
            notificationCenter.postNotificationName(CategoryStoreNewCategoryAddedNotification, object: self, userInfo: userInfo)
        }
    }
    
    // Remove category from the store and post notification
    private func removeCategory(category: Category) {
        guard let parentCategory = category.parent else {
            if let index = categories.indexOf(category) {
                let userInfo = [CategoryStoreCategoryIndexKey: index]
                notificationCenter.postNotificationName(CategoryStoreCategoryRemovedNotification, object: self, userInfo: userInfo)
            }
            return
        }
        if let removedIndex = parentCategory.removeSubcategory(category) {
            let userInfo = [
                CategoryStoreCategoryIndexKey: removedIndex,
                CategoryStoreParentCategoryKey: parentCategory
            ]
            notificationCenter.postNotificationName(CategoryStoreCategoryRemovedNotification, object: self, userInfo: userInfo)
        }
    }
    
    // MARK: - Methods
    func loadCategories() {
        categories.removeAll()
        selectedCategory = nil
        notificationCenter.postNotificationName(CategoryStoreCategoriesLoadedNotification, object: self)
        
        adapter.getAll {
            result in
            switch result {
            case let .Success(categories):
                self.categories = categories
            case let .Failure(error):
                print("Got error: \(error)")
            }
            self.notificationCenter.postNotificationName(CategoryStoreCategoriesLoadedNotification, object: self)
        }
    }
    
    func createCategory(category: Category) {
        guard let parentCategory = category.parent else {
            // Currently API does not allow adding top level category
            return
        }
        adapter.createCategoryWithName(category.name, parentCategoryId: parentCategory.id!) {
            result in
            
            switch result {
            case let .Success(categories):
                let category = categories[0]
                category.parent = parentCategory
                self.addCategory(category)
            case let .Failure(error):
                print("Got error: \(error)")
            }
        }
    }
    
    func deleteCategory(category: Category) {
        adapter.deleteCategoryWithId(category.id!) {
            result in
            switch result {
            case .Success:
                self.removeCategory(category)
            case let .Failure(error):
                print("Got error: \(error)")
            }
        }
    }
    
    func moveCategory(category: Category, fromParentCategory oldParent: Category, toParentCategory newParent: Category) {
        // Remove the category from old parent
        removeCategory(category)
        
        // Add the category to new parent
        category.parent = newParent
        addCategory(category)
        
        adapter.moveCategoryWithId(category.id!, underParentCategoryWithId: newParent.id!) {
            result in
            switch result {
            case .Success:
                break
            case let .Failure(error):
                print("Got error \(error)")
                self.removeCategory(category)
                
                category.parent = oldParent
                self.addCategory(category)
            }
        }
    }
    
    func renameCategory(category: Category, withName name: String, errorHandler handler: Void -> Void) {
        adapter.renameCategoryWithId(category.id!, withName: name) {
            result in
            switch result {
            case .Success:
                break
            case let .Failure(error):
                print("Got error: \(error)")
                handler()
            }
        }
    }

    // MARK: - Subscript
    subscript(index: Int) -> Category? {
        if index < categories.count {
            return categories[index]
        }
        return nil
    }
}