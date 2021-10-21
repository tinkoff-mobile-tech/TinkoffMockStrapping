import Nimble
import SwiftyJSON
import TinkoffMockStrapping
import XCTest

class HappyPathTests: XCTestCase {

    // MARK: Private properties

    private var server: MockNetworkServer!
    private var port: UInt16!

    private var json: JSON {
        let jsonDictionary: [String: Any] = ["sender": "lupa@test.com", "recipients": "pupa@test.com"]
        let jsonData = try! JSONSerialization.data(withJSONObject: jsonDictionary, options: [])
        return JSON(jsonData)
    }

    private var json2: JSON {
        let jsonDictionary: [String: Any] = ["nkt": "kzntsv", "vs": "rdnvsk", "rm": "gldkh"]
        let jsonData = try! JSONSerialization.data(withJSONObject: jsonDictionary, options: [])
        return JSON(jsonData)
    }

    // MARK: SetUp & TearDown

    override func setUp() {
        super.setUp()
        server = MockNetworkServer()
        port = server.start()
    }

    // MARK: Tests

    func testStubsHistoryOneRequest() {
        let url = "test/url/1"
        let query = ["query1": "1", "query2": "2"]
        let excludedQuery = ["query3": "3"]
        let request = NetworkStubRequest(url: url,
                                         query: query,
                                         excludedQuery: excludedQuery,
                                         httpMethod: .GET)
        let response = NetworkStubResponse.json(json)
        let stub = NetworkStub(request: request, response: response)
        server.setStub(stub)
        makeRequest(to: "\(url)?query1=1&query2=2")

        expect(self.server.requestsHistory.count).to(equal(1))
        expect(self.server.history.count).to(equal(1))
        expect(self.server.requestsHistory[0].url).to(contain(url))
        expect(self.server.requestsHistory[0].query).to(equal(query))
        expect(self.server.history[0].request.httpMethod).to(equal(NetworkStubMethod.GET))
    }

    func testStubsHistoryTwoRequestsWithTheSameUrl() {
        let url = "test/url/1"
        let query = ["query1": "1", "query2": "2"]
        let excludedQuery = ["query3": "3"]
        let requestGet = NetworkStubRequest(url: url,
                                            query: query,
                                            excludedQuery: excludedQuery,
                                            httpMethod: .GET)
        let responseGet = NetworkStubResponse.json(json)
        server.setStub(NetworkStub(request: requestGet, response: responseGet))

        let requestPost = NetworkStubRequest(url: url,
                                             httpMethod: .POST)
        let responsePost = NetworkStubResponse.json(json2)
        server.setStub(NetworkStub(request: requestPost, response: responsePost))
        makeRequest(to: "\(url)?query1=1&query2=2")
        makeRequest(to: "\(url)", method: "POST")
        expect(self.server.requestsHistory.count).to(equal(2))
        expect(self.server.history.count).to(equal(2))
        expect(self.server.history[0].request.httpMethod).to(equal(NetworkStubMethod.GET))
        expect(self.server.history[1].request.httpMethod).to(equal(NetworkStubMethod.POST))

        let actualResponseGet = server.history[0].response
        if case let .json(actualResponse) = actualResponseGet {
            expect(actualResponse).to(equal(json))
        }
        let actualResponsePost = server.history[1].response
        if case let .json(actualResponse) = actualResponsePost {
            expect(actualResponse).to(equal(json2))
        }
    }

    // MARK: Private funcs

    private func makeRequest(to address: String, method: String = "GET") {
        let url = URL(string: "http://localhost:\(port!)/\(address)")!
        var request = URLRequest(url: url)
        request.httpMethod = method
        let task = URLSession.shared.dataTask(with: request) { data, response, _ in
            guard
                let data = data,
                let response = response as? HTTPURLResponse
            else {
                return
            }
            print(data)
            print("response: \(response)")
        }

        task.resume()
        sleep(1)
    }
}
