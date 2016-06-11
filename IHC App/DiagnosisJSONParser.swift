import Foundation

struct DiagnosisJSONParser: JSONParser {
    /// Date formatter to parse the timestamps
    let dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    
    // MARK: - Conformance to JSONParser
    typealias ObjectType = Diagnosis
    
    func objectFromDictionary(dictionary: NSDictionary) -> Diagnosis? {
        return Diagnosis()
    }
}