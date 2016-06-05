import Foundation

//extension NSURLRequest {
//    func cURLString() -> String {
//        var retString = "curl -k --dump-header - --request \(HTTPMethod!)\n"
//        for (key, value) in allHTTPHeaderFields! {
//            retString.appendContentsOf(" -H \(key): \(value)\n")
//        }
//        
//        if let bodyDataString = String(data: HTTPBody!, encoding: NSUTF8StringEncoding) {
//            retString.appendContentsOf(" --data \(bodyDataString)")
//        }
//        
//        retString.appendContentsOf(" '\(URL!.absoluteString)'")
//        return retString
//    }
//}

struct CategoryAPIAdapter: APIAdapter {
    // MARK: - Nested types
    enum Error: ErrorType {
        case APIError(APIAdapterError)
        case ParserError(JSONParserError)
    }
    
    enum Result {
        case Success([Category])
        case Failure(Error)
    }
    
    
    // MARK: - Properties
    let parser: CategoryJSONParser
    private let baseURLString = "http://ihcapp.dev/categories"
    
    // MARK: - Initializer
    init(parser: CategoryJSONParser) {
        self.parser = parser
    }
    
    // MARK: - Methods
    func get(completionHandler: (Result) -> Void) {
        let url = NSURL(string: baseURLString)!
        let request = NSURLRequest(URL: url)
        
        let session: NSURLSession = {
            let config = NSURLSessionConfiguration.defaultSessionConfiguration()
            return NSURLSession(configuration: config)
        }()
        
        makeRequest(request, usingSession: session) {
            result in
            switch result {
            case let .Failure(apiError):
                completionHandler(.Failure(.APIError(apiError)))
            case let .Success(data):
                do {
                    let categories = try self.parser.parseData(data)
                    completionHandler(.Success(categories))
                } catch let error {
                    completionHandler(.Failure(.ParserError(error as! JSONParserError)))
                }
            }
        }
    }
    
    func create(name: String, parentCategoryId: Int, completionHandler: (Result) -> Void) {
        let session: NSURLSession = {
            let config = NSURLSessionConfiguration.defaultSessionConfiguration()
            config.HTTPAdditionalHeaders = [
                "Content-Type": "application/json",
                "Accept": "application/json"
            ]
            return NSURLSession(configuration: config)
        }()
        
        let url = NSURL(string: "\(baseURLString)/\(parentCategoryId)")!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        
        
        let dataDict: NSDictionary = ["name": name]
        let data: NSData = try! NSJSONSerialization.dataWithJSONObject(dataDict, options: [])
        request.HTTPBody = data
        makeRequest(request, usingSession: session) {
            result in
            switch result {
            case let .Failure(apiError):
                completionHandler(.Failure(.APIError(apiError)))
            case let .Success(data):
                do {
                    let categories = try self.parser.parseData(data)
                    completionHandler(.Success(categories))
                } catch let error {
                    completionHandler(.Failure(.ParserError(error as! JSONParserError)))
                }
            }
        }
    }
    
    func delete(categoryId: Int, completionHandler: (Result) -> Void) {
        let session: NSURLSession = {
            let config = NSURLSessionConfiguration.defaultSessionConfiguration()
            config.HTTPAdditionalHeaders = [
                "Content-Type": "application/json",
                "Accept": "application/json"
            ]
            return NSURLSession(configuration: config)
        }()
        
        let url = NSURL(string: "\(baseURLString)/\(categoryId)")!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "DELETE"
        
        makeRequest(request, usingSession: session) {
            result in
            switch result {
            case let .Failure(apiError):
                completionHandler(.Failure(.APIError(apiError)))
            case let .Success(data):
                do {
                    let categories = try self.parser.parseData(data)
                    completionHandler(.Success(categories))
                } catch let error {
                    completionHandler(.Failure(.ParserError(error as! JSONParserError)))
                }
            }
        }
    }
}