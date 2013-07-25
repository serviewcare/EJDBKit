#import "EJDBDatabase.h"
#import "EJDBCollection.h"

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

- (BOOL)open
{
    return [self openWithMode:JBOWRITER | JBOCREAT | JBOTRUNC];
}

- (BOOL)openWithMode:(int)mode
{
    return ejdbopen(_db, [_dbPath cStringUsingEncoding:NSUTF8StringEncoding], mode);
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

- (EJDBCollection *)createCollectionWithName:(NSString *)name
{
    return [self createCollectionWithName:name options:NULL];
}

- (EJDBCollection *)createCollectionWithName:(NSString *)name options:(EJCOLLOPTS *)options
{
    EJCOLL *coll = ejdbcreatecoll(_db, [name cStringUsingEncoding:NSUTF8StringEncoding],options);
    if (coll != NULL)
    {
        EJDBCollection *collection = [[EJDBCollection alloc]initWithName:name collection:coll];
        return collection;
    }
    return nil;
}

- (void)close
{
    ejdbclose(_db);
    ejdbdel(_db);
}

@end