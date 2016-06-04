import Foundation

enum JSONParserError: ErrorType {
    case InvalidJSON
    case NoDataKey
    case InvalidObjectData
}

protocol JSONParser {
    associatedtype ObjectType
    
    func parseData(data: NSData) throws -> [ObjectType]
    func objectFromDictionary(dictionary: NSDictionary) -> ObjectType?
}

extension JSONParser {
    func parseData(data: NSData) throws -> [ObjectType] {
        guard let topLevelDict = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? NSDictionary else {
            throw JSONParserError.InvalidJSON
        }
        
        guard let dataDict = topLevelDict["data"] as? [NSDictionary] else {
            throw JSONParserError.NoDataKey
        }
        
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