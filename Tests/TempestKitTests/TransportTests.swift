//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation
import Testing

@testable import TempestKit

struct TransportTests {

    @Test("A network error doesn't keep the token URL")
    func networkError() throws {
        let url = try #require(
            URL(string: "https://swd.weatherflow.com/swd/rest/stations?token=secret")
        )
        let error = URLError(.timedOut, userInfo: [
            NSURLErrorFailingURLErrorKey: url,
            "NSURLErrorFailingURLStringErrorKey": url.absoluteString,
        ])

        guard case .network(let urlError) = URLSessionTransport.networkError(error) else {
            Issue.record("Expected a network error")
            return
        }
        #expect(urlError.userInfo[NSURLErrorFailingURLErrorKey] == nil)
        #expect(urlError.userInfo["NSURLErrorFailingURLStringErrorKey"] == nil)
    }
}
