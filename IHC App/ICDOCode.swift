import Foundation

class ICDOCode: NSObject {
    /// Corresponds to morphology of the tumor
    var morphologyCode: Int
    
    /// Corresponds to behaviour of the tumor
    /// 0: Benign neoplasms
    /// 1: Neoplasms of uncertain behavior
    /// 2: In situ neoplasms
    /// 3: Malignant neoplasms, primary
    /// 6: Malignant neoplasms, secondary
    var behaviorCode: Int
    
    /**
         Initializer
         - Parameter morphologyCode: Integer representing morphology code
         - Parameter behaviorCode: Integer representing behavior code (0, 1, 2, 3, 6)
     */
    init(morphologyCode: Int, behaviorCode: Int) {
        self.morphologyCode = morphologyCode
        self.behaviorCode = behaviorCode
        
        super.init()
    }
}