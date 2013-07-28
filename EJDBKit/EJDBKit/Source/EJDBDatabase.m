#import "EJDBDatabase.h"
#import "BSONEncoder.h"
#import "EJDBCollection.h"
#import "EJDBQuery.h"

/* 
   Yes...I'm doing something unholy here but I need to know some things that I can't get from ejdb.h.
   Example: How the hell do I get a name of a collection??? This smells bad, I will have to talk to the folks over at softmotions
   but for now, it's the only solution I can come up with.
 */
#include "tcejdb/ejdb_private.h"

@interface EJDBDatabase ()
@property (copy,nonatomic) NSString *dbPath;
@property (copy,nonatomic) NSString *dbFileName;
@end

@implementation EJDBDatabase

- (id)initWithPath:(NSString *)path dbFileName:(NSString *)fileName
{
    self = [super init];
    if (self)
    {
        _db = ejdbnew();
        _dbPath = [path copy];
        _dbFileName = [fileName copy];
    }
    return self;
}

- (BOOL)openWithError:(NSError *__autoreleasing)error
{
    return [self openWithMode:( JBOREADER | JBOWRITER | JBOCREAT) error:error];
}

- (BOOL)openWithMode:(int)mode error:(NSError *__autoreleasing)error
{
    BOOL success = YES;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:_dbPath])
    {
        success = [fileManager createDirectoryAtPath:_dbPath withIntermediateDirectories:YES attributes:NULL error:&error];
        if (!success)
        {
            [NSException raise:@"Could not create db path!" format:@"Error is: %@",error.localizedDescription];
            return NO;
        }
    }
    NSString *dbFilePath = [_dbPath stringByAppendingPathComponent:_dbFileName];
    success = ejdbopen(_db, [dbFilePath cStringUsingEncoding:NSUTF8StringEncoding], mode);
    if (!success) [self populateError:error];
    return success;
}

- (BOOL)isOpen
{
    return ejdbisopen(_db);
}

- (EJDBCollection *)collectionWithName:(NSString *)name
{
    EJCOLL *coll = ejdbgetcoll(_db, [name cStringUsingEncoding:NSUTF8StringEncoding]);
    if (coll != NULL)
    {
        EJDBCollection *collection = [[EJDBCollection alloc]initWithName:name collection:coll];
        return collection;
    }
    return nil;
}

- (NSArray *)collections
{
    NSMutableArray *openCollections = [NSMutableArray array];
    TCLIST *collectionList = ejdbgetcolls(_db);
    if (collectionList != NULL)
    {
        for (int i = 0; i < TCLISTNUM(collectionList); i++)
        {
            EJCOLL *coll = TCLISTVALPTR(collectionList, i);
            /* coll->cname just doesn't feel right. Look at top of this file for explanation. */
            NSString *collectionName = [NSString stringWithCString:coll->cname encoding:NSUTF8StringEncoding];
            EJDBCollection *collection = [[EJDBCollection alloc]initWithName:collectionName collection:coll];
            [openCollections addObject:collection];
        }
        tclistdel(collectionList);
        return [NSArray arrayWithArray:openCollections];
    }
    return nil;
}

- (EJDBCollection *)ensureCollectionWithName:(NSString *)name error:(NSError *__autoreleasing)error
{
    return [self ensureCollectionWithName:name options:NULL error:error];
}

- (EJDBCollection *)ensureCollectionWithName:(NSString *)name options:(EJCOLLOPTS *)options error:(NSError *__autoreleasing)error
{
    EJCOLL *coll = ejdbcreatecoll(_db, [name cStringUsingEncoding:NSUTF8StringEncoding],options);
    if (coll == NULL)
    {
        [self populateError:error];
        return nil;
    }
    EJDBCollection *collection = [[EJDBCollection alloc]initWithName:name collection:coll];
    return collection;
}

- (BOOL)removeCollectionWithName:(NSString *)name
{
    return [self removeCollectionWithName:name unlinkFile:YES];
}

- (BOOL)removeCollectionWithName:(NSString *)name unlinkFile:(BOOL)unlinkFile
{
    return ejdbrmcoll(_db, [name cStringUsingEncoding:NSUTF8StringEncoding], unlinkFile);
}

- (NSArray *)findObjectsWithQuery:(NSDictionary *)query inCollection:(EJDBCollection *)collection error:(NSError *__autoreleasing)error
{
    return [self findObjectsWithQuery:query hints:nil inCollection:collection error:error];
}

- (NSArray *)findObjectsWithQuery:(NSDictionary *)query hints:(NSDictionary *)queryHints inCollection:(EJDBCollection *)collection
                            error:(NSError *__autoreleasing)error
{
    BSONEncoder *bsonQuery = [[BSONEncoder alloc]initAsQuery];
    [bsonQuery encodeDictionary:query];
    [bsonQuery finish];
    BSONEncoder *bsonHints;
    BOOL isHintsNull = queryHints == nil ? YES : NO;
    if (!isHintsNull)
    {
        bsonHints = [[BSONEncoder alloc]initAsQuery];
        [bsonHints encodeDictionary:queryHints];
        [bsonHints finish];
    }
    EJQ *ejq = ejdbcreatequery(_db, bsonQuery.bson, NULL, 0, !isHintsNull ? bsonHints.bson : NULL);
    if (ejq == NULL)
    {
        [self populateError:error];
        return nil;
    }
    EJDBQuery *ejdbQuery = [[EJDBQuery alloc]initWithEJQuery:ejq collection:collection];
    return [ejdbQuery fetchObjects];
}


/*
- (EJDBQuery *)createQuery:(NSDictionary *)query forCollection:(EJDBCollection *)collection error:(NSError *__autoreleasing)error
{
    BSONEncoder *bsonQuery = [[BSONEncoder alloc]initAsQuery];
    [bsonQuery encodeDictionary:query];
    [bsonQuery finish];
    EJQ *ejqQuery = ejdbcreatequery(_db, bsonQuery.bson, NULL, 0, NULL);
    if (ejqQuery == NULL)
    {
        [self populateError:error];
        return nil;
    }
    EJDBQuery *ejdbQuery = [[EJDBQuery alloc]initWithEJQuery:ejqQuery collection:collection];
    return ejdbQuery;
}
*/

- (int)errorCode
{
    return ejdbecode(_db);
}

- (NSString *)errorMessageFromCode:(int)errorCode
{
    return [NSString stringWithCString:ejdberrmsg(errorCode) encoding:NSUTF8StringEncoding];
}

- (void)populateError:(NSError *)error
{
    if (error != NULL)
    {
        int errorCode = [self errorCode];
        error = [NSError errorWithDomain:@"com.softmotions.ejdbkit"
                                    code:errorCode userInfo:@{NSLocalizedDescriptionKey : [self errorMessageFromCode:errorCode]}];
    }
}


- (void)close
{
    ejdbclose(_db);
    ejdbdel(_db);
}

@end