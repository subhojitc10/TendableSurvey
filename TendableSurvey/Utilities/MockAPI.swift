//
//  MockAPI.swift
//  TendableSurvey
//
//  Created by Subhojit Chatterjee on 19/08/24.
//

import Foundation
import Alamofire

class MockURLProtocol: URLProtocol {
    static var mockData: Data?
    static var responseStatusCode: Int = 200
    static var mockError: Error?

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        if let mockError = MockURLProtocol.mockError {
            self.client?.urlProtocol(self, didFailWithError: mockError)
        } else {
            let response = HTTPURLResponse(url: request.url!,
                                           statusCode: MockURLProtocol.responseStatusCode,
                                           httpVersion: nil,
                                           headerFields: nil)!
            self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)

            if let mockData = MockURLProtocol.mockData {
                self.client?.urlProtocol(self, didLoad: mockData)
            }

            self.client?.urlProtocolDidFinishLoading(self)
        }
    }

    override func stopLoading() {}
}


class MockNetworkService: TendableAPI {
    override init(session: Session = Session.default) {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let mockSession = Session(configuration: configuration)
        super.init(session: mockSession)
    }
}
