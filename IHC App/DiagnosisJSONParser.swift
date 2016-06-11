import Foundation

/// Parses JSON data to Diagnosis
struct DiagnosisJSONParser {
    /// Date formatter to parse the timestamps
    let dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    /// ICD-O Code Formatter
    let icdoCodeFormatter = ICDOCodeFormatter()
    
    // MARK: - Conformance to JSONParser
    typealias ObjectType = Diagnosis
    
    func objectFromDictionary(dictionary: NSDictionary) -> Diagnosis? {
        return diagnosisFromDictionary(dictionary)
    }
    
    // MARK: - Helpers
    
    /**
        Creates Diagnosis object from NSDictionary
     
        - Parameter diagnosisDict: NSDictionary containing the data
        - Returns: `Diagnosis` if successful, else `nil`
     */
    private func diagnosisFromDictionary(diagnosisDict: NSDictionary) -> Diagnosis? {
        // Check whether the dictionary contains all the keys
        guard let id = diagnosisDict["id"] as? Int,
            let name = diagnosisDict["name"] as? String,
            let icdoCodeString = diagnosisDict["icdo_code"] as? String,
            let categoryId = diagnosisDict["category_id"] as? Int,
            let createdAtString = diagnosisDict["created_at"] as? String,
            let updatedAtString = diagnosisDict["updated_at"] as? String,
            let icdoCode = icdoCodeFormatter.icdoCodeFromString(icdoCodeString),
            let createdAt = dateFormatter.dateFromString(createdAtString),
            let updatedAt = dateFormatter.dateFromString(updatedAtString)
            else {
                return nil
        }
        
        return Diagnosis(id: id, name: name, icdoCode: icdoCode, categoryId: categoryId, createdAt: createdAt, updatedAt: updatedAt)
    }
}