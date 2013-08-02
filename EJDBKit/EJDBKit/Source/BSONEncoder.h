#import <Foundation/Foundation.h>
#include "tcejdb/ejdb.h"

/**
 This class encodes a dictionary to a bson object. It is meant for internal use only.
*/
@interface BSONEncoder : NSObject

/**
 The underlying bson object.
*/
@property (nonatomic,getter = bson,readonly) bson *bson;

/**
 By default, the underlying bson is not useable as a query. This initializer allows it to be used in queries
 whereas the default initializer is only allowed for fetching, saving or updating.
*/
- (id)initAsQuery;

/**
 Encodes the dictionary into a bson object.
 @param dictionary - The dictionary to be encoded.
*/
- (void)encodeDictionary:(NSDictionary *)dictionary;

/**
 Finish the underlying bson object, that is, once this method is called, further modifications can't be made to it.
*/
- (void)finish;

@end
