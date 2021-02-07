
import Foundation

enum TestError: Error {
    case noDocumentDirectory
    case cannotGetFileSize
}
    
protocol Utilities {
}

extension Utilities {
    func getDocumentsDirectory() throws -> URL {
        let paths = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)
        guard paths.count > 0 else {
            throw TestError.noDocumentDirectory
        }
        
        return paths[0]
    }
    
    func getFileSize(file: URL) throws -> UInt64 {
        let attr = try FileManager.default.attributesOfItem(atPath: file.path)
        guard let fileSize = attr[FileAttributeKey.size] as? UInt64 else {
            throw TestError.cannotGetFileSize
        }

        return fileSize
    }
}
