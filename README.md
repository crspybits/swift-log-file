# swift-log-file

[SwiftLog](https://github.com/apple/swift-log) compatible file log handler.

## Example: Just logging to a file

```swift
let logFileURL = URL(/* your local log file here */)
let logger = try FileLogging.logger(label: "Foobar", localFile: logFileURL)
logger.error("Test Test Test")
```

## Example: Logging to both the standard output (Xcode console if using Xcode) and a file.

```swift
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
```

Note in that last example, if you use `LoggingSystem.bootstrap`, make sure to create your `Logger` *after* the  `LoggingSystem.bootstrap` usage (or you won't get the effects of the `LoggingSystem.bootstrap`).

## Example: Using XCGLogger

[XCGLogger](https://github.com/DaveWoodCom/XCGLogger.git) supports rotating file logs amongst other features.

```swift
let logFileURL = URL(/* your local log file here */)
let xcgLogger = /* Make your XCGLogger, using logFileURL */
let logger = XCGLogging.logger(label: "Test", logger: xcgLogger)
logger.error("Test Test Test")
```

## Example: Logging to both the standard output (Xcode console if using Xcode) and a file using XCGLogger.

```swift
let logFileURL = try getDocumentsDirectory().appendingPathComponent(logFileName)
let xcgLogger = /* Make your XCGLogger, using logFileURL */

LoggingSystem.bootstrap { label in
    let handlers:[LogHandler] = [
        XCGLoggerHandler(label: label, logger: xcgLogger),
        StreamLogHandler.standardOutput(label: label)
    ]

    return MultiplexLogHandler(handlers)
}

let logger = Logger(label: "Test")
```

For more examples, see the unit tests and refer to [apple/swift-log's README](https://github.com/apple/swift-log#the-core-concepts)
