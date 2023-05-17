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

enum ActionAfterDownload {
    case nothing
    case copy
    case move
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
                        writer.deleteFile(errorMessage: $lastErrorMessage)
                        refresh()
                    }
                    
                    Spacer()
                }
                .disabled(writeProgess != 0.0)
                
                VStack(alignment: .leading) {
                    Text("Location:")
                    Text("\(writer.path)")
                        .foregroundStyle(.secondary)
                        .foregroundColor(writer.outputExists() ? .black : .red)
                }
                
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
                            downloader.downloadFile(url: URL(string: amountToDownload)!, downloadProgess: $writeProgess, downloadedFiles: $downloadedFiles, action: selectedActionAfterDownload, errorMessage: $lastErrorMessage)
                        }
                    }
                    
                    Button("Delete") {
                        lastErrorMessage = nil
                        downloader.deleteFile(id: selectedDownloadedFile!, downloadedFiles: $downloadedFiles, errorMessage: $lastErrorMessage)
                        selectedDownloadedFile = nil
                        refresh()
                    }
                    .disabled(selectedDownloadedFile == nil)
                    .opacity(selectedDownloadedFile == nil ? 0.5 : 1)
                    
                    Spacer()
                }
                .disabled(writeProgess != 0.0)
                
                HStack {
                    Text("After download do")
                    Picker("After download action", selection: $selectedActionAfterDownload) {
                        ForEach(actionsAfterDownload.sorted { $0.0 < $1.0 }, id: \.key) { key, value in
                            Text(key).tag(value)
                        }
                    }
                    .pickerStyle(.menu)
                    
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
    @State private var moveWhenDownloaded = false
    @State private var copyWhenDownloaded = false
    @State private var selectedActionAfterDownload = ActionAfterDownload.nothing

    private let processingQueue = DispatchQueue(label: "disk_sizes")
    private let amountsToWrite = ["1 GB" : 1,
                                  "5 GB" : 5,
                                  "10 GB" : 10,
                                  "15 GB" : 15,
                                  "20 GB" : 20,
                                  "25 GB" : 25,
                                  "30 GB" : 30,
                                  "35 GB" : 35,
                                  "40 GB" : 40,
                                  "45 GB" : 45,
                                  "50 GB" : 50]
    private let amountsToDownload = ["0.015 GB" : "https://link.testfile.org/15MB",
                                     "0.5 GB" : "https://link.testfile.org/500MB",
                                     "1 GB" : "https://bit.ly/1GB-testfile",
                                     "5 GB": "https://bit.ly/5GB-TESTFILE-ORG",
                                     "10 GB": "https://bit.ly/10GbOVHserver"]
    private let actionsAfterDownload = ["Nothing" : ActionAfterDownload.nothing,
                                        "Copy" : ActionAfterDownload.copy,
                                        "Move" : ActionAfterDownload.move]
    
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
