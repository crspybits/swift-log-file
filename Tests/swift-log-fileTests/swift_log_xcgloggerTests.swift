//
//  swift_log_xcgloggerTests.swift
//  swift-log-fileTests
//
//  Created by Christopher G Prince on 2/6/21.
//

import XCTest
@testable import FileLogging
@testable import Logging
import XCGLogger

class swift_log_xcgloggerTests: XCTestCase, Utilities {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    let logFileName = "LogFile.txt"
    
    func testLogToFileUsingBootstrap() throws {
        let logFileURL = try getDocumentsDirectory().appendingPathComponent(logFileName)
        print("\(logFileURL)")
        
        let xcgLogger = makeFileXCGLogger(logFileURL: logFileURL)
        let fileLogger = XCGLogging(logger: xcgLogger)

        // Using `bootstrapInternal` so that running `swift test` won't fail. If using this in production code, just use `bootstrap`.
        LoggingSystem.bootstrapInternal(fileLogger.handler)

        let logger = Logger(label: "Test")

        logger.error("Test Test Test")
    }
    
    func testLogToFileAppendsAcrossLoggerCalls() throws {
        let logFileURL = try getDocumentsDirectory().appendingPathComponent(logFileName)
        print("\(logFileURL)")
        
        let xcgLogger = makeFileXCGLogger(logFileURL: logFileURL)
        let fileLogger = XCGLogging(logger: xcgLogger)
        
        // Using `bootstrapInternal` so that running `swift test` won't fail. If using this in production code, just use `bootstrap`.
        LoggingSystem.bootstrapInternal(fileLogger.handler)
        let logger = Logger(label: "Test")
        
        // Not really an error.
        logger.error("Test Test Test")
        let fileSize1 = try getFileSize(file: logFileURL)

        logger.error("Test Test Test")
        let fileSize2 = try getFileSize(file: logFileURL)
        
        XCTAssert(fileSize2 > fileSize1)
        try? FileManager.default.removeItem(at: logFileURL)
    }
    
    func testLogToFileAppendsAcrossConstructorCalls() throws {
        let logFileURL = try getDocumentsDirectory().appendingPathComponent(logFileName)
        print("\(logFileURL)")
        
        let xcgLogger = makeFileXCGLogger(logFileURL: logFileURL)
        let fileLogger = XCGLogging(logger: xcgLogger)

        let logger1 = Logger(label: "Test", factory: fileLogger.handler)
        logger1.error("Test Test Test")
        let fileSize1 = try getFileSize(file: logFileURL)
        
        let logger2 = Logger(label: "Test", factory: fileLogger.handler)
        logger2.error("Test Test Test")
        let fileSize2 = try getFileSize(file: logFileURL)
        
        XCTAssert(fileSize2 > fileSize1)
        try? FileManager.default.removeItem(at: logFileURL)
    }
    
    func testLogToBothFileAndConsole() throws {
        let logFileURL = try getDocumentsDirectory().appendingPathComponent(logFileName)
        let xcgLogger = makeFileXCGLogger(logFileURL: logFileURL)

        LoggingSystem.bootstrap { label in
            let handlers:[LogHandler] = [
                XCGLoggerHandler(label: label, logger: xcgLogger),
                StreamLogHandler.standardOutput(label: label)
            ]

            return MultiplexLogHandler(handlers)
        }
        
        let logger = Logger(label: "Test")
        
        // TODO: Manually check that the output also shows up in the Xcode console.
        logger.error("Test Test Test Boogba")
        try? FileManager.default.removeItem(at: logFileURL)
    }
    
    func testLoggingUsingLoggerFactoryConstructor() throws {
        let logFileURL = try getDocumentsDirectory().appendingPathComponent(logFileName)

        let xcgLogger = makeFileXCGLogger(logFileURL: logFileURL)
        let fileLogger = XCGLogging(logger: xcgLogger)
        
        let logger = Logger(label: "Test", factory: fileLogger.handler)
        
        logger.error("Test Test Test")
        let fileSize1 = try getFileSize(file: logFileURL)
        
        logger.error("Test Test Test")
        let fileSize2 = try getFileSize(file: logFileURL)
        
        XCTAssert(fileSize2 > fileSize1)
        try? FileManager.default.removeItem(at: logFileURL)
    }
    
    func testLoggingUsingConvenienceMethod() throws {
        let logFileURL = try getDocumentsDirectory().appendingPathComponent(logFileName)

        let xcgLogger = makeFileXCGLogger(logFileURL: logFileURL)
        let logger = XCGLogging.logger(label: "Test", logger: xcgLogger)
        
        logger.error("Test Test Test")
        let fileSize1 = try getFileSize(file: logFileURL)
        
        logger.error("Test Test Test")
        let fileSize2 = try getFileSize(file: logFileURL)
        
        XCTAssert(fileSize2 > fileSize1)
        try? FileManager.default.removeItem(at: logFileURL)
    }
    
    // MARK: Helpers
    
    func makeFileXCGLogger(logFileURL: URL, level: XCGLogger.Level = .verbose) -> XCGLogger {
        // Create a logger object with no destinations
        let log = XCGLogger(identifier: "advancedLogger", includeDefaultDestinations: false)
        
        // Create a file log destination
        let fileDestination = AutoRotatingFileDestination(writeToFile: logFileURL.path, identifier: "advancedLogger.fileDestination", shouldAppend: true)
        
        // Optionally set some configuration options
        fileDestination.outputLevel = level
        fileDestination.showLogIdentifier = false
        fileDestination.showFunctionName = true
        fileDestination.showThreadName = true
        fileDestination.showLevel = true
        fileDestination.showFileName = true
        fileDestination.showLineNumber = true
        fileDestination.showDate = true
        
        // Trying to get max total log size that could be sent to developer to be around 1MByte; this comprises one current log file and two archived log files.
        fileDestination.targetMaxFileSize = (1024 * 1024) / 3 // 1/3 MByte
        
        // These are archived log files.
        fileDestination.targetMaxLogFiles = 2

        // Process this destination in the background
        fileDestination.logQueue = XCGLogger.logQueue

        // Add the destination to the logger
        log.add(destination: fileDestination)

        // Add basic app info, version info etc, to the start of the logs
        log.logAppDetails()
        return log
    }
}
