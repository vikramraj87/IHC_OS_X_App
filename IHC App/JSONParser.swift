import Foundation

/**
    Errors of JSONParser.
 
     - InvalidJSON: JSON Deserialization failed.
     - NoDataKey: JSON does not contain any data key.
     - InvalidObjectData: Object cannot be created from JSON.
 */
enum JSONParserError: ErrorType {
    case InvalidJSON
    case NoDataKey
    case InvalidObjectData
}

protocol JSONParser {
    /// The object type that will be converted from JSON data.
    associatedtype ObjectType
    
    /**
         Parses JSON data to the object mentioned in the ObjectType.
         
         - Parameter data: JSON data required to create object.
         - Throws: `JSONParserError` if the JSON cannot be parsed.
         - Returns: An array of objects of type defined by `ObjectType` from data.
     */
    func parseData(data: NSData) throws -> [ObjectType]
    
    /**
        Creates an object of type defined by `ObjectType` from NSDictionary.
     
         - Parameter dictionary: NSDictionary containing the data.
         - Returns: object if successly parsed, else nil
     */
    func objectFromDictionary(dictionary: NSDictionary) -> ObjectType?
}

extension JSONParser {
    
    func parseData(data: NSData) throws -> [ObjectType] {
        // Deserialize the JSON
        guard let topLevelDict = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? NSDictionary else {
            throw JSONParserError.InvalidJSON
        }
        
        // Get the data dictionary
        guard let dataDict = topLevelDict["data"] as? [NSDictionary] else {
            throw JSONParserError.NoDataKey
        }
        
        // Parse object and add to the array
        var objects: [ObjectType] = []
        for objectDict in dataDict {
            guard let object = objectFromDictionary(objectDict) else {
                throw JSONParserError.InvalidObjectData
            }
            objects.append(object)
        }
        
        return objects
    }
}