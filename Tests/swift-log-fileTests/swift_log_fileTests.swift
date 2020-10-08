import XCTest
@testable import FileLogging
@testable import Logging

enum TestError: Error {
    case noDocumentDirectory
    case cannotGetFileSize
}

final class swift_log_fileTests: XCTestCase {
    let logFileName = "LogFile.txt"
    
    func testLogToFileUsingBootstrap() throws {
        let logFileURL = try getDocumentsDirectory().appendingPathComponent(logFileName)
        print("\(logFileURL)")
        let fileLogger = try FileLogging(to: logFileURL)
        // Using `bootstrapInternal` so that running `swift test` won't fail. If using this in production code, just use `bootstrap`.
        LoggingSystem.bootstrapInternal(fileLogger.handler)

        let logger = Logger(label: "Test")
        
        // Not really an error.
        logger.error("Test Test Test")
    }
    
    func testLogToFileAppendsAcrossLoggerCalls() throws {
        let logFileURL = try getDocumentsDirectory().appendingPathComponent(logFileName)
        print("\(logFileURL)")
        let fileLogger = try FileLogging(to: logFileURL)
        // Using `bootstrapInternal` so that running `swift test` won't fail. If using this in production code, just use `bootstrap`.
        LoggingSystem.bootstrapInternal(fileLogger.handler)
        let logger = Logger(label: "Test")
        
        // Not really an error.
        logger.error("Test Test Test")
        let fileSize1 = try getFileSize(file: logFileURL)

        logger.error("Test Test Test")
        let fileSize2 = try getFileSize(file: logFileURL)
        
        XCTAssert(fileSize2 > fileSize1)
    }
    
    func testLogToFileAppendsAcrossConstructorCalls() throws {
        let logFileURL = try getDocumentsDirectory().appendingPathComponent(logFileName)
        print("\(logFileURL)")
        let fileLogger = try FileLogging(to: logFileURL)

        let logger1 = Logger(label: "Test", factory: fileLogger.handler)
        logger1.error("Test Test Test")
        let fileSize1 = try getFileSize(file: logFileURL)
        
        let logger2 = Logger(label: "Test", factory: fileLogger.handler)
        logger2.error("Test Test Test")
        let fileSize2 = try getFileSize(file: logFileURL)
        
        XCTAssert(fileSize2 > fileSize1)
    }
    
    // Adapted from https://nshipster.com/swift-log/
    func testLogToBothFileAndConsole() throws {
        let logFileURL = try getDocumentsDirectory().appendingPathComponent(logFileName)
        let fileLogger = try FileLogging(to: logFileURL)

        LoggingSystem.bootstrap { label in
            let handlers:[LogHandler] = [
                FileLogHandler(label: label, fileLogger: fileLogger),
                StreamLogHandler.standardOutput(label: label)
            ]

            return MultiplexLogHandler(handlers)
        }
        
        let logger = Logger(label: "Test")
        
        // TODO: Manually check that the output also shows up in the Xcode console.
        logger.error("Test Test Test")
    }
    
    func testLoggingUsingLoggerFactoryConstructor() throws {
        let logFileURL = try getDocumentsDirectory().appendingPathComponent(logFileName)
        let fileLogger = try FileLogging(to: logFileURL)

        let logger = Logger(label: "Test", factory: fileLogger.handler)
        
        logger.error("Test Test Test")
        let fileSize1 = try getFileSize(file: logFileURL)
        
        logger.error("Test Test Test")
        let fileSize2 = try getFileSize(file: logFileURL)
        
        XCTAssert(fileSize2 > fileSize1)
    }
    
    func testLoggingUsingConvenienceMethod() throws {
        let logFileURL = try getDocumentsDirectory().appendingPathComponent(logFileName)

        let logger = try FileLogging.logger(label: "Foobar", localFile: logFileURL)
        
        logger.error("Test Test Test")
        let fileSize1 = try getFileSize(file: logFileURL)
        
        logger.error("Test Test Test")
        let fileSize2 = try getFileSize(file: logFileURL)
        
        XCTAssert(fileSize2 > fileSize1)
    }
    
    // MARK: Helpers
    
    func getDocumentsDirectory() throws -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        guard paths.count > 0 else {
            throw TestError.noDocumentDirectory
        }
        
        return paths[0]
    }
    
    func getFileSize(file: URL) throws -> UInt64 {
        let attr = try FileManager.default.attributesOfItem(atPath: file.path)
        guard let fileSize = attr[FileAttributeKey.size] as? UInt64 else {
            throw TestError.noDocumentDirectory
        }

        return fileSize
    }
}
