# swift-log-file

```
let logFileURL = URL(/* your local log file here */)
let logger = try FileLogHandler.fileLogger(label: "Foobar", localFile: logFileURL)

logger.error("Test Test Test")
```

```
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

For more examples, see the unit tests.
