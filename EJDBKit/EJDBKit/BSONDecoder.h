#import <Foundation/Foundation.h>
#include <tcejdb/ejdb.h>

@interface BSONDecoder : NSObject

- (NSDictionary *)decodeFromIterator:(bson_iterator)iterator;

@end
