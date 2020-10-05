# swift-log-file

[SwiftLog](https://github.com/apple/swift-log) compatible file log handler.

## Example: Just logging to a file

```swift
let logFileURL = URL(/* your local log file here */)
let logger = try FileLogHandler.fileLogger(label: "Foobar", localFile: logFileURL)

logger.error("Test Test Test")
```

## Example: Logging to both the standard output (Xcode console if using Xcode) and a file.

```swift
let logFileURL = try getDocumentsDirectory().appendingPathComponent(logFileName)

LoggingSystem.bootstrap { label in
    var handlers = [LogHandler]()
    
    if let logFileHandler = try? FileLogHandler(label: label, localFile: logFileURL) {
        handlers += [logFileHandler]
    }
    
    handlers += [StreamLogHandler.standardOutput(label: label)]

    return MultiplexLogHandler(handlers)
}

let logger = Logger(label: "Test")
```

Note in that last example, if you use `LoggingSystem.bootstrap`, make sure to create your `Logger` *after* the  `LoggingSystem.bootstrap` usage (or you won't get the effects of the `LoggingSystem.bootstrap`).

For more examples, see the unit tests and refer to [apple/swift-log's README](https://github.com/apple/swift-log#the-core-concepts)
