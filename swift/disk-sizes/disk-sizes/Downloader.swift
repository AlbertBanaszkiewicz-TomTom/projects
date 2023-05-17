//
//  Downloader.swift
//  disk-sizes
//
//  Created by Albert Banaszkiewicz on 15/05/2023.
//

import Foundation
import SwiftUI

public class Downloader {
    func downloadFile(url: URL, downloadProgess: Binding<Double>, downloadedFiles: Binding<[DownloadedFile]>, action: ActionAfterDownload, errorMessage: Binding<String?>) {
        print("Downloading: \(url)")
        print("After download do: \(action)")
        task = URLSession.shared.downloadTask(with: url) { localURL, urlResponse, error in
            if let localURL = localURL, error == nil {
                if let statusCode = (urlResponse as? HTTPURLResponse)?.statusCode {
                    print("Successfully downloaded. Status code: \(statusCode)")
                }
                
                print("Downloaded to \(localURL)")
                
                let fileSize = try? FileManager.default.attributesOfItem(atPath: localURL.path())[FileAttributeKey.size] as? UInt64
                let downloadedFile = DownloadedFile(id: self.id, url: localURL, size: Measurement.init(value: fileSize != nil ? Double(fileSize!) : -1.0, unit: UnitInformationStorage.bytes))
                
                switch action {
                    case .copy:
                        do {
                            let destinationFileUrl = getOutputDirectoryUrl().appendingPathComponent(localURL.lastPathComponent)
                            print("Copying to \(destinationFileUrl)...")
                            try FileManager.default.copyItem(at: localURL, to: destinationFileUrl)
                            print("Copied.")
                        } catch (let writeError) {
                            errorMessage.wrappedValue = writeError.localizedDescription
                        }
                    case .move:
                        do {
                            let destinationFileUrl = getOutputDirectoryUrl().appendingPathComponent(localURL.lastPathComponent)
                            print("Moving to \(destinationFileUrl)...")
                            try FileManager.default.moveItem(at: localURL, to: destinationFileUrl)
                            print("Moved.")
                        } catch (let writeError) {
                            errorMessage.wrappedValue = writeError.localizedDescription
                        }
                    case .nothing:
                        break
                }
                
                downloadedFiles.wrappedValue.append(downloadedFile)
                                                   
                self.id = self.id + 1
            } else {
                errorMessage.wrappedValue = error?.localizedDescription
            }
            
            self.task = nil
            self.progressObserver = nil
            downloadProgess.wrappedValue = 0
        }

        progressObserver = task!.progress.observe(\.fractionCompleted) { progress, _ in
          downloadProgess.wrappedValue = progress.fractionCompleted * 100
        }
        
        task?.resume()
    }
    
    func deleteFile(id: Int, downloadedFiles: Binding<[DownloadedFile]>, errorMessage: Binding<String?>) {
        guard let index = downloadedFiles.wrappedValue.firstIndex(where: {$0.id == id}) else {
            errorMessage.wrappedValue = "Could not locate file"
            return
        }
        
        var errorString = ""

        let file = downloadedFiles.wrappedValue[index]
        
        do {
            print("Deleting \(file.url)...")
            try FileManager.default.removeItem(at: file.url)
            print("Deleted.")
        } catch let error {
            errorString = "[TMP]" + error.localizedDescription
        }

        do {
            let destinationFileUrl = getOutputDirectoryUrl().appendingPathComponent(file.url.lastPathComponent)
            print("Deleting \(destinationFileUrl)...")
            try FileManager.default.removeItem(at: destinationFileUrl)
            print("Deleted.")
        } catch let error {
            errorString = errorString + "[DOC]" + error.localizedDescription
        }

        if !errorString.isEmpty {
            errorMessage.wrappedValue = errorString
        }
        
        downloadedFiles.wrappedValue.remove(at: index)
    }

    private var task: URLSessionDownloadTask?
    private var progressObserver: NSKeyValueObservation?
    private var id: Int = 0
}


