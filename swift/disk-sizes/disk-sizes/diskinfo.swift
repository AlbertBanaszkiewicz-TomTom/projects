//
//  diskinfo.swift
//  disk-sizes
//
//  Created by Albert Banaszkiewicz on 11/05/2023.
//

import Foundation

func getOutputDirectoryUrl() -> URL {
    FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
}

func getAvailableSizeAvailableCapacityForImportantUsageSwift() -> Measurement<UnitInformationStorage>? {
    let url = getOutputDirectoryUrl()
    do {
        let values = try url.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey])
        if let capacity = values.volumeAvailableCapacityForImportantUsage {
            return Measurement(value: Double(capacity), unit: UnitInformationStorage.bytes)
        }
    }
    catch {
        print("ERROR: getAvailableSizeAvailableCapacityForImportantUsageSwift")
    }
    
    return nil
}

func getAvailableSizeVolumeAvailableCapacitySwift() -> Measurement<UnitInformationStorage>? {
    let url = getOutputDirectoryUrl()
    do {
        let values = try url.resourceValues(forKeys: [.volumeAvailableCapacityKey])
        if let capacity = values.volumeAvailableCapacity {
            return Measurement(value: Double(capacity), unit: UnitInformationStorage.bytes)
        }
    }
    catch {
        print("ERROR: getAvailableSizeVolumeAvailableCapacitySwift")
    }
    
    return nil
}

func getAvailabeSpaceNSFileSystemFreeSizeObjC() -> Measurement<UnitInformationStorage>? {
    Measurement.init(value: DiskInfo.getAvailabeSpaceNSFileSystemFreeSizeObjC(), unit: UnitInformationStorage.bytes)
}

func getAvailabeSpaceBoostCPP() -> Measurement<UnitInformationStorage>? {
    Measurement.init(value: DiskInfo.getAvailabeSpaceBoostCPP(), unit: UnitInformationStorage.bytes)
}
