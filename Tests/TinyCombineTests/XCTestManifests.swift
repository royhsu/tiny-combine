import XCTest

#if !canImport(ObjectiveC)

public func allTests() -> [XCTestCaseEntry] {
    
    [
        testCase(FutureTests.allTests),
    ]
    
}

#endif
