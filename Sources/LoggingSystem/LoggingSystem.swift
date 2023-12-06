
//
// Requirements:
//  - multiple outputs (console, file)
//  - timestamp
//  - messages
//

import Foundation

protocol LogOutput {
    func write(_ message: String)
}

protocol LoggingSystemProtocol {
    func addOutput(_ output: LogOutput)
    func makeSubsystem(label: String) -> SubsystemProtocol
}

protocol SubsystemProtocol {
    func log(_ message: String)
}

struct LoggingSystem {
    private var outputs: [LogOutput] = []
    
    init() {}

    mutating func addOutput(_ output: LogOutput) {
        outputs.append(output)
    }
    
    func makeSubsystem(label: String) -> SubsystemProtocol {
        Subsystem(label: label, output: MultiplexLogOutput(outputs: outputs))
    }
}

private struct Subsystem: SubsystemProtocol {
    let label: String
    let output: LogOutput
    
    func log(_ message: String) {
        output.write("[\(label)] \(message)")
    }
}

struct ConsoleOutput: LogOutput {
    func write(_ message: String) {
        print("\(message)")
    }
}

struct FileOutput: LogOutput {
    private var fileHandle: FileHandle
    
    init?(fileURL: URL) {
        _ = FileManager.default.createFile(atPath: fileURL.path, contents: nil)
        guard let fileHandle = try? FileHandle(forWritingTo: fileURL) else { return nil }
        
        self.fileHandle = fileHandle
    }
    
    func write(_ message: String) {
        let data = Data(message.utf8)
        try? fileHandle.write(contentsOf: data)
    }
}

struct MultiplexLogOutput: LogOutput {
    let outputs: [LogOutput]
    
    func write(_ message: String) {
        let outputMessage = "\(makeTimestamp()) \(message)\n"
        for output in outputs {
            output.write(outputMessage)
        }
    }
    
    private func makeTimestamp() -> String {
        let dateFormatter = ISO8601DateFormatter()
        return dateFormatter.string(from: Date())
    }
}
