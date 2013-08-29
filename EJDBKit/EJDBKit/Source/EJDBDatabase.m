#import "EJDBDatabase.h"
#import "BSONEncoder.h"
#import "BSONDecoder.h"
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
    return [self openWithMode:( EJDBOpenReader | EJDBOpenWriter | EJDBOpenCreator) error:error];
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
    return [NSArray arrayWithArray:collectionNames];
}


- (EJDBCollection *)collectionWithName:(NSString *)name
{
    return [EJDBCollection collectionWithName:name db:self];    
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

- (EJDBCollection *)ensureCollectionWithName:(NSString *)name options:(EJDBCollectionOptions *)options error:(NSError **)error
{
    EJDBCollection *collection = [[EJDBCollection alloc]initWithName:name db:self];
    if (![collection openWithOptions:options error:error]) return nil;
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
    EJDBQuery *ejdbQuery = [self createQuery:query hints:queryHints forCollection:collection];
    return [ejdbQuery fetchObjectsWithError:error];
}

- (EJDBQuery *)createQuery:(NSDictionary *)query forCollection:(EJDBCollection *)collection error:(NSError **)error
{
    return [self createQuery:query hints:nil forCollection:collection];
}

- (EJDBQuery *)createQuery:(NSDictionary *)query hints:(NSDictionary *)queryHints forCollection:(EJDBCollection *)collection
{
    EJDBQuery *ejdbQuery = [[EJDBQuery alloc]initWithCollection:collection query:query hints:queryHints];
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
            ejdbsyncoll(collection.collection);
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

- (BOOL)exportCollections:(NSArray *)collections toDirectory:(NSString *)path asJSON:(BOOL)asJSON
{
    BOOL success = YES;
    
    if ([collections count] > 0)
    {
        TCLIST *cnames = tclistnew2([collections count]);
        for (NSString *collectionName in collections)
        {
            tclistpush2(cnames, [collectionName cStringUsingEncoding:NSUTF8StringEncoding]);
        }
        const char *cPath = [path cStringUsingEncoding:NSUTF8StringEncoding];
        int flags = asJSON;
        success = ejdbexport(_db, cPath, cnames, flags, NULL);
        tclistdel(cnames);
    }
    
    return success;
}

- (BOOL)exportAllCollectionsToDirectory:(NSString *)path asJSON:(BOOL)asJSON
{
    BOOL success = YES;
    const char *cPath = [path cStringUsingEncoding:NSUTF8StringEncoding];
    int flags = asJSON;
    success = ejdbexport(_db, cPath, NULL, flags, NULL);
    return success;
}

- (BOOL)importCollections:(NSArray *)collections fromDirectory:(NSString *)path options:(EJDBImportOptions)options
{
    BOOL success = YES;
    
    if ([collections count] > 0)
    {
        TCLIST *cnames = tclistnew2([collections count]);
        for (NSString *collectionName in collections)
        {
            tclistpush2(cnames, [collectionName cStringUsingEncoding:NSUTF8StringEncoding]);
        }
        const char *cPath = [path cStringUsingEncoding:NSUTF8StringEncoding];
        int flags = options;
        success = ejdbimport(_db, cPath, cnames, flags, NULL);
        tclistdel(cnames);
    }
    
    return success;
}

- (BOOL)importAllCollectionsFromDirectory:(NSString *)path options:(EJDBImportOptions)options
{
    BOOL success = YES;
    const char *cPath = [path cStringUsingEncoding:NSUTF8StringEncoding];
    int flags = options;
    success = ejdbimport(_db, cPath, NULL, flags, NULL);
    return success;
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