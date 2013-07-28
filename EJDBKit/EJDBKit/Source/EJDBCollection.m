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

- (BOOL)saveObject:(id)object
{
   return [self saveObjects:@[object]];
}

- (BOOL)saveObjects:(NSArray *)objects
{
    for (id object in objects)
    {
        BOOL isArchivable = [object conformsToProtocol:@protocol(BSONArchiving)];
        BOOL isDictionary = [object isKindOfClass:[NSDictionary class]];
        
        if (!isArchivable && !isDictionary)
        {
            NSException *exception = [NSException exceptionWithName:@"Unsupported Type!"
                                                             reason:@"The object to save must be either a Dictionary or a class that adopts the BSONArchiving protocol!"
                                                           userInfo:nil];
            @throw exception;
        }

        NSDictionary *dictionaryToSave;
 
        dictionaryToSave = isArchivable ? [object toDictionary] : object;
        bson_oid_t oid;
        NSString *oidStr = [dictionaryToSave objectForKey:@"_id"];
        if (oidStr)
        {
            const char *oidCString = [oidStr cStringUsingEncoding:NSUTF8StringEncoding];
            if (!ejdbisvalidoidstr(oidCString))
            {
                NSException *exception = [NSException exceptionWithName:@"Invalid OID value!"                                                                 reason:[NSString stringWithFormat:@"The value: %@ is not a valid oid.",oidStr] userInfo:nil];
                @throw exception;
            }
            bson_oid_from_string(&oid, oidCString);
        }
        
        BSONEncoder *bsonObject = [[BSONEncoder alloc]init];
        [bsonObject encodeDictionary:dictionaryToSave];
        [bsonObject finish];

        BOOL success = ejdbsavebson(_collection, bsonObject.bson, &oid);
        if (!success) return NO;
    }
    
    return YES;
}

@end