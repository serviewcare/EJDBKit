#import "EJDBQuery.h"
#import "EJDBCollection.h"
#import "BSONDecoder.h"
#import "BSONArchiving.h"

@interface EJDBQuery ()
@property (strong,nonatomic) EJDBCollection *collection;
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

- (id)fetchObject
{
    NSArray *array = [self fetchWithFlags:JBQRYFINDONE];
    if ([array count] > 0) return array[0];
    return nil;
}

- (NSArray *)fetchObjects
{
    return [self fetchWithFlags:0];
}

- (NSArray *)fetchWithFlags:(int)queryFlags
{
    uint32_t count = 0;
    TCLIST *r = ejdbqryexecute(_collection.collection, _ejQuery, &count, queryFlags, NULL);
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