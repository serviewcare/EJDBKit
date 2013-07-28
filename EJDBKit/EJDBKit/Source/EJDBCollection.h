#import <Foundation/Foundation.h>
#include "tcejdb/ejdb.h"

@class BSONEncoder;

/**
 This class wraps the EJCOLL object and provides a facility for saving one or more objects to the underlying database.
*/
@interface EJDBCollection : NSObject

/** The underlying EJCOLL object. */
@property (assign,nonatomic,readonly) EJCOLL *collection;

/** 
 Initialize with the name of the collection and the EJCOLL object.
*/
- (id)initWithName:(NSString *)name collection:(EJCOLL *)collection;

/**
 Save an object. This is really just a convenience method that calls the saveObjects method.
 @param dictionary - The dictionary to save.
 @return - YES, if the save was successful, NO otherwise.
*/
- (BOOL)saveObject:(NSDictionary *)dictionary;

/**
 Saves the objects contained in the array.
 @param objects - An array of dictionaries to save.
 @return - YES, if the save was successful, NO otherwise.
*/
- (BOOL)saveObjects:(NSArray *)objects;

@end
