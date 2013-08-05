#import "EJDBQuery.h"
#import "EJDBCollection.h"
#import "BSONDecoder.h"
#import "BSONArchiving.h"

@interface EJDBQuery ()
@property (strong,nonatomic) EJDBCollection *collection;
@property (assign,nonatomic) u_int32_t recordCount;
@end

@implementation EJDBQuery

- (id)initWithEJQuery:(EJQ *)query collection:(EJDBCollection *)collection
{
    self = [super init];
    if (self)
    {
        _ejQuery = query;
        _collection = collection;
    }
    return self;
}

- (int)fetchCount
{
    [self fetchWithOptions:EJDBQueryCountOnly];
    return _recordCount;
}

- (id)fetchObject
{
    NSArray *array = [self fetchWithOptions:EJDBQueryFetchFirstOnly];
    if ([array count] > 0) return array[0];
    return nil;
}

- (NSArray *)fetchObjects
{
    return [self fetchWithOptions:0];
}

- (NSArray *)fetchWithOptions:(EJDBQueryOptions)queryOptions
{
    TCLIST *r = ejdbqryexecute(_collection.collection, _ejQuery, &_recordCount, queryOptions, NULL);
    NSMutableArray *results = [[NSMutableArray alloc]init];
    for (int i = 0; i < TCLISTNUM(r);i++)
    {
       void *p =  TCLISTVALPTR(r, i);
       bson *data = bson_create();
       bson_init_with_data(data, p);
       BSONDecoder *bsonDecoder = [[BSONDecoder alloc]init];
       id obj = [bsonDecoder decodeObjectFromBSON:data];
       [results addObject:obj];
       bson_del(data);
    }
    ejdbquerydel(_ejQuery);
    free(r);
    return [NSArray arrayWithArray:results];
}

@end