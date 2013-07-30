#import "EJDBCollection.h"
#import "BSONEncoder.h"
#import "BSONDecoder.h"

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

+ (BOOL)isSupportedObject:(id)object
{
    BOOL isArchivable = [object conformsToProtocol:@protocol(BSONArchiving)];
    BOOL isDictionary = [object isKindOfClass:[NSDictionary class]];
    
    if (!isArchivable && !isDictionary)
    {
        return NO;
    }
    return YES;
}

+ (BOOL)isValidOID:(NSString *)OID
{
    if (!OID) return NO;
    const char *oidCString = [OID cStringUsingEncoding:NSUTF8StringEncoding];
    if (!ejdbisvalidoidstr(oidCString)) return NO;
    return YES;
}

- (id)fetchObjectWithOID:(NSString *)OID
{
    if (![EJDBCollection isValidOID:OID]) return nil;
    
    bson_oid_t oid;
    bson_oid_from_string(&oid, [OID cStringUsingEncoding:NSUTF8StringEncoding]);
    bson *bsonObj = ejdbloadbson(_collection, &oid);
    if (bsonObj == NULL) return nil;
    BSONDecoder *bsonDecoder = [[BSONDecoder alloc]init];
    return [bsonDecoder decodeObjectFromBSON:bsonObj];
}

- (BOOL)saveObject:(id)object
{
   return [self saveObjects:@[object]];
}

- (BOOL)saveObjects:(NSArray *)objects
{
    for (id object in objects)
    {
        if (![EJDBCollection isSupportedObject:object]) return NO;
 
        NSDictionary *dictionary = [object respondsToSelector:@selector(toDictionary)] ? [object toDictionary] : object;
        BOOL isArchivable = [object conformsToProtocol:@protocol(BSONArchiving)];
        bson_oid_t oid;
        NSString *oidStr;
        NSMutableDictionary *dictionaryToSave = [NSMutableDictionary dictionaryWithDictionary:dictionary];
        
        if (isArchivable && [object respondsToSelector:@selector(oidPropertyName)])
        {
            oidStr = [object valueForKey:[object oidPropertyName]];
            if (!oidStr) oidStr = [dictionary valueForKey:@"_id"];
            if (oidStr) [dictionaryToSave setValue:oidStr forKey:@"_id"];
        }
        else
        {
            oidStr = [dictionary objectForKey:@"_id"];
        }
        
        if (oidStr)
        {
            if (![EJDBCollection isValidOID:oidStr]) return NO;
            const char *oidCString = [oidStr cStringUsingEncoding:NSUTF8StringEncoding];
            bson_oid_from_string(&oid, oidCString);
        }
        
        BSONEncoder *bsonObject = [[BSONEncoder alloc]init];
        [bsonObject encodeDictionary:[NSDictionary dictionaryWithDictionary:dictionaryToSave]];
        [bsonObject finish];

        BOOL success = ejdbsavebson(_collection, bsonObject.bson, &oid);
        if (!success) return NO;
    }
    
    return YES;
}

- (int)updateWithQuery:(NSDictionary *)query
{
    return [self updateWithQuery:query hints:NULL];
}

- (int)updateWithQuery:(NSDictionary *)query hints:(NSDictionary *)hints
{
    BSONEncoder *queryBsonEncoder = [[BSONEncoder alloc]initAsQuery];
    [queryBsonEncoder encodeDictionary:query];
    [queryBsonEncoder finish];
    bson *queryHints = NULL;
    if (hints)
    {
        BSONEncoder *queryHintsBsonEncoder = [[BSONEncoder alloc]initAsQuery];
        [queryBsonEncoder encodeDictionary:hints];
        [queryBsonEncoder finish];
        queryHints = queryHintsBsonEncoder.bson;
    }
    return ejdbupdate(_collection, queryBsonEncoder.bson, NULL, 0, queryHints, NULL);
}

- (BOOL)removeObject:(id)object
{
    BOOL isDictionary = [object isKindOfClass:[NSDictionary class]];
    BOOL isArchivable = [object conformsToProtocol:@protocol(BSONArchiving)];
    NSString *oid = nil;
    
    if (!isDictionary && !isArchivable) return NO;
    
    if (isDictionary)
    {
        oid = [object objectForKey:@"_id"];
        if (!oid) return NO;
    }
    else
    {
        oid = [object valueForKey:[object oidPropertyName]];
    }

    return [self removeObjectWithOID:oid];
}


- (BOOL)removeObjectWithOID:(NSString *)OID
{
    if (![EJDBCollection isValidOID:OID]) return NO;
    bson_oid_t oid;
    bson_oid_from_string(&oid, [OID cStringUsingEncoding:NSUTF8StringEncoding]);
    return ejdbrmbson(_collection, &oid);
}

- (BOOL)setIndexOption:(EJDBIndexOptions)options forFieldPath:(NSString *)fieldPath
{
    return ejdbsetindex(_collection,[fieldPath cStringUsingEncoding:NSUTF8StringEncoding], options);
}

- (BOOL)synchronize
{
    return ejdbsyncoll(_collection);
}

@end