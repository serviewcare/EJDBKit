#import "EJDBQuery.h"
#import "EJDBCollection.h"
#import "BSONDecoder.h"

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

- (void)execute
{
    uint32_t count = 0;
    TCLIST *r = ejdbqryexecute(_collection.collection, _ejQuery, &count, 0, NULL);
    NSMutableArray *array = [[NSMutableArray alloc]init];
    
    for (int i = 0; i < TCLISTNUM(r);i++)
    {
       void *p =  TCLISTVALPTR(r, i);
       bson *data = bson_create();
       bson_init_with_data(data, p);
       bson_iterator iterator;
       bson_iterator_init(&iterator, data);
       BSONDecoder *bsonDecoder = [[BSONDecoder alloc]init];
       NSDictionary *dict = [bsonDecoder decodeFromIterator:iterator];
       //NSLog(@"dict %@",dict);
       [array addObject:dict];
       bson_del(data);
    }
    ejdbquerydel(_ejQuery);
}

@end
