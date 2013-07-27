#import "BSONEncoder.h"

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
    else
    {
        [NSException raise:@"Unsupported BSON Type" format:@"Cannot encode class: %@",NSStringFromClass([value class])];
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
            [NSException raise:@"Invalid oid value!" format:@"The value %@ is not a valid oid",string];
            exit(1);
            return;
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

- (void)appendDate:(NSDate *)date forKey:(NSString *)key
{
    const char *cKeyString = [key cStringUsingEncoding:NSUTF8StringEncoding];
    bson_append_date(&_bsonObj, cKeyString, [date timeIntervalSince1970]);
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
    bson_append_binary(&_bsonObj, cKeyString, BSON_BINDATA, [data bytes], [data length]);
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