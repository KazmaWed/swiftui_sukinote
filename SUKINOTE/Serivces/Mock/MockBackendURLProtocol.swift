import Foundation

// NOTE: Stands in for the backend (to be built later) by handling requests to baseURL inside the app.
// URLSession drives each instance on its own thread and the instance holds no mutable state, so it is marked @unchecked Sendable.
nonisolated final class MockBackendURLProtocol: URLProtocol, @unchecked Sendable {

    static let baseURL = URL(string: "https://mock-backend.local")!

    static func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockBackendURLProtocol.self]
        // NOTE: Analyzing a long chat history can take longer than the default 60 seconds
        configuration.timeoutIntervalForRequest = 300
        return URLSession(configuration: configuration)
    }

    override class func canInit(with request: URLRequest) -> Bool {
        request.url?.host() == baseURL.host()
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        Task { [self] in
            let (statusCode, body) = await Self.response(for: request)

            guard let url = request.url,
                  let response = HTTPURLResponse(
                      url: url,
                      statusCode: statusCode,
                      httpVersion: "HTTP/1.1",
                      headerFields: ["Content-Type": "application/json"]
                  ) else {
                client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
                return
            }
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: body)
            client?.urlProtocolDidFinishLoading(self)
        }
    }

    override func stopLoading() {}
}

nonisolated private extension MockBackendURLProtocol {

    static func response(for request: URLRequest) async -> (statusCode: Int, body: Data) {
        switch (request.httpMethod, request.url?.path()) {
        case ("POST", "/analyze-talk"):
            return await MockBackendAnalyzeTalkHandler.handle(requestBody: readBody(of: request))
        default:
            return (404, Data(#"{"error": "Not Found"}"#.utf8))
        }
    }

    // NOTE: URLSession passes the body to URLProtocol as a stream instead of httpBody
    static func readBody(of request: URLRequest) -> Data {
        if let body = request.httpBody { return body }
        guard let stream = request.httpBodyStream else { return Data() }

        var body = Data()
        let bufferSize = 4096
        var buffer = [UInt8](repeating: 0, count: bufferSize)
        stream.open()
        defer { stream.close() }
        while stream.hasBytesAvailable {
            let count = stream.read(&buffer, maxLength: bufferSize)
            guard count > 0 else { break }
            body.append(buffer, count: count)
        }
        return body
    }
}
