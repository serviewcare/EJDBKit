#import <Foundation/Foundation.h>
#include <tcejdb/ejdb.h>

@class EJDBRecord;

@interface EJDBCollection : NSObject
@property (assign,nonatomic) EJCOLL *collection;

- (id)initWithName:(NSString *)name collection:(EJCOLL *)collection;

- (BOOL)saveRecord:(EJDBRecord *)record;

@end
