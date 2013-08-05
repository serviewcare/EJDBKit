#import "EJDBDatabase.h"
#import "BSONEncoder.h"
#import "BSONDecoder.h"
#import "EJDBCollection.h"
#import "EJDBQuery.h"

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
        _dbPath = [path copy];
        _dbFileName = [fileName copy];
    }
    return self;
}

- (BOOL)openWithError:(NSError **)error
{
    return [self openWithMode:( JBOREADER | JBOWRITER | JBOCREAT) error:error];
}

- (BOOL)openWithMode:(EJDBOpenModes)mode error:(NSError **)error
{
    BOOL success = YES;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:_dbPath])
    {
        success = [fileManager createDirectoryAtPath:_dbPath withIntermediateDirectories:YES attributes:NULL error:error];
        if (!success)
        {
            return NO;
        }
    }
    NSString *dbFilePath = [_dbPath stringByAppendingPathComponent:_dbFileName];
    if (!_db)
    {
      _db = ejdbnew();
      if (_db == NULL) return NO;
    }
    success = ejdbopen(_db, [dbFilePath cStringUsingEncoding:NSUTF8StringEncoding], mode);
    if (!success) [self populateError:error];
    return success;
}

- (BOOL)isOpen
{
    return ejdbisopen(_db);
}

- (NSDictionary *)metadata
{
   bson *bson = ejdbmeta(_db);
   BSONDecoder *decoder = [[BSONDecoder alloc]init];
   NSDictionary *metaDataDictionary = [decoder decodeObjectFromBSON:bson];
   return metaDataDictionary;
}

- (NSArray *)collectionNames
{
    NSDictionary *metadata = [self metadata];
    NSMutableArray *collectionNames = [NSMutableArray array];
    for (NSDictionary *collection in [metadata objectForKey:@"collections"])
    {
        [collectionNames addObject:[collection objectForKey:@"name"]];
    }
    return collectionNames;
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
    for (NSString *collectionName in [self collectionNames])
    {
        EJDBCollection *collection = [self collectionWithName:collectionName];
        if (collection) [openCollections addObject:collection];
    }
    return openCollections;
}

- (EJDBCollection *)ensureCollectionWithName:(NSString *)name error:(NSError **)error
{
    return [self ensureCollectionWithName:name options:NULL error:error];
}

- (EJDBCollection *)ensureCollectionWithName:(NSString *)name options:(EJCOLLOPTS *)options error:(NSError **)error
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

- (NSArray *)findObjectsWithQuery:(NSDictionary *)query inCollection:(EJDBCollection *)collection error:(NSError **)error
{
    return [self findObjectsWithQuery:query hints:nil inCollection:collection error:error];
}

- (NSArray *)findObjectsWithQuery:(NSDictionary *)query hints:(NSDictionary *)queryHints inCollection:(EJDBCollection *)collection
                            error:(NSError **)error
{
    EJDBQuery *ejdbQuery = [self createQuery:query hints:queryHints forCollection:collection error:error];
    return [ejdbQuery fetchObjects];
}

- (EJDBQuery *)createQuery:(NSDictionary *)query forCollection:(EJDBCollection *)collection error:(NSError **)error
{
    return [self createQuery:query hints:nil forCollection:collection error:error];
}

- (EJDBQuery *)createQuery:(NSDictionary *)query hints:(NSDictionary *)queryHints forCollection:(EJDBCollection *)collection error:(NSError **)error
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
    return ejdbQuery;
}

- (BOOL)transactionInCollection:(EJDBCollection *)collection error:(NSError **)error transaction:(EJDBTransactionBlock)transaction
{
    if(ejdbtranbegin(collection.collection))
    {
        BOOL shouldCommit = transaction(collection,error);
        if (error) return NO;
        if (shouldCommit)
        {
            if(!ejdbtrancommit(collection.collection))
            {
                [self populateError:error];
                return NO;
            }
            ejdbsyncdb(_db);
        }
        else
        {
            if(!ejdbtranabort(collection.collection))
            {
                [self populateError:error];
                return NO;
            }
        }
    }
    else
    {
        [self populateError:error];
        return NO;
    }
    return YES;
}

- (int)errorCode
{
    return ejdbecode(_db);
}

- (NSString *)errorMessageFromCode:(int)errorCode
{
    return [NSString stringWithCString:ejdberrmsg(errorCode) encoding:NSUTF8StringEncoding];
}

- (void)populateError:(NSError **)error
{
    if (error != NULL)
    {
        int errorCode = [self errorCode];
        *error = [NSError errorWithDomain:@"com.softmotions.ejdbkit"
                                    code:errorCode userInfo:@{NSLocalizedDescriptionKey : [self errorMessageFromCode:errorCode]}];
    }
}

- (void)close
{
    ejdbclose(_db);
    ejdbdel(_db);
}

@end