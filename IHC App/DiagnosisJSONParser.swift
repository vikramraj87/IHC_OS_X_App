import Foundation

struct DiagnosisJSONParser {
    /// Date formatter to parse the timestamps
    let dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    
    // MARK: - Conformance to JSONParser
//    typealias ObjectType = Diagnosis
    
//    func objectFromDictionary(dictionary: NSDictionary) -> Diagnosis? {
//        return Diagnosis(id: nil, name: "", category: Category(), createdAt: nil, updatedAt: nil)
//    }
}