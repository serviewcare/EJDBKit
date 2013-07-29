#import <Foundation/Foundation.h>
#include "tcejdb/ejdb.h"

/**
 This class decodes a bson object to a dictionary representation. It is meant for internal use only.
*/
@interface BSONDecoder : NSObject

/**
 Decode the bson object into an NSDictionary or an object that implements the BSONArchiving protocol.
 If an object, it must contain a "type" key whose value is the name of a class it will be decoded into
 otherwise an exception will be thrown.
 @param bsonObject - The bson object to be decoded.
*/
- (id)decodeObjectFromBSON:(bson *)bsonObject;

@end
