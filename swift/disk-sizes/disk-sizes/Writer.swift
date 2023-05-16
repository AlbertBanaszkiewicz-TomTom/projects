//
//  Writer.swift
//  disk-sizes
//
//  Created by Albert Banaszkiewicz on 16/05/2023.
//

import Foundation
import SwiftUI

public class Writer {
    func deleteFile(errorMessage: Binding<String?>?) {
        let filename = getOutputDirectoryUrl().appendingPathComponent("output.txt", isDirectory: false)
        do {
            try FileManager.default.removeItem(at: filename)
        } catch let error {
            errorMessage?.wrappedValue = error.localizedDescription
        }
    }
    
    func writeFile(size: Measurement<UnitInformationStorage>, writeProgess: Binding<Double>, errorMessage: Binding<String?>) {
        let filename = getOutputDirectoryUrl().appendingPathComponent("output.txt", isDirectory: false)

        var megabyteOfData: [UInt8] = []
        for i in 0..<1024*1024 {
            megabyteOfData.append(UInt8(i % 0xff))
        }
        
        let data = Data(bytes: &megabyteOfData, count: megabyteOfData.count * MemoryLayout<UInt8>.stride)

        do {
            let chunks = Int(size.converted(to: UnitInformationStorage.megabytes).value)
            
            writeProgess.wrappedValue = 0.0
            try data.write(to: filename, options: .atomicWrite)
            
            let fileHandle = try FileHandle(forWritingTo: filename)
            for i in 2...chunks {
                try fileHandle.write(contentsOf: data)
                writeProgess.wrappedValue = Double(i * 100 / chunks)
            }
            try fileHandle.close()
        }
        catch {
            print(error)
            errorMessage.wrappedValue = error.localizedDescription
        }
        
        writeProgess.wrappedValue = 0.0
    }
}


