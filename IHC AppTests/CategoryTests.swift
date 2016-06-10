import XCTest

class CategoryTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testAddSubcategorySetsParent() {
        let category = Category(name: "Test", parent: nil)
        let subcategory1 = Category(name: "Sub1", parent: nil)
        let index = category.addSubcategory(subcategory1)!
        
        XCTAssertEqual(0, index)
        XCTAssertTrue(category === subcategory1.parent!)
        XCTAssertEqual("Sub1", category.subcategories[0].name)
    }
    
    func testAddingSameSubcategoryReturnsNilAsIndex() {
        let category = Category(name: "Test", parent: nil)
        let subcategory1 = Category(name: "Sub1", parent: nil)
        let subcategory2 = Category(name: "Sub2", parent: nil)
        let subcategory3 = Category(name: "Sub3", parent: nil)
        let index1 = category.addSubcategory(subcategory1)!
        let index2 = category.addSubcategory(subcategory2)!
        let index3 = category.addSubcategory(subcategory3)!
        let index4 = category.addSubcategory(subcategory2)
        
        XCTAssertEqual(0, index1)
        XCTAssertEqual(1, index2)
        XCTAssertEqual(2, index3)
        
        XCTAssertNil(index4)
        
        XCTAssertTrue(category === subcategory1.parent!)
        XCTAssertTrue(category === subcategory2.parent!)
        XCTAssertTrue(category === subcategory3.parent!)
        
        XCTAssertEqual("Sub1", category.subcategories[0].name)
        XCTAssertEqual("Sub2", category.subcategories[1].name)
        XCTAssertEqual("Sub3", category.subcategories[2].name)
    }
    
    func testRemoveSubcategoryReturnsIndexOfRemovedSubcategory() {
        let category = Category(name: "Test", parent: nil)
        
        let subcategory1 = Category(name: "Sub1", parent: nil)
        let subcategory2 = Category(name: "Sub2", parent: nil)
        let subcategory3 = Category(name: "Sub3", parent: nil)
        
        category.addSubcategory(subcategory1)
        category.addSubcategory(subcategory2)
        category.addSubcategory(subcategory3)
        
        let remIndex = category.removeSubcategory(subcategory2)
        XCTAssertEqual(1, remIndex)
        XCTAssertEqual(2, category.subcategories.count)
        XCTAssertEqual("Sub1", category.subcategories[0].name)
        XCTAssertEqual("Sub3", category.subcategories[1].name)
    }
    
    func testRemoveSubcategoryReturnsNilForNonExistingSubcategory() {
        let category = Category(name: "Test", parent: nil)
        
        let subcategory1 = Category(name: "Sub1", parent: nil)
        let subcategory2 = Category(name: "Sub2", parent: nil)
        let subcategory3 = Category(name: "Sub3", parent: nil)
        
        category.addSubcategory(subcategory1)
        category.addSubcategory(subcategory3)
        
        let remIndex = category.removeSubcategory(subcategory2)
        XCTAssertNil(remIndex)
    }
}
