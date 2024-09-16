import libfragmentzip
import Foundation

public enum FragmentZipError: Error {
    case downloadFailed(Int32)
    case handleNotInitialized
}

/// Wrapper for libfragmentzip
/// Must call `open(url: URL)` to open
/// close will automatically be called on `deinit()`
public final class FragmentZip {
    
    private var url: URL?
    private var handle: UnsafeMutableRawPointer?
    
    
    /// Open a URL, will close any open URLs
    /// - Parameter url: URL to open
    public func open(url: URL) {
        close()
        self.url = url
        self.handle = fragmentzip_open(convertURLToCString(url))
    }
    
    /// Close the current URL handle if any
    public func close() {
        if let handle = handle {
            fragmentzip_close(handle)
            self.handle = nil
        }
        self.url = nil
    }
        
    /// Download a remote file to local path with progress handler
    /// - Parameters:
    ///   - remotePath: remote path
    ///   - savePath: save path
    ///   - progressCallback: progress callback with status from 0 to 1
    public func downloadFile(remotePath: String, savePath: String, progressCallback: fragmentzip_process_callback_t? = nil) throws {
        guard let handle = self.handle else {
            throw FragmentZipError.handleNotInitialized
        }
        
        let remotePathCString = remotePath.cString(using: .utf8)
        let savePathCString = savePath.cString(using: .utf8)
        
        let result = fragmentzip_download_file(handle, remotePathCString, savePathCString, progressCallback)
        
        if result != 0 {
            throw FragmentZipError.downloadFailed(result)
        }
    }
    
    deinit {
        close()
    }
    
    private func convertURLToCString(_ url: URL) -> UnsafePointer<CChar>! {
        let path = url.path
        return (path as NSString).utf8String
    }
}

private class ProgressContext {
    let callback: ((Double) -> Void)?
    
    init(callback: ((Double) -> Void)?) {
        self.callback = callback
    }
}
