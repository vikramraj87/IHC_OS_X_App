import Foundation

/// API Adapter for Category API calls
class CategoryAPIAdapter: NSObject, APIAdapter {
    // MARK: - Properties
    let parser: CategoryJSONParser
    private let baseURLString = "http://ihcapp.dev/categories"
    
    let session: NSURLSession = {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        config.HTTPAdditionalHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        return NSURLSession(configuration: config)
    }()
    
    /// For Async Progress Indicator
    dynamic var numberOfLiveContacts = 0
    
    // MARK: - Initializer
    init(parser: CategoryJSONParser) {
        self.parser = parser
    }
    
    // MARK: - Methods
    func getAll(completionHandler: (AdapterResult<Category>) -> Void) {
        let url = NSURL(string: baseURLString)!
        let request = NSURLRequest(URL: url)
        
        makeRequest(request, withCompletionHandler: completionHandler)
    }
    
    func createCategoryWithName(name: String, parentCategoryId: Int, completionHandler: (AdapterResult<Category>) -> Void) {
        let url = NSURL(string: "\(baseURLString)/\(parentCategoryId)")!
        
        let request = NSMutableURLRequest(URL: url)
        
        request.HTTPMethod = "POST"
        
        let dataDict: NSDictionary = ["name": name]
        let data: NSData = try! NSJSONSerialization.dataWithJSONObject(dataDict, options: [])
        request.HTTPBody = data
        
        makeRequest(request, withCompletionHandler: completionHandler)
    }
    
    func moveCategoryWithId(categoryId: Int, underParentCategoryWithId parentId: Int, completionHandler: (AdapterResult<Category>) -> Void) {
        let url = NSURL(string: "\(baseURLString)/\(categoryId)/parent/\(parentId)")!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "PATCH"
        
        makeRequest(request, withCompletionHandler: completionHandler)
    }
    
    func deleteCategoryWithId(categoryId: Int, completionHandler: (AdapterResult<Category>) -> Void) {
        let url = NSURL(string: "\(baseURLString)/\(categoryId)")!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "DELETE"
        
        makeRequest(request, withCompletionHandler: completionHandler)
    }
    
    func renameCategoryWithId(categoryId: Int, withName name: String, completionHandler: (AdapterResult<Category>) -> Void) {
        let encodedName = name.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!
        let url = NSURL(string: "\(baseURLString)/\(categoryId)/name/\(encodedName)")!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "PATCH"
        
        
        makeRequest(request, withCompletionHandler: completionHandler)
    }
    
    // MARK: - Helpers
    
    /**
     Makes request to the server and calls the completion handler when responded.
     - Parameter request: NSURLRequest containing the URL, method, etc
     - Parameter handler: Completion hanlder that will be called when responded
     */
    private func makeRequest(request: NSURLRequest, withCompletionHandler handler: (AdapterResult<Category>) -> Void) {
        // Increase the count of live contacts
        numberOfLiveContacts += 1
        
        makeRequest(request, usingSession: session) {
            result in
            switch result {
            case let .Failure(apiError):
                handler(.Failure(.APIContactError(apiError)))
            case let .Success(data):
                do {
                    let categories = try self.parser.parseData(data)
                    handler(.Success(categories))
                } catch let error {
                    handler(.Failure(.ParserError(error as! JSONParserError)))
                }
            }
            
            // Decrease the count of live contacts
            if self.numberOfLiveContacts > 0 {
                self.numberOfLiveContacts -= 1
            }
        }
    }
}