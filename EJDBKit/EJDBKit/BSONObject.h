#import <Foundation/Foundation.h>
#include <tcejdb/ejdb.h>


@interface BSONObject : NSObject

@property (nonatomic,getter = bson,readonly) bson *bson;

- (id)initAsQuery;

- (void)encodeDictionary:(NSDictionary *)dictionary;

- (void)finish;

@end
