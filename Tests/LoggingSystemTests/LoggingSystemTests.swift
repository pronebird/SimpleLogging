import XCTest
@testable import LoggingSystem

final class LoggingSystemTests: XCTestCase {
    
    func testExample() throws {
        var loggingSystem = LoggingSystem()
        let fileLogURL = FileManager.default.temporaryDirectory.appending(component: "testlog.txt")
        
        loggingSystem.addOutput(ConsoleOutput())
        
        if let fileOutput = FileOutput(fileURL: fileLogURL) {
            loggingSystem.addOutput(fileOutput)
        } else {
            print("Couldn't create the file output to \(fileLogURL.path)")
        }
        
        let subsystem = loggingSystem.makeSubsystem(label: "LoggingSystemTests")
            
        subsystem.log("Hello world!")
    }
    
    func testOutputsWork() {
        let expectation = self.expectation(description: "Wait for output to happen.")
        var loggingSystem = LoggingSystem()
        loggingSystem.addOutput(TestOutput(onWrite: {
            expectation.fulfill()
        }))
        let subsystem = loggingSystem.makeSubsystem(label: "LoggingSystemTests")
        
        subsystem.log("Hello world!")
        
        wait(for: [expectation])
    }
    
}

struct TestOutput: LogOutput {
    var onWrite: (() -> Void)?
    func write(_ message: String) {
        onWrite?()
    }
}
