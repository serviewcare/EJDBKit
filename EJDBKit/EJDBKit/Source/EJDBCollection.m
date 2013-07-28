#import "EJDBCollection.h"
#import "BSONEncoder.h"

@interface EJDBCollection ()
@property (copy,nonatomic) NSString *name;

@end

@implementation EJDBCollection

- (id)initWithName:(NSString *)name collection:(EJCOLL *)collection
{
    self = [super init];
    if (self)
    {
        _name = [name copy];
        _collection = collection;
    }
    return self;
}

- (BOOL)saveObject:(NSDictionary *)dictionary
{
    BSONEncoder *bsonObject = [[BSONEncoder alloc]init];
    [bsonObject encodeDictionary:dictionary];
    [bsonObject finish];
    bson_oid_t oid;
    return ejdbsavebson(_collection, bsonObject.bson, &oid);
}

- (BOOL)saveObjects:(NSArray *)objects
{
    for (NSDictionary *dictionary in objects)
    {
        BSONEncoder *bsonObject = [[BSONEncoder alloc]init];
        [bsonObject encodeDictionary:dictionary];
        [bsonObject finish];
        bson_oid_t oid;
        BOOL success = ejdbsavebson(_collection, bsonObject.bson, &oid);
        if (!success) return NO;
    }
    return YES;
}

@end