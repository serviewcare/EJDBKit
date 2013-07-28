#import <Foundation/Foundation.h>
#include "tcejdb/ejdb.h"

@class BSONEncoder;

/*
typedef enum
{
  EJDBCollectionIndex 
}
EJDBCollectionIndexOptions;
*/

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
 Saves an object that is an NSDictionary or a class that adopts the BSONArchiving protocol. This is really just a convenience method that calls saveObjects with
 an array containing a single object.
*/
- (BOOL)saveObject:(id)object;

/**
 Saves the objects contained in the array.
 @param objects - An array of dictionaries to save which may be comprised of NSDictionary or classes that adopt the BSONArchiving protocol.
 @return - YES, if the save was successful, NO otherwise.
*/
- (BOOL)saveObjects:(NSArray *)objects;

@end
