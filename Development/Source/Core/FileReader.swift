//
//  FileReader.swift
//  TinkoffMockStrapping
//
//  Created by a.volokhin on 04.02.2020.
//

import Foundation
import SwiftyJSON

/// Reads data from any files from the given Bundle.
open class FileReader {

    private let defaultBundle: Bundle

    /// Initializes reader.
    /// - Parameter defaultBundle: bundle to lookup files unless special bundle doesn't provided.
    public init(defaultBundle: Bundle) {
        self.defaultBundle = defaultBundle
    }

    /// Read file with specific name & extension into Data.
    /// - Parameters:
    ///   - name: Name of the file to read.
    ///   - extension: Extension of the file to read.
    ///   - bundle: Bundle with the file.
    public func readFile(name: String, extension: String, bundle: Bundle? = nil) -> Data {
        let bundle = bundle ?? defaultBundle
        guard let fileUrl = bundle.url(forResource: name, withExtension: `extension`) else {
            fatalError("File \(name).\(`extension`) could not be located at the given bundle")
        }
        do {
            return try Data(contentsOf: fileUrl)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
