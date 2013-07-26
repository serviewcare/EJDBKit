#import <Foundation/Foundation.h>
#include <tcejdb/ejdb.h>

@class EJDBCollection;
@class EJDBQuery;

/**
 This class wraps the EJDB object and provides the ability to manipulate the underlying db,collections,etc.
*/
@interface EJDBDatabase : NSObject

/** The underlying EJDB object. */
@property (assign,nonatomic,readonly) EJDB *db;

/** 
    Initializes the object with the path of the db.
    @param path - The full path of where the database will reside.
 */
- (id)initWithPath:(NSString *)path;

/** 
   Opens the database in reader, writer and truncater mode.
   @param error - The error object. Pass a NULL if not interested in retrieving the possible error.
   @return - YES if successful. No if an error occurred.
 */
- (BOOL)openWithError:(NSError *__autoreleasing)error;

/**
  Opens the database in the specified mode.
  @param mode - The desired mode the db should be opened with. Please see ejdb.h for more information about modes.
  @param error - The error object. Pass a NULL if not interested in retrieving the possible error.
  @return - YES if successful. No if an error occurred.
*/
- (BOOL)openWithMode:(int)mode error:(NSError *__autoreleasing )error;

/**
  Fetches a collection with the name provided.
  @param name - The name of the collection.
  @return - The EJDBCollection object or nil if the collection does not exist in the db.
*/
- (EJDBCollection *)collectionWithName:(NSString *)name;

/**
  Creates the collection with the name provided and default collection options.
  @param name - The desired name of the collection.
  @param error - The error object. Pass a NULL if not interested in retrieving the possible error.
  @return - The EJDBCollection object or nil if the collection could not be created.
*/
- (EJDBCollection *)ensureCollectionWithName:(NSString *)name error:(NSError *__autoreleasing)error;

/**
  Creates the collection with the name and collection options provided.
  @param name - The desired name of the collection.
  @param options - The desired collection options. Please see ejdb.h for more infomration about collection options.
  @param error - The error object. Pass a NULL if not interested in retrieving the possible error.
  @return - The EJDBCollection object or nil if the collection could not be created.
*/
- (EJDBCollection *)ensureCollectionWithName:(NSString *)name options:(EJCOLLOPTS *)options error:(NSError *__autoreleasing)error;

- (EJDBQuery *)createQuery:(NSDictionary *)query forCollection:(EJDBCollection *)collection error:(NSError *__autoreleasing)error;

- (void)close;

@end
