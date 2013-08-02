#import <Foundation/Foundation.h>
#include "tcejdb/ejdb.h"

/*
enum { // Query search mode flags in ejdbqryexecute()
    JBQRYCOUNT = 1, // Query only count(*)
    JBQRYFINDONE = 1 << 1 // < Fetch first record only
};
*/

typedef enum {
  // Fetch only the count of records.
  EJDBQueryCountOnly = 1,
  // Fetch only the first record.
  EJDBQueryFetchFirstOnly = 1 << 1
} EJDBQueryOptions;

@class EJDBCollection;

/**
 This class wraps the EJQ query object and provides a facility for fetching one or more objects.
 It is initialized by the EJDBDatabase and therefore should generally only be used to
 fetch objects that were returned from a query.
*/
@interface EJDBQuery : NSObject

/** The underlying EJQ query object. */
@property (assign,nonatomic,readonly) EJQ *ejQuery;

/** 
 Initialize with the EJQ query object and the collection it will be used with.
 You shouldn't have to ever use create an instance of EJDBQuery as the EJDBDatabase creates it for you.
 @param query - The underlying EJQ object.
 @param collection - The EJDBCollection object.
*/
- (id)initWithEJQuery:(EJQ *)query collection:(EJDBCollection *)collection;

/**
 Fetches the amount of records returned by the query
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
