#import <Foundation/Foundation.h>
#include "tcejdb/ejdb.h"

@class BSONEncoder;

typedef enum
{
  /** Drop index. */
  EJDBIndexDrop = 1 << 0,
  /** Drop index for all types. */
  EJDBIndexDropAll = 1 << 1,
  /** Optimize indexes. */
  EJDBIndexOptimize = 1 << 2,
  /** Rebuild index. */
  EJDBIndexRebuild = 1 << 3,
  /** Number index. */
  EJDBIndexNumber = 1 << 4,
  /** String index. */
  EJDBIndexString = 1 << 5,
  /** Array token index. */
  EJDBIndexArray = 1 << 6,
  /** Case insensitive string index. */
  EJDBIndexStringCaseInsensitive = 1 << 7
}
EJDBIndexOptions;


extern NSString * const EJDBCollectionObjectSavedNotification;
extern NSString * const EJDBCollectionObjectRemovedNotification;

/**
 This class wraps the EJCOLL object and provides a facility for saving one or more objects to the underlying database.
*/
@interface EJDBCollection : NSObject

/** The underlying EJCOLL object. */
@property (assign,nonatomic,readonly) EJCOLL *collection;

/** 
 Initialize with the name of the collection and the EJCOLL object. You should never have to create collections manually
 as the EJDBDatabase object does this for you.
 @param name - The name of the collection.
 @param collection - The collection object.
*/
- (id)initWithName:(NSString *)name collection:(EJCOLL *)collection;


/** 
 Fetch an NSDictionary or object that implements the BSONArchiving protocol with the supplied OID.
 @param OID - A valid OID of the object to fetch.
 @return - An an NSDictionary or object that implements the BSONArchiving protocol, nil if not found or OID is invalid.
*/
- (id)fetchObjectWithOID:(NSString *)OID;


/**
 Saves an object that is an NSDictionary or a class that adopts the BSONArchiving protocol. This is really just a convenience method that calls saveObjects with
 an array containing a single object.
*/
- (BOOL)saveObject:(id)object;

/**
 Saves the objects contained in the array.
 @param objects - An array of dictionaries to save which may be comprised of NSDictionary or classes that adopt the BSONArchiving protocol.
 @return - YES, if the save was successful, NO otherwise. Note that upon first unsuccessful save, the method returns immediately.
*/
- (BOOL)saveObjects:(NSArray *)objects;


/**
 Updates the collection that match the criteria specified in the query dictionary.
 This is mainly a convenience method for when/if you don't want to specifiy hints.
 @param - The query dictionary.
 @return - The count of objects updated in the collection.
*/
- (int)updateWithQuery:(NSDictionary *)query;

/** 
 Updates the collection that match the criteria specified in the query dictionary.
 @param query - The query dictionary.
 @param hints - The query hints (if any). If you don't want to give any hints pass a NULL.
 @return - The count of objects updated in the collection.
*/
- (int)updateWithQuery:(NSDictionary *)query hints:(NSDictionary *)hints;

/**
 Removes the object from the collection.
 @param object - The object must either be an NSDictionary that contains an "_id" key or a class that adopts the BSONArchiving protocol.
 @return
 */
- (BOOL)removeObject:(id)object;

/**
 Removes the object with the provided OID.
 @param oid - The oid string representation of the object you wish to remove.
 @return
*/
- (BOOL)removeObjectWithOID:(NSString *)OID;

/**
 Sets an index with the supplied index option for the provided field path.
 @param indexOption - The index option (s). You can provide by multiple options by bitwise OR-ing. 
                      example: (EJDBIndexNumber | EJDBIndexNumberString).
 @param fieldPath - The path of the field, for example "address.city"
 @return
*/
- (BOOL)setIndexOption:(EJDBIndexOptions)options forFieldPath:(NSString *)fieldPath;

/**
Synchronize content of a EJDB collection database with the file on device.
@return - YES if successful. NO if not.
*/
- (BOOL)synchronize;

@end