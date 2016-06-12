import Cocoa

class ICDOCodeFormatter: NSFormatter {
    /// Regex Pattern for validating ICD-O Code.
    /// Should start with a number, not zero.
    /// Followed by three numbers.
    /// Followed by backslash(/).
    /// Followed by a number in 0, 1, 2, 3, 6.
    ///
    /// # Examples
    /// ## Valid ones
    /// - 8000/1
    /// - 9099/3
    /// - 8088/0
    /// ## Invalid ones
    /// - 0123/1
    /// - 8088/7
    lazy var regex: NSRegularExpression = {
        return try! NSRegularExpression(pattern: "^([1-9]\\d{3})\\/([01236])$", options: [])
    }()
    
    /**
        Returns `ICDOCode` object from string if the string is a valid ICD-O code
        else returns nil.
        
        - Parameter string: ICD-O code as string
        - Returns: `ICDOCode` object if string is valid else `nil`
     */
    func icdoCodeFromString(string: String) -> ICDOCode? {
        var icdoCodeObject: AnyObject?
        var errorDescription: NSString?
        
        let result = getObjectValue(&icdoCodeObject, forString: string, errorDescription: &errorDescription)
        
        guard result == true else { return nil }
        
        guard let icdoCode = icdoCodeObject as? ICDOCode else { return nil }
        
        return icdoCode
    }
    
    /**
        Returns string from `ICDOCode`
     
        - Parameter icdoCode: ICDOCode object
        - Returns: String representation of ICDOCode
     */
 
    func stringFromICDOCode(icdoCode: ICDOCode) -> String {
        return stringForObjectValue(icdoCode)!
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
            if error != nil {
                let errorString = "Invalid icd-o code provided."
                error.memory = errorString as NSString
            }
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
