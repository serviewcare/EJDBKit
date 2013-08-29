#import <Foundation/Foundation.h>
#include "tcejdb/ejdb.h"

@class BSONEncoder;
@class EJDBDatabase;

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

typedef EJCOLLOPTS EJDBCollectionOptions;

/** The notification name that is sent when an object is saved via saveObjects. */
extern NSString * const EJDBCollectionObjectSavedNotification;

/** The notification name that is sent when an object is removed via removeObjects. */
extern NSString * const EJDBCollectionObjectRemovedNotification;

/**
 This class wraps the EJCOLL object and provides a facility for saving one or more objects to the underlying database.
*/
@interface EJDBCollection : NSObject

@property (copy,nonatomic,readonly) NSString *name;

/** The underlying EJCOLL object. */
@property (assign,nonatomic,readonly) EJCOLL *collection;

/** The database instance that this collection belongs to. */
@property (weak,nonatomic,readonly) EJDBDatabase *db;

/**
  Retrieve an already existing collection or nil if not found.
  @param collectionName - The name of the existing collection.
  @param db - The database this collection belongs to.
  @returns - An EJDBCollection object or nil if not found.
  @since - v0.2.0
*/
+ (EJDBCollection *)collectionWithName:(NSString *)collectionName db:(EJDBDatabase *)db;
/**
 Initialize with the name of the collection and the database it belongs to.
 @param name - The name of the collection.
 @param db - The database this collection belongs to.
 @since - v0.2.0
*/
- (id)initWithName:(NSString *)name db:(EJDBDatabase *)db;
/**
 Creates a collection if it doesn't exist.
 @param error - The error object to be filled if there was an error.
 @returns - YES if the collection was created successfully, NO if not.
 @since - v0.2.0
*/
- (BOOL)openWithError:(NSError **)error;
/**
 Creates a collectionif it doesn't exist with the supplied options.
 @param options - The options the collection should be created with.
 @param error - The error object to be filled if there was an error.
 @returns - YES if the collection was created successfully, NO if not.
 @since - v0.2.0
*/
- (BOOL)openWithOptions:(EJDBCollectionOptions *)options error:(NSError **)error;
/** 
 Fetch an NSDictionary or object that implements the BSONArchiving protocol with the supplied OID.
 @param OID - A valid OID of the object to fetch.
 @returns - An an NSDictionary or object that implements the BSONArchiving protocol, nil if not found or OID is invalid.
 @since - v0.1.0
*/
- (id)fetchObjectWithOID:(NSString *)OID;
/**
 Saves an object that is an NSDictionary or a class that adopts the BSONArchiving protocol. This is really just a convenience method that calls saveObjects with
 an array containing a single object. Also sends a EJDBCollectionObjectSaved notification after successful save.
 @since - v0.1.0
*/
- (BOOL)saveObject:(id)object;
/**
 Saves the objects contained in the array. Also sends a EJDBCollectionObjectSaved notification after successful save.
 @param objects - An array of dictionaries to save which may be comprised of NSDictionary or classes that adopt the BSONArchiving protocol.
 @returns - YES, if the save was successful, NO otherwise. Note that upon first unsuccessful save, the method returns immediately.
 @since - v0.1.0
*/
- (BOOL)saveObjects:(NSArray *)objects;
/**
 Updates the collection that match the criteria specified in the query dictionary.
 This is mainly a convenience method for when/if you don't want to specifiy hints.
 @param - The query dictionary.
 @returns - The count of objects updated in the collection.
 @since - v0.1.0
*/
- (int)updateWithQuery:(NSDictionary *)query;
/** 
 Updates the collection that match the criteria specified in the query dictionary.
 @param query - The query dictionary.
 @param hints - The query hints (if any). If you don't want to give any hints pass a NULL.
 @returns - The count of objects updated in the collection.
 @since - v0.1.0
*/
- (int)updateWithQuery:(NSDictionary *)query hints:(NSDictionary *)hints;
/**
 Removes the object from the collection. Also sends a EJDBCollectionObjectRemoved notification after removal.
 @param object - The object must either be an NSDictionary that contains an "_id" key or a class that adopts the BSONArchiving protocol.
 @returns
 @since - v0.1.0
 */
- (BOOL)removeObject:(id)object;
/**
 Removes the object with the provided OID. Also sends a EJDBCollectionObjectRemoved notification after removal.
 @param oid - The oid string representation of the object you wish to remove.
 @returns
 @since - v0.1.0
*/
- (BOOL)removeObjectWithOID:(NSString *)OID;
/**
 Sets an index with the supplied index option for the provided field path.
 @param indexOption - The index option (s). You can provide multiple options by bitwise OR-ing. 
                      example: (EJDBIndexNumber | EJDBIndexNumberString).
 @param fieldPath - The path of the field, for example "address.city"
 @returns
 @since - v0.1.0
*/
- (BOOL)setIndexOption:(EJDBIndexOptions)options forFieldPath:(NSString *)fieldPath;
/**
 Synchronize content of a EJDB collection database with the file on device.
 @returns - YES if successful. NO if not.
 @since - v0.1.0
*/
- (BOOL)synchronize;

@end