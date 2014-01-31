#import "BSONEncoder.h"
#import "BSONArchiving.h"
#import "EJDBModel.h"


@interface BSONEncoder ()
@property (assign,nonatomic) bson bsonObj;
@end

@implementation BSONEncoder

- (id)init
{
    self = [super init];
    if (self)
    {
        bson_init(&_bsonObj);
    }
    return self;
}

- (id)initAsQuery
{
    self = [super init];
    if (self)
    {
        bson_init_as_query(&_bsonObj);
    }
    return self;
}

- (void)encodeDictionary:(NSDictionary *)dictionary
{
    for (NSString *key in [dictionary keyEnumerator])
    {
        id value = [dictionary objectForKey:key];
        [self encodeObject:value forKey:key];
    }
}

- (void)encodeObject:(id)value forKey:(NSString *)key
{
    if ([value isKindOfClass:[NSString class]])
    {
        [self appendString:value forKey:key];
    }
    else if ([value isKindOfClass:[NSNumber class]])
    {
        [self appendNumber:value forKey:key];
    }
    else if ([value isKindOfClass:[NSDate class]])
    {
        [self appendDate:value forKey:key];
    }
    else if ([value isKindOfClass:[NSDictionary class]])
    {
        [self appendDictionary:value forKey:key];
    }
    else if ([value isKindOfClass:[NSArray class]])
    {
        [self appendArray:value forKey:key];
    }
    else if ([value isKindOfClass:[NSData class]])
    {
        [self appendData:value forKey:key];
    }
    else if ([value isKindOfClass:[NSNull class]])
    {
        [self appendNullForKey:key];
    }
    else if ([value conformsToProtocol:@protocol(BSONArchiving)])
    {
        [self appendDictionary:[value toDictionary] forKey:key];
    }
    else
    {
        NSException *exception = [NSException exceptionWithName:@"Unsupported BSON Type!"
                                                         reason:[NSString stringWithFormat:@"Cannot encode class: %@!",NSStringFromClass([value class])]
                                                       userInfo:nil];
        @throw exception;
    }
}

- (void)appendString:(NSString *)string forKey:(NSString *)key
{
    const char *cKeyString = [key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cString = [string cStringUsingEncoding:NSUTF8StringEncoding];
    if(strcmp(cKeyString, "_id") == 0)
    {
        if(!ejdbisvalidoidstr(cString))
        {
            NSException *exception = [NSException exceptionWithName:@"Invalid OID value!"
                                            reason:[NSString stringWithFormat:@"The value: %@ is not a valid OID!",string]
                                            userInfo:nil];
            @throw exception;
        }
        bson_oid_t oid;
        bson_oid_from_string(&oid, cString);
        bson_append_oid(&_bsonObj, cKeyString,&oid);
    }
    else
    {
        bson_append_string(&_bsonObj, cKeyString, cString);    
    }
    
}

- (void)appendNumber:(NSNumber *)number forKey:(NSString *)key
{
    const char *cKeyString = [key cStringUsingEncoding:NSUTF8StringEncoding];
    
    switch (*[number objCType]) {
        case 'c':
            bson_append_bool(&_bsonObj, cKeyString, [number boolValue]);
            break;
        case 'i':
        case 'l':
        {
            bson_append_int(&_bsonObj, cKeyString, [number intValue]);
            break;
        }
        case 'q':
        {
            bson_append_long(&_bsonObj, cKeyString, [number longLongValue]);
            break;
        }
        case 'f':
        case 'd':
        default:
        {
            bson_append_double(&_bsonObj, cKeyString, [number doubleValue]);
            break;
        }
    }
}

/* 
 The most we can do here is round and cast our timeinterval instead of just cramming a double into an int64_t.
 We lose sub second precision because of this but for most uses this should not be an issue.
 I don't like this but I haven't been able to come up with a better alternative.
*/
- (void)appendDate:(NSDate *)date forKey:(NSString *)key
{
    const char *cKeyString = [key cStringUsingEncoding:NSUTF8StringEncoding];
    bson_append_date(&_bsonObj, cKeyString, (int64_t)round([date timeIntervalSince1970]));
}

- (void)appendDictionary:(NSDictionary *)dictionary forKey:(NSString *)key
{
    const char *cKeyString = [key cStringUsingEncoding:NSUTF8StringEncoding];
    bson_append_start_object(&_bsonObj, cKeyString);
    [self encodeDictionary:dictionary];
    bson_append_finish_object(&_bsonObj);
}

- (void)appendArray:(NSArray *)array forKey:(NSString *)key
{
    const char *cKeyString = [key cStringUsingEncoding:NSUTF8StringEncoding];
    bson_append_start_array(&_bsonObj, cKeyString);
    for (id value in array)
    {
        if ([value isKindOfClass:[NSDictionary class]])
        {
            bson_append_start_object(&_bsonObj,"");
            [self encodeDictionary:value];
            bson_append_finish_object(&_bsonObj);
        }
        else
        {
            [self encodeObject:value forKey:key];
        }
    }
    bson_append_finish_array(&_bsonObj);
}

- (void)appendData:(NSData *)data forKey:(NSString *)key
{
    const char *cKeyString = [key cStringUsingEncoding:NSUTF8StringEncoding];
    NSNumber *length = [NSNumber numberWithUnsignedInteger:[data length]];
    bson_append_binary(&_bsonObj, cKeyString, BSON_BINDATA, [data bytes], [length intValue]);
}

- (void)appendNullForKey:(NSString *)key
{
    const char *cKeyString = [key cStringUsingEncoding:NSUTF8StringEncoding];
    bson_append_null(&_bsonObj, cKeyString);
}

- (void)finish
{
    bson_finish(&_bsonObj);
}

- (bson *)bson
{
    return &_bsonObj;
}

- (void)dealloc
{   
    bson_destroy(&_bsonObj);
}

@end