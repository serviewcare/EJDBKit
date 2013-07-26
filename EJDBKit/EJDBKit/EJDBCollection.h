#import <Foundation/Foundation.h>
#include <tcejdb/ejdb.h>

@class BSONEncoder;

@interface EJDBCollection : NSObject
@property (assign,nonatomic) EJCOLL *collection;

- (id)initWithName:(NSString *)name collection:(EJCOLL *)collection;

- (BOOL)saveObject:(NSDictionary *)dictionary;

- (BOOL)saveObjects:(NSArray *)objects;


@end
