import Foundation

enum APIAdapterError: ErrorType {
    case RequestError
    case InvalidResponse
    case BadStatusCode(Int)
}

enum APIAdapterResult {
    case Success(NSData)
    case Failure(APIAdapterError)
}

protocol APIAdapter {
    func makeRequest(request: NSURLRequest, usingSession session: NSURLSession, completionHandler: APIAdapterResult -> Void)
}

extension APIAdapter {
    func makeRequest(request: NSURLRequest, usingSession session: NSURLSession, completionHandler: APIAdapterResult -> Void) {
        session.dataTaskWithRequest(request, completionHandler: {
            data, response, error in
            func callCompletionHandlerWithResult(result: APIAdapterResult) {
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