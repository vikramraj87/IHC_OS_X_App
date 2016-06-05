import Cocoa

@objc(isCategoryRemovableTransformer) class IsCategoryRemovableTransformer: NSValueTransformer {
    override class func allowsReverseTransformation() -> Bool {
        return false
    }
    
    override class func transformedValueClass() -> AnyClass {
        return NSNumber.self
    }
    
    override func transformedValue(value: AnyObject?) -> AnyObject? {
        guard let category = value as? Category else {
            return NSNumber(bool: false)
        }
        return NSNumber(bool: !category.hasSubcategories)
    }
}