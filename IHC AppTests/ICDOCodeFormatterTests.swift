import XCTest

class ICDOCodeFormatterTests: XCTestCase {
    var formatter: ICDOCodeFormatter!
    
    override func setUp() {
        super.setUp()
        formatter = ICDOCodeFormatter()
    }
    
    func testReturnsNilWhenFormattingANonICDOCode() {
        var icdoCodeString: String?
        icdoCodeString = formatter.stringForObjectValue("123456")
        XCTAssertNil(icdoCodeString)
    }
    
    func testReturnsCorrectStringForICDOCode() {
        let icdoCode = ICDOCode(morphologyCode: 8088, behaviorCode: 3)
        let icdoCodeString = formatter.stringForObjectValue(icdoCode)
        XCTAssertEqual("8088/3", icdoCodeString)
        XCTAssertEqual("8088/3", formatter.stringFromICDOCode(icdoCode))
    }
    
    func testReturnsFalseWhenNonsenseIsGiven() {
        let icdoCodeString = "NONSENSE"
        
        var icdoCodeObject: AnyObject?
        var errorDescription: NSString?
        
        let result = formatter.getObjectValue(&icdoCodeObject, forString: icdoCodeString, errorDescription: &errorDescription)
        
        XCTAssertFalse(result)
        XCTAssertNil(icdoCodeObject)
        XCTAssertEqual("Invalid icd-o code provided.", errorDescription!)
        XCTAssertNil(formatter.icdoCodeFromString(icdoCodeString))
    }
    
    func testReturnsFalseWhenNumberIsLessThanMinimumInMorphologyCode() {
        let icdoCodeString = "880/3"
        
        var icdoCodeObject: AnyObject?
        var errorDescription: NSString?
        
        let result = formatter.getObjectValue(&icdoCodeObject, forString: icdoCodeString, errorDescription: &errorDescription)
        
        XCTAssertFalse(result)
        XCTAssertNil(icdoCodeObject)
        XCTAssertEqual("Invalid icd-o code provided.", errorDescription!)
        XCTAssertNil(formatter.icdoCodeFromString(icdoCodeString))
    }
    
    func testReturnsFalseWhenMorphologyCodeStartsWithZero() {
        let icdoCodeString = "0880/3"
        
        var icdoCodeObject: AnyObject?
        var errorDescription: NSString?
        
        let result = formatter.getObjectValue(&icdoCodeObject, forString: icdoCodeString, errorDescription: &errorDescription)
        
        XCTAssertFalse(result)
        XCTAssertNil(icdoCodeObject)
        XCTAssertEqual("Invalid icd-o code provided.", errorDescription!)
        XCTAssertNil(formatter.icdoCodeFromString(icdoCodeString))
    }
    
    func testReturnsFalseWhenBehaviorCodeIsInvalid() {
        let icdoCodeString = "8800/5"
        
        var icdoCodeObject: AnyObject?
        var errorDescription: NSString?
        
        let result = formatter.getObjectValue(&icdoCodeObject, forString: icdoCodeString, errorDescription: &errorDescription)
        
        XCTAssertFalse(result)
        XCTAssertNil(icdoCodeObject)
        XCTAssertEqual("Invalid icd-o code provided.", errorDescription!)
        XCTAssertNil(formatter.icdoCodeFromString(icdoCodeString))
    }
    
    func testReturnsTrueAndObjectForValidString() {
        let icdoCodeString = "8808/6"
        
        var icdoCodeObject: AnyObject?
        var errorDescription: NSString?
        
        let result = formatter.getObjectValue(&icdoCodeObject, forString: icdoCodeString, errorDescription: &errorDescription)
        
        XCTAssertTrue(result)
        XCTAssertNil(errorDescription)
        
        let icdoCode = icdoCodeObject as! ICDOCode
        XCTAssertEqual(8808, icdoCode.morphologyCode)
        XCTAssertEqual(6, icdoCode.behaviorCode)
        
        let icdoCode2 = formatter.icdoCodeFromString("8088/3")
        XCTAssertEqual(8088, icdoCode2!.morphologyCode)
        XCTAssertEqual(3, icdoCode2!.behaviorCode)
    }
}
