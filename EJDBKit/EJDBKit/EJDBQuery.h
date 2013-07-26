#import <Foundation/Foundation.h>
#include <tcejdb/ejdb.h>

@class EJDBCollection;

@interface EJDBQuery : NSObject

@property (assign,nonatomic,readonly) EJQ *ejQuery;

- (id)initWithEJQuery:(EJQ *)query collection:(EJDBCollection *)collection;
- (NSDictionary *)fetchObject;
- (NSArray *)fetchObjects;
@end
