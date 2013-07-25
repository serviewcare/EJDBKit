#import <Foundation/Foundation.h>
#include <tcejdb/ejdb.h>

@class BSONObject;

@interface EJDBCollection : NSObject
@property (assign,nonatomic) EJCOLL *collection;

- (id)initWithName:(NSString *)name collection:(EJCOLL *)collection;

- (BOOL)saveObject:(BSONObject *)bsonObject;

@end
