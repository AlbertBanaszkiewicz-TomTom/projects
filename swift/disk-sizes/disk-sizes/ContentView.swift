//
//  ContentView.swift
//  disk-sizes
//
//  Created by Albert Banaszkiewicz on 09/05/2023.
//

import SwiftUI

struct ContentView: View {
    
    func refresh() {
        print("Refreshing...")
        availableSizeAvailableCapacityForImportantUsageSwift = formatSize(getAvailableSizeAvailableCapacityForImportantUsageSwift())
        availableSizeVolumeAvailableCapacitySwift = formatSize(getAvailableSizeVolumeAvailableCapacitySwift())
        availableSizeNSFileSystemFreeSizeObjC = formatSize(getAvailabeSpaceNSFileSystemFreeSizeObjC())
        availableSizeBoostCpp = formatSize(getAvailabeSpaceBoostCPP())
        print("Refreshed")
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("VACForImportantUsageKey\t: \(availableSizeAvailableCapacityForImportantUsageSwift)")
            Text("VolumeAvailableCapacity\t\t: \(availableSizeVolumeAvailableCapacitySwift)")
            Text("NSFileSystem\t\t\t\t\t: \(availableSizeNSFileSystemFreeSizeObjC)")
            Text("Available (Boost)\t\t\t\t: \(availableSizeBoostCpp)")
            
            HStack {
                Text("Allocate space:")
                TextField("in GB", value: $spaceToAllocate, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                
                Button("Allocate") {
                    lastErrorMessage = nil
                    processingQueue.async{
                        writeFile(size: Measurement(value: Double(spaceToAllocate), unit: UnitInformationStorage.gigabytes), writeProgess: $writeProgess, errorMessage: $lastErrorMessage)
                        refresh()
                    }
                }
                .disabled(writeProgess != 0.0)
               
                Button("Refresh") {
                    lastErrorMessage = nil
                    processingQueue.async{
                        refresh()
                    }
                }
                .disabled(writeProgess != 0.0)
              
                Button("Clear") {
                    lastErrorMessage = nil
                    processingQueue.async{
                        deleteFile(errorMessage: $lastErrorMessage)
                        refresh()
                    }
                }
                .disabled(writeProgess != 0.0)
            }
            
            ProgressView("Writing data \(Int(writeProgess))%...", value: writeProgess, total: 100)
                .opacity(writeProgess == 0.0 ? 0.0 : 1.0)
            
            Text("Error: \(lastErrorMessage ?? "None")")
                .foregroundColor(.red)
                .opacity(lastErrorMessage == nil ? 0.0 : 1.0)
        }
        .padding()
    }
    
    @State private var spaceToAllocate = 2
    @State private var availableSizeAvailableCapacityForImportantUsageSwift = formatSize(nil)
    @State private var availableSizeVolumeAvailableCapacitySwift = formatSize(nil)
    @State private var availableSizeNSFileSystemFreeSizeObjC = formatSize(nil)
    @State private var availableSizeBoostCpp = formatSize(nil)
    @State private var writeProgess = 0.0
    @State private var lastErrorMessage: String?
    
    private let processingQueue = DispatchQueue(label: "disk_sizes")
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

fileprivate func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}

fileprivate func deleteFile(errorMessage: Binding<String?>?) {
    let filename = getDocumentsDirectory().appendingPathComponent("output.txt", isDirectory: false)
    do {
        try FileManager.default.removeItem(at: filename)
    } catch let error {
        print("error occurred, here are the details:\n \(error)")
        errorMessage?.wrappedValue = error.localizedDescription
    }
}

fileprivate func writeFile(size: Measurement<UnitInformationStorage>, writeProgess: Binding<Double>, errorMessage: Binding<String?>) {
    deleteFile(errorMessage: nil)
    
    let filename = getDocumentsDirectory().appendingPathComponent("output.txt", isDirectory: false)

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


fileprivate func formatSize(_ size: Measurement<UnitInformationStorage>?) -> String {
    let formatter = MeasurementFormatter()
    formatter.locale = Locale(identifier: "en_US")
    formatter.unitOptions = .naturalScale
    formatter.numberFormatter.maximumFractionDigits = 1
    return formatter.string(from: size ?? Measurement.init(value: 0, unit: UnitInformationStorage.bytes))
}
