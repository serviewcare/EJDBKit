#import <Foundation/Foundation.h>
#include <tcejdb/ejdb.h>

@class EJDBCollection;

@interface EJDBQuery : NSObject

@property (assign,nonatomic,readonly) EJQ *ejQuery;

- (id)initWithEJQuery:(EJQ *)query collection:(EJDBCollection *)collection;
- (void)execute;
@end
