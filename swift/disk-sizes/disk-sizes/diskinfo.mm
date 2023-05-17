#import "diskinfo.h"

#include <boost/filesystem.hpp>

@implementation DiskInfo

+ (double) getAvailabeSpaceNSFileSystemFreeSizeObjC {
    NSDictionary* dict = [[NSFileManager defaultManager] attributesOfFileSystemForPath:@"/" error:NULL];
    auto freeSpace = [[dict objectForKey:NSFileSystemFreeSize] doubleValue];
    return freeSpace;
}

+ (double) getAvailabeSpaceBoostCPP {
    std::string path = std::string([NSHomeDirectory() UTF8String]);
    boost::filesystem::space_info space = boost::filesystem::space(path);
    return space.free * 1.0f;
}

@end
