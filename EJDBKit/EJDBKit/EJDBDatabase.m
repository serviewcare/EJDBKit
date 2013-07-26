#import "EJDBDatabase.h"
#import "BSONEncoder.h"
#import "EJDBCollection.h"
#import "EJDBQuery.h"

@interface EJDBDatabase ()
@property (copy,nonatomic) NSString *dbPath;
@end

@implementation EJDBDatabase

- (id)initWithPath:(NSString *)path
{
    self = [super init];
    if (self)
    {
        _db = ejdbnew();
        _dbPath = [path copy];
    }
    return self;
}

- (BOOL)openWithError:(NSError *__autoreleasing)error
{
    return [self openWithMode:(JBOWRITER | JBOCREAT | JBOTRUNC) error:error];
}

- (BOOL)openWithMode:(int)mode error:(NSError *__autoreleasing)error
{
    BOOL success = ejdbopen(_db, [_dbPath cStringUsingEncoding:NSUTF8StringEncoding], mode);
    if (!success) [self populateError:error];
    return success;
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

- (EJDBQuery *)createQuery:(NSDictionary *)query forCollection:(EJDBCollection *)collection error:(NSError *__autoreleasing)error
{
    BSONEncoder *bsonQuery = [[BSONEncoder alloc]initAsQuery];
    [bsonQuery encodeDictionary:query];
    [bsonQuery finish];
    EJQ *ejqQuery = ejdbcreatequery(_db, bsonQuery.bson, NULL, 0, NULL);
    if (ejqQuery == NULL)
    {
        error = [NSError errorWithDomain:@"jdubd.me.ejdbkit" code:1 userInfo:@{NSLocalizedDescriptionKey: @"couldn't create query!"}];
        return nil;
    }
    EJDBQuery *ejdbQuery = [[EJDBQuery alloc]initWithEJQuery:ejqQuery collection:collection];
    return ejdbQuery;
}

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