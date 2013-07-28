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
       bson_iterator iterator;
       bson_iterator_init(&iterator, data);
       BSONDecoder *bsonDecoder = [[BSONDecoder alloc]init];
       NSDictionary *dict = [bsonDecoder decodeFromIterator:iterator];
       NSString *type = [dict objectForKey:@"type"];
       if (type)
       {
            Class aClass = NSClassFromString(type);
            id obj = [[aClass alloc]init];
            NSAssert([obj conformsToProtocol:@protocol(BSONArchiving)],@"Custom class must conform to the BSONArchiving protocol!");
            NSMutableDictionary *modifiedDict = [NSMutableDictionary dictionaryWithDictionary:dict];
            [modifiedDict removeObjectForKey:@"type"];
            NSString *oid = [modifiedDict objectForKey:@"_id"];
            if (oid)
            {
                [modifiedDict setValue:[modifiedDict objectForKey:@"_id"] forKey:[obj oidPropertyName]];
                [modifiedDict removeObjectForKey:@"_id"];
            }
            [obj fromDictionary:[NSDictionary dictionaryWithDictionary:modifiedDict]];
            [results addObject:obj];
       }
       else
       {
           [results addObject:dict];
       }
       
       bson_del(data);
    }
    ejdbquerydel(_ejQuery);
    return [NSArray arrayWithArray:results];
}

@end