#import "EJDBQuery.h"
#import "EJDBDatabase.h"
#import "EJDBCollection.h"
#import "BSONEncoder.h"
#import "BSONDecoder.h"
#import "BSONArchiving.h"
#import "EJDBQueryBuilderDelegate.h"
#import "EJDBModel.h"

@interface EJDBQuery ()
@property (strong,nonatomic) EJDBCollection *collection;
@property (assign,nonatomic) uint32_t recordCount;
@end

@implementation EJDBQuery

- (id)initWithCollection:(EJDBCollection *)collection query:(NSDictionary *)query hints:(NSDictionary *)hints
{
    self = [super init];
    
    if (self)
    {
        _collection = collection;
        [self setQuery:query];
        [self setHints:hints];
    }
    return self;
}

- (id)initWithCollection:(EJDBCollection *)collection query:(NSDictionary *)query
{
    return [self initWithCollection:collection query:query hints:nil];
}

- (id)initWithCollection:(EJDBCollection *)collection queryBuilder:(id<EJDBQueryBuilderDelegate>)queryBuilder
{
    return [self initWithCollection:collection query:[queryBuilder query] hints:[queryBuilder hints]];
}

- (uint32_t)recordCount
{
    return _recordCount;
}

- (int)fetchCount
{
    return [self fetchCountWithError:NULL];
}

- (uint32_t)fetchCountWithError:(NSError **)error
{
    uint32_t recordCount;
    EJQ *qry = [self createQueryWithError:error];
    if (!qry) return 0;
    ejdbqryexecute(_collection.collection, qry, &recordCount, EJDBQueryCountOnly, NULL);
    ejdbquerydel(qry);
    return recordCount;
}

- (id)fetchObject
{
   return [self fetchObjectWithError:NULL];
}

- (id)fetchObjectWithError:(NSError **)error
{
    NSArray *array = [self fetchWithOptions:EJDBQueryFetchFirstOnly error:error];
    if ([array count] > 0) return array[0];
    return nil;
}

- (NSArray *)fetchObjects
{
    return [self fetchObjectsWithError:NULL];
}

- (NSArray *)fetchObjectsWithError:(NSError **)error
{
    return [self fetchWithOptions:0 error:error];
}

- (NSArray *)fetchWithOptions:(EJDBQueryOptions)queryOptions error:(NSError **)error
{
    EJQ *qry = [self createQueryWithError:error];
    if (!qry) return nil;
    
    TCLIST *r = ejdbqryexecute(_collection.collection, qry, &_recordCount, queryOptions, NULL);
    
    NSMutableArray *results = [[NSMutableArray alloc]init];
    for (int i = 0; i < TCLISTNUM(r);i++)
    {
        void *p =  TCLISTVALPTR(r, i);
        bson *data = bson_create();
        bson_init_with_data(data, p);
        BSONDecoder *bsonDecoder = [[BSONDecoder alloc]init];
        id obj = [bsonDecoder decodeObjectFromBSON:data];
        if ([obj isKindOfClass:[NSDictionary class]])
        {
            NSString *type = [obj valueForKey:@"type"];
            if (type)
            {
                Class class = NSClassFromString(type);
                if ([class isSubclassOfClass:[EJDBModel class]])
                {
                    id modelObject = [[class alloc]initWithDatabase:self.collection.db];
                    [modelObject fromDictionary:obj];
                    [results addObject:modelObject];
                }
            }
            else
            {
                [results addObject:obj];
            }
        }
        else
        {
            [results addObject:obj];
        }
        bson_del(data);
    }
    tcfree(r);
    ejdbquerydel(qry);
    return [NSArray arrayWithArray:results];
}

- (BSONEncoder *)queryBSON
{
    BSONEncoder *bsonQuery = [[BSONEncoder alloc]initAsQuery];
    if (_query == nil) [self setQuery:@{}];
    [bsonQuery encodeDictionary:_query];
    [bsonQuery finish];
    return bsonQuery;
}

- (BSONEncoder *)hintsBSON
{
    if (_hints != nil && [_hints count] > 0)
    {
        BSONEncoder *bsonHints = [[BSONEncoder alloc]initAsQuery];
        [bsonHints encodeDictionary:_hints];
        [bsonHints finish];
        return bsonHints;
    }
    return NULL;
}

- (EJQ *)createQueryWithError:(NSError **)error
{
    BSONEncoder *query = [self queryBSON];
    BSONEncoder *hints = [self hintsBSON];
    
    EJQ *ejq = ejdbcreatequery(_collection.db.db, query.bson, NULL, 0, hints.bson);
    if (ejq == NULL)
    {
        [_collection.db populateError:error];
        return nil;
    }
    return ejq;
}

@end