import Foundation

class CategoryAPI {
    // MARK: - Nested types
    enum CategoriesAPIError: ErrorType {
        case BadStatusCode(Int)
        case JSONParserError
        case UnexpectedResponse
        case RequestError(NSError)
    }
    
    enum AllCategoriesResult {
        case Success([Category])
        case Failure(CategoriesAPIError)
    }

    // MARK: - Singleton pattern
    // Shared Instance for singleton
    static let sharedInstance = CategoryAPI()
    
    // Private init to prevent more than one instance
    private init() {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        defaultSession = NSURLSession(configuration: config)
    }

    // MARK: - Private properties
    private let baseURLString = "http://ihcapp.dev/categories"
    private let defaultSession: NSURLSession
    private let dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    // MARK: - Methods
    func allCategories(completionHandler: AllCategoriesResult -> Void) {
        // Create NSURLRequest with the base URL
        let request: NSURLRequest = {
            let url = NSURL(string: baseURLString)!
            return NSURLRequest(URL: url)
        }()
        
        let dataTask = defaultSession.dataTaskWithRequest(request) {
            data, response, error in
            var result: AllCategoriesResult
            
            if data == nil {
                result = .Failure(.RequestError(error!))
            }
            else if let response = response as? NSHTTPURLResponse {
                if response.statusCode == 200 {
                    let parser = CategoryJSONParser()
                    if let categories = try? parser.parseData(data!) {
                        result = .Success(categories)
                    }
                    else {
                        result = .Failure(.JSONParserError)
                    }
                }
                else {
                    result = .Failure(.BadStatusCode(response.statusCode))
                }
            }
            else {
                result = .Failure(.UnexpectedResponse)
            }
            
            // Call the completion handler in main queue
            // So that updates to the UI can be handled
            // in the completion handler
            NSOperationQueue.mainQueue().addOperationWithBlock {
                completionHandler(result)
            }
        }
        dataTask.resume()
    }
}