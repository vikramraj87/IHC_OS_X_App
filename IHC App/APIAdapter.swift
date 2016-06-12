import Foundation

/**
    Error thrown by the generic make request method in protocol extension. 
    Used to indicate failure in contacting server.
    - RequestError: No data sent from the server.
    - InvalidResponse: No response object.
    - BadStatusCode: Status codes indicating error like 404, 500.
 */
enum APIError: ErrorType {
    case RequestError
    case InvalidResponse
    case BadStatusCode(Int)
}

/**
    Result as NSData returned from the server if the request is success
    - Success: Data returned.
    - Failure: Request failed.
 */
enum APIDataResult {
    case Success(NSData)
    case Failure(APIError)
}

/**
    Error returned by the adapter conforming to APIAdapter.
    - APIContactError: Error in contacting the server
    - ParserError: Error in parsing NSData to Corresponding Object
 */
enum AdapterError: ErrorType {
    case APIContactError(APIError)
    case ParserError(JSONParserError)
}

/**
    Result returned from the adapter conforming to APIAdapter
    - Success: Request and Parsing successful
    - Failure: Failure during contacting the server or parsing the data, indicated by `AdapterError`
 */
enum AdapterResult<T> {
    case Success([T])
    case Failure(AdapterError)
}

// API Adapter Protocol
protocol APIAdapter {
    /**
         Make request to the server and call the completion handler after receiving response from the server
         - Parameter request: `NSURLRequest` containing the URL, method, etc.
         - Parameter session: `NSURLSession` used to make the request
         - Parameter completionHandler: Block to call after the async request is responded
     */
    func makeRequest(request: NSURLRequest, usingSession session: NSURLSession, completionHandler: APIDataResult -> Void)
}

extension APIAdapter {
    func makeRequest(request: NSURLRequest, usingSession session: NSURLSession, completionHandler: APIDataResult -> Void) {
        session.dataTaskWithRequest(request, completionHandler: {
            data, response, error in
            func callCompletionHandlerWithResult(result: APIDataResult) {
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    completionHandler(result)
                }
            }
            
            guard data != nil else {
                callCompletionHandlerWithResult(.Failure(.RequestError))
                return
            }
            
            guard let res = response as? NSHTTPURLResponse else {
                callCompletionHandlerWithResult(.Failure(.InvalidResponse))
                return
            }
            
            guard res.statusCode == 200 || res.statusCode == 201 else {
                callCompletionHandlerWithResult(.Failure(.BadStatusCode(res.statusCode)))
                return
            }
            
            callCompletionHandlerWithResult(.Success(data!))
        }).resume()
    }
}