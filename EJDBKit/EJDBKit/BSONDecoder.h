#import <Foundation/Foundation.h>
#include <tcejdb/ejdb.h>

/**
 This class decodes a bson object to a dictionary representation. It is meant for internal use only.
 It also a work in progress, as it does not support all the bson types that exist.
*/
@interface BSONDecoder : NSObject

/**
 Decode the underlying bson object(s) from the supplied iterator.
 @param iterator - The bson iterator to use for decoding.
 @return dictionary - The dictionary representation of the underlying bson object.
*/
- (NSDictionary *)decodeFromIterator:(bson_iterator)iterator;

@end
