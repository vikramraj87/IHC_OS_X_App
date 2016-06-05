import Cocoa

@objc(isNotEmptyTransformer) class IsNotEmptyTransformer: NSValueTransformer {
    override class func allowsReverseTransformation() -> Bool {
        return false
    }
    
    override class func transformedValueClass() -> AnyClass {
        return NSNumber.self
    }
    
    override func transformedValue(value: AnyObject?) -> AnyObject? {
        guard let str = value as? String else { return NSNumber(bool: false) }
        
        return NSNumber(bool: !str.isEmpty)
    }
}
