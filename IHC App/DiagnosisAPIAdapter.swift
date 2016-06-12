import Cocoa

/// API Adapter for Diagnosis API calls
class DiagnosisAPIAdapter: NSObject, APIAdapter {
    // MARK: - Properties
    
    /// Parser to parse NSDictionary to Diagnosis object
    let parser: DiagnosisJSONParser
    
    /// NSURLSession used to make request
    let session: NSURLSession = {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        config.HTTPAdditionalHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        return NSURLSession(configuration: config)
    }()
    
    /// Number of live contacts to server
    dynamic var numberOfLiveContacts = 0
    
    // MARK: Initializer
    init(parser: DiagnosisJSONParser) {
        self.parser = parser
    }
    
    // MARK: Methods
    
    /**
         Get all the diagnoses from API and call the completion handler with the diagnoses incorporated into the result and passed as parameter if successful else error is passed in the result
         - Parameter completionHandler: Block to call once the response is received
     */
    func getAll(completionHandler: (AdapterResult<Diagnosis>) -> Void) {
        let url = NSURL(string: "http://ihcapp.dev/diagnoses")!
        let request = NSURLRequest(URL: url)
        
        makeRequest(request, withCompletionHandler: completionHandler)
    }
    
    // MARK: Helpers
    
    /**
         Makes request to the server and calls the completion handler when responded.
         - Parameter request: NSURLRequest containing the URL, method, etc
         - Parameter handler: Completion hanlder that will be called when responded
     */
    private func makeRequest(request: NSURLRequest, withCompletionHandler handler: (AdapterResult<Diagnosis>) -> Void) {
        // Increase the count of live contacts
        numberOfLiveContacts += 1
        
        makeRequest(request, usingSession: session) {
            result in
            switch result {
            case let .Failure(apiError):
                handler(.Failure(.APIContactError(apiError)))
            case let .Success(data):
                do {
                    let diagnoses = try self.parser.parseData(data)
                    handler(.Success(diagnoses))
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
