import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(Flat47PuzzleGameTests.allTests),
    ]
}
#endif
