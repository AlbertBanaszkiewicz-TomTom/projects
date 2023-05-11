#import "diskinfo.h"

#include <boost/filesystem.hpp>

@implementation DiskInfo

+ (double) getAvailabeSpaceNSFileSystemFreeSizeObjC {
    NSDictionary* dict = [[NSFileManager defaultManager] attributesOfFileSystemForPath:@"/" error:NULL];
    auto freeSpace = [[dict objectForKey:NSFileSystemFreeSize] doubleValue];
    return freeSpace;
}

+ (double) getAvailabeSpaceBoostCPP {
    return boost::filesystem::space(".").available * 1.0f;
}

@end
