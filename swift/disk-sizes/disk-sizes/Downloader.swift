//
//  Downloader.swift
//  disk-sizes
//
//  Created by Albert Banaszkiewicz on 15/05/2023.
//

import Foundation
import SwiftUI

public class Downloader {
    func downloadFile(url: URL, downloadProgess: Binding<Double>, downloadedFiles: Binding<[DownloadedFile]>, errorMessage: Binding<String?>) {
        print("Downloading: \(url)")
        task = URLSession.shared.downloadTask(with: url) { localURL, urlResponse, error in
            if let localURL = localURL, error == nil {
                if let statusCode = (urlResponse as? HTTPURLResponse)?.statusCode {
                    print("Successfully downloaded. Status code: \(statusCode)")
                }
                
                print("Downloaded to \(localURL)")
                
                let fileSize = try? FileManager.default.attributesOfItem(atPath: localURL.path())[FileAttributeKey.size] as? UInt64
                let downloadedFile = DownloadedFile(id: self.id, url: localURL, size: Measurement.init(value: fileSize != nil ? Double(fileSize!) : -1.0, unit: UnitInformationStorage.bytes))
                downloadedFiles.wrappedValue.append(downloadedFile)
                                                   
                self.id = self.id + 1
    //            do {
    //                deleteFile(errorMessage: nil)
    //                let destinationFileUrl = getOutputDirectoryUrl().appendingPathComponent("output.txt")
    //                try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
    //            } catch (let writeError) {
    //                errorMessage.wrappedValue = writeError.localizedDescription
    //            }
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
    
    public var downloadTmpUrls: [URL : Measurement<UnitInformationStorage>] = [:]
    
    private var task: URLSessionDownloadTask?
    private var progressObserver: NSKeyValueObservation?
    private var id: Int = 0
}


