# swift-log-file

```
let logFileURL = URL(/* your local log file here */)
let logger = try FileLogHandler.fileLogger(label: "Foobar", localFile: logFileURL)

logger.error("Test Test Test")
```

For more examples, see the unit tests.
