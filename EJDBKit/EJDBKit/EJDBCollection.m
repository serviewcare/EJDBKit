#import "EJDBCollection.h"
#import "BSONObject.h"

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

- (BOOL)saveObject:(BSONObject *)bsonObject
{
    [bsonObject finish];
    bson_oid_t oid;
    return ejdbsavebson(_collection, bsonObject.bson, &oid);
}

@end
