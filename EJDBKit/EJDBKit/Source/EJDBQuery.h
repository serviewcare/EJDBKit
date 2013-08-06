#import <Foundation/Foundation.h>
#include "tcejdb/ejdb.h"

typedef enum {
  /** Fetch only the count of records. */
  EJDBQueryCountOnly = 1,
  /** Fetch only the first record. */
  EJDBQueryFetchFirstOnly = 1 << 1
} EJDBQueryOptions;

@class EJDBCollection;

/**
 This class wraps the EJQ query object and provides a facility for fetching one or more objects.
 It is initialized by the EJDBDatabase and therefore should generally only be used to
 fetch an object/objects that was/were returned from a query.

 It's also very important to note that once you call any of the fetch* methods, the underlying query
 is freed (released from memory) after the query is executed and is no longer accessible. In other words,
 it is a one-time use object only and attempting to use it more than once will cause an EXC_BAD_ACCESS error!!!
*/
@interface EJDBQuery : NSObject

/** The underlying EJQ query object. */
@property (assign,nonatomic,readonly) EJQ *ejQuery;

/** 
 Initialize with the EJQ query object and the collection it will be used with.
 You shouldn't have to ever create an instance of EJDBQuery yourself as the EJDBDatabase creates it for you.
 @param query - The underlying EJQ object.
 @param collection - The EJDBCollection object.
*/
- (id)initWithEJQuery:(EJQ *)query collection:(EJDBCollection *)collection;


/**
  The count of records returned by a query.
*/
- (NSUInteger)recordCount;

/**
 Executes the query but only fetches the amount of records instead of the results.
 @return count - The count of records.
*/
- (int)fetchCount;

/** 
 Fetch a single object.
 @return - The returned object or nil if not found.
*/
- (id)fetchObject;

/**
 Fetch an array of objects.
 @return - An array of objects.
*/
- (NSArray *)fetchObjects;

@end
