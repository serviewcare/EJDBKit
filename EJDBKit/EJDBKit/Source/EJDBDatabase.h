#import <Foundation/Foundation.h>
#include "tcejdb/ejdb.h"

@class EJDBCollection;
@class EJDBQuery;

/** Transaction block definition. Used for executing statements in transaction. 
 @return YES - if you'd like to commit the transaction. NO - if you'd like to abort it.
 */
typedef BOOL(^EJDBTransactionBlock)(EJDBCollection *collection);

/**
 This class wraps the EJDB object and provides the ability to manipulate the underlying db,collections,etc.
*/
@interface EJDBDatabase : NSObject

/** The underlying EJDB object. */
@property (assign,nonatomic,readonly) EJDB *db;

/** 
 Initializes the object with the path of the db.
 @param path - The full path of where the database will reside excluding the database file name.
 @param fileName - The file name (without path) of the database file.
 @discussion - The fileName is appended to path. If the path does not exist it is created.
*/
- (id)initWithPath:(NSString *)path dbFileName:(NSString *)fileName;

/** 
 Opens the database in reader, writer and create mode.
 @param error - The error object. Pass a NULL if not interested in retrieving the possible error.
 @return - YES if successful. NO if an error occurred.
*/
- (BOOL)openWithError:(NSError *__autoreleasing)error;

/**
 Opens the database in the specified mode.
 @param mode - The desired mode the db should be opened with. Please see ejdb.h for more information about modes.
 @param error - The error object. Pass a NULL if not interested in retrieving the possible error.
 @return - YES if successful. NO if an error occurred.
*/
- (BOOL)openWithMode:(int)mode error:(NSError *__autoreleasing )error;

/**
 Check if the database is open or not.
 @return - YES if open. NO if not.
*/
- (BOOL)isOpen;

/**
 Gets a dictionary of data about the database such as collections and their respective indexes, options,etc.
*/
- (NSDictionary *)metadata;

/**
 Get a list of the collection's names in the database.
 @param - Array of collection names.
*/
- (NSArray *)collectionNames;

/**
 Fetches a collection with the name provided.
 @param name - The name of the collection.
 @return - The EJDBCollection object or nil if the collection does not exist in the db.
*/
- (EJDBCollection *)collectionWithName:(NSString *)name;

/** 
 Fetches a list of EJDBCollection objects that exist and are currently open.
 @return - Array of EJDBCollection objects or nil if there was an error.
*/
- (NSArray *)collections;

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

/**
 Removes the collection from the db with the provided name and the associated db files/indexes.
 @param name - The name of the collection to remove.
 @return - YES if removal succeeded. NO if not.
*/
- (BOOL)removeCollectionWithName:(NSString *)name;

/**
 Removes the collection from the db with the provided name with the option of removing associated db files/indexes.
 @param name - The name of the collection to remove.
 @param unlinkFile - Pass YES if you want associated db files/indexes to removed. NO if not.
 @return - YES if removal succeeded. NO if not.
*/
- (BOOL)removeCollectionWithName:(NSString *)name unlinkFile:(BOOL)unlinkFile;

/**
 Finds all objects that match the criteria passed in the query object but with no query hints.
 Please look at json.h for more info on queries and query hints.
 
 @param query - The query dictionary. Must be encodable by BSONEncoder.
 @param collection - The collection to query.
 @param error - The error object. Pass a NULL if not interested in retrieving the possible error.
 @return - Array of objects matching the criteria or nil if there was an error.   
*/

- (NSArray *)findObjectsWithQuery:(NSDictionary *)query inCollection:(EJDBCollection *)collection error:(NSError *__autoreleasing)error;

/**
 Finds all objects that match the criteria passed in the query object but with no query hints.
 Please look at json.h for more info on queries and query hints.
 
 @param query - The query dictionary. Must be encodable by BSONEncoder.
 @param hints - The query hints.
 @param collection - The collection to query.
 @param error - The error object. Pass a NULL if not interested in retrieving the possible error.
 @return - Array of objects matching the criteria or nil if there was an error.
*/

- (NSArray *)findObjectsWithQuery:(NSDictionary *)query hints:(NSDictionary *)queryHints inCollection:(EJDBCollection *)collection
                            error:(NSError *__autoreleasing)error;

/**
 Executes the statements by the provided EJDBTransactionBlock as a transaction.
 The block gives you access to the EJDBCollection specified in the collection argument.
 The block must return either a YES, if you'd like to commit the transaction or NO if you'd like to abort it.
 
 @param collection - The collection the transaction will occur in.
 @param transaction - The EJDBTransactiobBlock, this is where your inserts/updates/etc go.
 @return - nil if the transaction occurred with no errors or an NSError if an error occurred.
 
*/
- (NSError *)transactionInCollection:(EJDBCollection *)collection transaction:(EJDBTransactionBlock)transaction;

/** Close the database. */
- (void)close;

@end
