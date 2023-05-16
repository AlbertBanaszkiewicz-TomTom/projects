//
//  ContentView.swift
//  disk-sizes
//
//  Created by Albert Banaszkiewicz on 09/05/2023.
//

import SwiftUI

struct DownloadedFile: Identifiable {
    let id: Int
    var url: URL
    var size: Measurement<UnitInformationStorage>
}

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
            Text("")
            
            VStack {
                HStack {
                    Button("Refresh") {
                        lastErrorMessage = nil
                        processingQueue.async {
                            refresh()
                        }
                    }
                }
                .disabled(writeProgess != 0.0)
                .padding()
                
                HStack {
                    Text("Write")
                    Picker("Select amount to write", selection: $amountToWrite) {
                        ForEach(amountsToWrite.sorted { $0.1 < $1.1 }, id: \.key) { key, value in
                            Text(key).tag(value)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    Button("Write") {
                        lastErrorMessage = nil
                        processingQueue.async {
                            writer.deleteFile(errorMessage: nil)
                            writer.writeFile(size: Measurement(value: Double(amountToWrite), unit: UnitInformationStorage.gigabytes), writeProgess: $writeProgess, errorMessage: $lastErrorMessage)
                            refresh()
                        }
                    }
                    
                    Button("Clear") {
                        lastErrorMessage = nil
                        writer.deleteFile(errorMessage: $lastErrorMessage)
                        refresh()
                    }
                    
                    Spacer()
                }
                .disabled(writeProgess != 0.0)
                
                HStack {
                    Text("Download")
                    Picker("Select amount to download", selection: $amountToDownload) {
                        ForEach(amountsToDownload.sorted { $0 < $1 }, id: \.key) { key, value in
                            Text(key).tag(value)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    Button("Download") {
                        lastErrorMessage = nil
                        processingQueue.async {
                            downloader.downloadFile(url: URL(string: amountToDownload)!, downloadProgess: $writeProgess, downloadedFiles: $downloadedFiles, errorMessage: $lastErrorMessage)
                        }
                    }
                    
                    Button("Clear") {
                        lastErrorMessage = nil
                        refresh()
                    }
                    
                    Spacer()
                }
                .disabled(writeProgess != 0.0)
                
                Table(downloadedFiles, selection: $selectedDownloadedFile) {
                    TableColumn("Size in GB") { file in
                        VStack {
                            Text("\(formatSize(file.size))")
                            Text("\(file.url.absoluteString)")
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
                
                Text("")
                
                ProgressView("Writing data \(Int(writeProgess))%...", value: writeProgess, total: 100)
                    .opacity(writeProgess == 0.0 ? 0.0 : 1.0)
                
                Text("Error: \(lastErrorMessage ?? "None")")
                    .foregroundColor(.red)
                    .opacity(lastErrorMessage == nil ? 0.0 : 1.0)
            }
        }
        .padding()
    }
    
    @State private var amountToWrite = 1
    @State private var amountToDownload = "https://link.testfile.org/15MB"
    @State private var availableSizeAvailableCapacityForImportantUsageSwift = formatSize(nil)
    @State private var availableSizeVolumeAvailableCapacitySwift = formatSize(nil)
    @State private var availableSizeNSFileSystemFreeSizeObjC = formatSize(nil)
    @State private var availableSizeBoostCpp = formatSize(nil)
    @State private var writeProgess = 0.0
    @State private var downloadProgess = 0.0
    @State private var lastErrorMessage: String?
    @State private var downloadedFiles: [DownloadedFile] = []
    @State private var selectedDownloadedFile: DownloadedFile.ID?
    
    private let processingQueue = DispatchQueue(label: "disk_sizes")
    private let amountsToWrite = ["1 GB" : 1,
                                  "5 GB" : 5,
                                  "10 GB" : 10,
                                  "20 GB" : 20,
                                  "30 GB" : 30,
                                  "40 GB" : 40,
                                  "50 GB" : 50]
    private let amountsToDownload = ["0.015 GB" : "https://link.testfile.org/15MB",
                                     "0.5 GB" : "https://link.testfile.org/500MB",
                                     "1 GB" : "https://mmatechnical.com/Download/Download-Test-File/(MMA)-1GB.zip",
                                     "10 GB": "https://bit.ly/10GbOVHserver"]
    private let writer = Writer()
    private let downloader = Downloader()
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

fileprivate func formatSize(_ size: Measurement<UnitInformationStorage>?) -> String {
    let formatter = MeasurementFormatter()
    formatter.locale = Locale(identifier: "en_US")
    formatter.unitOptions = .naturalScale
    formatter.numberFormatter.maximumFractionDigits = 1
    return formatter.string(from: size ?? Measurement.init(value: 0, unit: UnitInformationStorage.bytes))
}
