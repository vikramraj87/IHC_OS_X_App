import Foundation

struct ICDOCode {
    /// Corresponds to morphology of the tumor
    var morphologyCode: Int
    
    /// Corresponds to behaviour of the tumor
    /// 0: Benign neoplasms
    /// 1: Neoplasms of uncertain behavior
    /// 2: In situ neoplasms
    /// 3: Malognant neoplasms, primary
    /// 6: Malignant neoplasms, secondary
    var behaviorCode: Int
}