//
//  Writer.swift
//  disk-sizes
//
//  Created by Albert Banaszkiewicz on 16/05/2023.
//

import Foundation
import SwiftUI

public class Writer {
    init() {
        self.path = getOutputDirectoryUrl().appendingPathComponent("output.txt", isDirectory: false)
        self.megabyteOfData = []
        for i in 0..<1024*1024 {
            self.megabyteOfData.append(UInt8(i % 0xff))
        }
        data = Data(bytes: megabyteOfData, count: megabyteOfData.count * MemoryLayout<UInt8>.stride)
    }
    
    func deleteFile(errorMessage: Binding<String?>?) {
        errorMessage?.wrappedValue = ""
        if outputExists() {
            do {
                try FileManager.default.removeItem(at: path)
            } catch let error {
                errorMessage?.wrappedValue = error.localizedDescription
                return
            }
        }
        errorMessage?.wrappedValue = nil
    }
    
    func writeFile(size: Measurement<UnitInformationStorage>, writeProgess: Binding<Double>, errorMessage: Binding<String?>) {
        do {
            let chunks = Int(size.converted(to: UnitInformationStorage.megabytes).value)
            
            writeProgess.wrappedValue = 0.0
            try data.write(to: path, options: .atomicWrite)
            
            let fileHandle = try FileHandle(forWritingTo: path)
            for i in 2...chunks {
                try fileHandle.write(contentsOf: data)
                writeProgess.wrappedValue = Double(i * 100 / chunks)
            }
            try fileHandle.close()
        }
        catch {
            errorMessage.wrappedValue = error.localizedDescription
        }
        
        writeProgess.wrappedValue = 0.0
    }
    
    func outputExists() -> Bool {
       FileManager.default.fileExists(atPath: path.path)
    }
    
    public let path: URL
    private var megabyteOfData: [UInt8]
    private let data: Data
}


