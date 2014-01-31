#import "EJDBCollection.h"
#import "BSONEncoder.h"
#import "BSONDecoder.h"
#import "BSONArchiving.h"
#import "EJDBDatabase.h"
#import "EJDBQueryBuilderDelegate.h"

NSString * const EJDBCollectionObjectSavedNotification = @"EJDBCollectionObjectSavedNotification";
NSString * const EJDBCollectionObjectRemovedNotification = @"EJDBCollectionObjectRemovedNotification";

@interface EJDBCollection ()

@end

@implementation EJDBCollection

+ (EJDBCollection *)collectionWithName:(NSString *)collectionName db:(EJDBDatabase *)db
{
    EJCOLL *ejcoll = ejdbgetcoll(db.db, [collectionName cStringUsingEncoding:NSUTF8StringEncoding]);
    if (ejcoll == NULL) return nil;
    EJDBCollection *collection = [[EJDBCollection alloc]initWithName:collectionName db:db];
    [collection openWithCollection:ejcoll];
    return collection;
}

- (id)initWithName:(NSString *)name db:(EJDBDatabase *)db
{
    self = [super init];
    if (self)
    {
        _name = [name copy];
        _db = db;
    }
    return self;
}

- (void)openWithCollection:(EJCOLL *)collection
{
    _collection = collection;
}

- (BOOL)openWithError:(NSError **)error
{
    return [self openWithOptions:NULL error:error];
}

- (BOOL)openWithOptions:(EJDBCollectionOptions *)options error:(NSError **)error
{
    if (_collection) return YES;
    
    _collection = ejdbcreatecoll(_db.db, [_name cStringUsingEncoding:NSUTF8StringEncoding],options);
    
    if (_collection == NULL)
    {
        [_db populateError:error];
        return NO;
    }
    return YES;
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
    if (!OID || [OID isEqual:[NSNull null]]) return NO;
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
   if (!object) return 0;
   return [self saveObjects:@[object]];
}

- (BOOL)saveObjects:(NSArray *)objects
{
    if (!objects) return NO;
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
            [dictionaryToSave setValue:[(id<BSONArchiving>)object type] forKey:@"type"];
        }
        else
        {
            oidStr = [dictionary objectForKey:@"_id"];
        }
        
        if (![oidStr isEqual:[NSNull null]] && oidStr != nil)
        {
            if (![EJDBCollection isValidOID:oidStr]) return NO;
            const char *oidCString = [oidStr cStringUsingEncoding:NSUTF8StringEncoding];
            bson_oid_from_string(&oid, oidCString);
        }
        else
        {
            bson_oid_gen(&oid);
            char oidCString[24];
            bson_oid_to_string(&oid, oidCString);
            dictionaryToSave[@"_id"] = [NSString stringWithCString:oidCString encoding:NSUTF8StringEncoding];
        }
        
        BSONEncoder *bsonObject = [[BSONEncoder alloc]init];
        [bsonObject encodeDictionary:[NSDictionary dictionaryWithDictionary:dictionaryToSave]];
        [bsonObject finish];

        BOOL success = ejdbsavebson(_collection, bsonObject.bson, &oid);
        if (success)
        {
            id savedObject;
            if (!oidStr || [oidStr isEqual:[NSNull null]])
            {
                char str[24];
                bson_oid_to_string(&oid, str);
                oidStr = [NSString stringWithCString:str encoding:NSUTF8StringEncoding];
                if (isArchivable)
                {
                    [object setValue:oidStr forKey:[object oidPropertyName]];
                    savedObject = object;
                }
                else
                {
                    [dictionaryToSave setValue:oidStr forKey:@"_id"];
                    savedObject = dictionaryToSave;
                }
            }
            else
            {
                savedObject = isArchivable ? object : dictionaryToSave;
            }

            NSNotification *notification = [NSNotification notificationWithName:EJDBCollectionObjectSavedNotification
                                                                         object:savedObject
                                                                       userInfo:nil];
            [[NSNotificationCenter defaultCenter]postNotification:notification];
        }
        else return NO;
    }
    return YES;
}

- (int)updateWithQuery:(NSDictionary *)query
{
    return [self updateWithQuery:query hints:NULL];
}

- (int)updateWithQueryBuilder:(id<EJDBQueryBuilderDelegate>)queryBuilder
{
    return [self updateWithQuery:[queryBuilder query] hints:[queryBuilder hints]];
}

- (int)updateWithQuery:(NSDictionary *)query hints:(NSDictionary *)hints
{
    NSDictionary *theQuery = [query count] == 0 ? NULL : query;
    if (theQuery == nil) return 0;
    NSDictionary *theHints = [hints count] == 0 ? NULL : hints;
    BSONEncoder *queryBsonEncoder = [[BSONEncoder alloc]initAsQuery];
    [queryBsonEncoder encodeDictionary:theQuery];
    [queryBsonEncoder finish];
    bson *queryHints = NULL;
    if (theHints)
    {
        BSONEncoder *queryHintsBsonEncoder = [[BSONEncoder alloc]initAsQuery];
        [queryBsonEncoder encodeDictionary:theHints];
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
    
    if (ejdbrmbson(_collection, &oid))
    {
        [self synchronize];
        NSNotification *notification = [NSNotification notificationWithName:EJDBCollectionObjectRemovedNotification
                                                                     object:OID userInfo:nil];
        [[NSNotificationCenter defaultCenter]postNotification:notification];
        return YES;
    }
    return NO;
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