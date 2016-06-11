import Cocoa

class ICDOCodeFormatter: NSFormatter {
    lazy var regex: NSRegularExpression = {
        return try! NSRegularExpression(pattern: "^([1-9]\\d{3})\\/([01236])$", options: [])
    }()
    
    func icdoCodeFromString(string: String) -> ICDOCode? {
        var icdoCodeObject: AnyObject?
        var errorDescription: NSString?
        
        let result = getObjectValue(&icdoCodeObject, forString: string, errorDescription: &errorDescription)
        
        guard result == true else { return nil }
        
        guard let icdoCode = icdoCodeObject as? ICDOCode else { return nil }
        
        return icdoCode
    }
    
    func stringFromICDOCode(icdoCode: ICDOCode) -> String? {
        return stringForObjectValue(icdoCode)
    }
    // MARK: - NSFormatter
    override func stringForObjectValue(obj: AnyObject) -> String? {
        guard let icdoCode = obj as? ICDOCode else {
            return nil
        }
        return "\(icdoCode.morphologyCode)/\(icdoCode.behaviorCode)"
    }
    
    override func getObjectValue(obj: AutoreleasingUnsafeMutablePointer<AnyObject?>, forString string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>) -> Bool {
        
        let range = NSRange(location: 0, length: string.characters.count)
        
        guard let result = regex.firstMatchInString(string, options: [], range: range) else {
            error.memory = "Invalid icd-o code provided."
            return false
        }
        
        let morphologyCode: Int = {
            let range = result.rangeAtIndex(1)
            let start = string.startIndex
            let end = string.startIndex.advancedBy(range.length)
            let indexRange = start..<end
            return Int(string.substringWithRange(indexRange))!
        }()
        
        let behaviorCode: Int = {
            let range = result.rangeAtIndex(2)
            let start = string.startIndex.advancedBy(range.location)
            let end = string.endIndex
            let indexRange = start..<end
            return Int(string.substringWithRange(indexRange))!
        }()
        
        let icdoCode = ICDOCode(morphologyCode: morphologyCode, behaviorCode: behaviorCode)
        obj.memory = icdoCode
        return true
    }
}
