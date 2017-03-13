import Foundation
#if os(Linux)
    import Dispatch
#endif

public extension URLSession {
    
    /// Perform a URL request synchronously, whereby the function will return either once the task has completed 
    /// or an error has occured.
    ///
    /// - Note: The data task will timeout after the duration specified in the `URLRequest`.
    ///
    /// - Important: If you are making an HTTP or HTTPS request, the returned `URLResponse` object is actually an `HTTPURLResponse` object.
    ///
    /// - Parameter request: The` URLRequest` object that provides the `URL`, cache policy, request type, body data or body stream, and so on.
    /// - Returns: An object that provides response metadata, such as HTTP headers and status code, and the data returned by the server.
    /// - Throws: An error object that indicates why the request failed, for example time out or network connection issue.
    public func syncDataTask(with request: URLRequest) throws -> (URLResponse?, Data?) {
        var data: Data?
        var response: URLResponse?
        var error: Error?
        
        // We use a sempahore to force synchornisation
        let semaphore = DispatchSemaphore(value: 0)
        
        let task = self.dataTask(with: request) { (asyncData, asyncReponse, asyncError) in
            data = asyncData
            response = asyncReponse
            error = asyncError
            
            semaphore.signal()
        }
        task.resume()
        
        let waitTime = DispatchTime.now() + .nanoseconds(Int(request.timeoutInterval * Double(NSEC_PER_SEC)))
        let wait = semaphore.wait(timeout: waitTime)
        
        guard wait != .timedOut else {
            throw URLError(.timedOut)
        }
        
        if let error = error {
            throw error
        }
        
        return (response, data)
    }
    
}
