#import <Foundation/Foundation.h>
#include <tcejdb/ejdb.h>


@interface BSONEncoder : NSObject

@property (nonatomic,getter = bson,readonly) bson *bson;

- (id)initAsQuery;

- (void)encodeDictionary:(NSDictionary *)dictionary;

- (void)finish;

@end
