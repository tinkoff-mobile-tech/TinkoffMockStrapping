# TinkoffMockStrapping

[![Version](https://img.shields.io/cocoapods/v/TinkoffMockStrapping.svg?style=flat)](https://cocoapods.org/pods/TinkoffMockStrapping)
[![License](https://img.shields.io/cocoapods/l/TinkoffMockStrapping.svg?style=flat)](https://cocoapods.org/pods/TinkoffMockStrapping)
[![Platform](https://img.shields.io/cocoapods/p/TinkoffMockStrapping.svg?style=flat)](https://cocoapods.org/pods/TinkoffMockStrapping)

## How to install?

TinkoffMockStrapping is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'TinkoffMockStrapping', :git => 'https://github.com/tinkoff-mobile-tech/TinkoffMockStrapping.git'
```

If you want to use TinkoffMockStrapping with [Swifter](https://github.com/httpswift/swifter), add the following line to your Podfile:

```ruby
pod 'TinkoffMockStrapping/Swifter', :git => 'https://github.com/tinkoff-mobile-tech/TinkoffMockStrapping.git'
```

## How to init the server?

```swift
lazy var mockServer = MockNetworkServer()
```

## How to init the request?

```swift
let stubRequest = NetworkStubRequest(url: "someUrlAsString", httpMethod: .GET)
```

```GET``` method is written above as an examle. We support all http methods, and you can use any of them. You can see them [here](https://github.com/tinkoff-mobile-tech/TinkoffMockStrapping/blob/main/Development/Source/Core/NetworkStubMethod.swift).
```ANY``` is a default parameter and means that method doesn't matter for you.

## How to init the response?

```swift
let stubResponse = NetworkStubResponse.json(json)
```
We use [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON), so ```json``` from the example above is an instance of ```JSON```. 

If you need to create a response with pdf, png etc, simply use ```data``` [case instead](https://github.com/tinkoff-mobile-tech/TinkoffMockStrapping/blob/main/Development/Source/Core/NetworkStubResponse.swift).

## How to init the stub?

```swift
let stub = NetworkStub(request: stubRequest, response: stubResponse)
mockServer.setStub(stub)
```

## Query? Sure

```swift
let query = ["query1": "1", "query2": "2"]
let stubRequest = NetworkStubRequest(url: "someUrlAsString",
                                     query: query,
                                     httpMethod: .GET)
```

Also we provide `excludedQuery`. If you don't want to see some parameters in your request, use this option.

## History

If you want to know which requests were called, you can use `history`.
Simply use functions from [MockNetworkHistoryProtocol](https://github.com/tinkoff-mobile-tech/TinkoffMockStrapping/blob/main/Development/Source/Core/Protocols/MockNetworkHistoryProtocol.swift)

## Authors
* RomanGL, r.gladkikh@tinkoff.ru,
* volokhin, volokhin@bk.ru,
* niceta, n.kuznetsov@tinkoff.ru 
* ra2ra, v.rudnevskiy@tinkoff.ru

## License

TinkoffMockStrapping is available under the Apache License 2.0. See the LICENSE file for more info.
