#import <Foundation/Foundation.h>
#include "tcejdb/ejdb.h"

@class EJDBCollection;

/**
 This class wraps the EJQ query object and provides a facility for fetching one or more objects.
*/
@interface EJDBQuery : NSObject

/** The underlying EJQ query object. */
@property (assign,nonatomic,readonly) EJQ *ejQuery;

/** 
 Initialize with the EJQ query object and the collection it will be used with.
 @param query - The underlying EJQ object.
 @param collection - The EJDBCollection object.
*/
- (id)initWithEJQuery:(EJQ *)query collection:(EJDBCollection *)collection;

/** 
 Fetch a single object.
 @return - The returned object.
*/
- (NSDictionary *)fetchObject;

/**
 Fetch an array of objects.
 @return - An array of objects.
*/
- (NSArray *)fetchObjects;

@end
