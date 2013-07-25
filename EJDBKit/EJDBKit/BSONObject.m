#import "BSONObject.h"
#import "BSONNumber.h"

@interface BSONObject ()
@property (assign,nonatomic) bson bsonObj;
@end

@implementation BSONObject

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
    if ([value isKindOfClass:[BSONNumber class]])
    {
        [self appendNumber:value forKey:key];
    }
    else if ([value isKindOfClass:[NSString class]])
    {
        [self appendString:value forKey:key];
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
    bson_init_as_query(self.bson);
}

- (void)appendNumber:(BSONNumber *)number forKey:(NSString *)key
{
    const char *cKeyString = [key cStringUsingEncoding:NSUTF8StringEncoding];
    if (number.isDouble)
    {
        bson_append_double(&_bsonObj, cKeyString,number.doubleValue);
    }
    else if (number.isLongLong) {
        bson_append_long(&_bsonObj, cKeyString, number.longlongValue);
    }
    else if (number.isInt)
    {
        bson_append_int(&_bsonObj, cKeyString, number.intValue);
    }
    else if (number.isBool)
    {
        bson_append_bool(&_bsonObj, cKeyString, number.boolValue);
    }
}

- (void)appendString:(NSString *)string forKey:(NSString *)key
{
    const char *cKeyString = [key cStringUsingEncoding:NSUTF8StringEncoding];
    bson_append_string(&_bsonObj, cKeyString, [string cStringUsingEncoding:NSUTF8StringEncoding]);
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
    bson_del(&_bsonObj);
}

@end