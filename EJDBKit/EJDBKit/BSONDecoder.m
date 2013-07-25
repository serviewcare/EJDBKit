#import "BSONDecoder.h"
#import "BSONNumber.h"

@interface BSONDecoder ()
@property (strong,nonatomic) NSMutableDictionary *decodedDict;
@end


@implementation BSONDecoder

- (id)init
{
    self = [super init];
    if (self)
    {
        _decodedDict = [[NSMutableDictionary alloc]initWithCapacity:10];
    }
    return self;
}


- (NSDictionary *)decodeFromIterator:(bson_iterator)iterator
{
    while (bson_iterator_more(&iterator))
    {
        bson_type type = bson_iterator_next(&iterator);

        if (type == BSON_STRING)
        {
            [self decodeStringIntoDictionary:_decodedDict fromIterator:iterator];
        }
        else if (type == BSON_OID)
        {
            [self decodeOIDIntoDictionary:_decodedDict fromIterator:iterator];
        }
        else if (type == BSON_INT)
        {
            [self decodeIntegerIntoDictionary:_decodedDict fromIterator:iterator];
        }
        else if (type == BSON_BOOL)
        {
            [self decodeBoolIntoDictionary:_decodedDict fromIterator:iterator];
        }
        else if (type == BSON_DOUBLE)
        {
            [self decodeDoubleIntoDictionary:_decodedDict fromIterator:iterator];
        }
        else if (type == BSON_DATE)
        {
            [self decodeDateIntoDictionary:_decodedDict fromIterator:iterator];
        }
        else if (type == BSON_ARRAY)
        {
            
        }
        else if (type == BSON_OBJECT)
        {
            [self decodeObjectIntoDictionary:_decodedDict fromIterator:iterator];
        }
    }
    return [NSDictionary dictionaryWithDictionary:_decodedDict];
}

- (void)decodeStringIntoDictionary:(NSMutableDictionary *)dict fromIterator:(bson_iterator)iterator
{
    NSString *key = [NSString stringWithCString:bson_iterator_key(&iterator) encoding:NSUTF8StringEncoding];
    NSString *value = [NSString stringWithCString:bson_iterator_string(&iterator) encoding:NSUTF8StringEncoding];
    [dict setValue:value forKey:key];
}

- (void)decodeOIDIntoDictionary:(NSMutableDictionary *)dict fromIterator:(bson_iterator)iterator
{
    NSString *key = [NSString stringWithCString:bson_iterator_key(&iterator) encoding:NSUTF8StringEncoding];
    bson_oid_t *oid = bson_iterator_oid(&iterator);
    char str[24];
    bson_oid_to_string(oid, str);
    NSString *value = [NSString stringWithCString:str encoding:NSUTF8StringEncoding];
    [dict setValue:value forKey:key];

}

- (void)decodeIntegerIntoDictionary:(NSMutableDictionary *)dict fromIterator:(bson_iterator)iterator
{
    NSString *key = [NSString stringWithCString:bson_iterator_key(&iterator) encoding:NSUTF8StringEncoding];
    int intValue = bson_iterator_int(&iterator);
    BSONNumber *value = [BSONNumber intNumberFromNumber:[NSNumber numberWithInt:intValue]];
    [dict setValue:value forKey:key];
}

- (void)decodeBoolIntoDictionary:(NSMutableDictionary *)dict fromIterator:(bson_iterator)iterator
{
    NSString *key = [NSString stringWithCString:bson_iterator_key(&iterator) encoding:NSUTF8StringEncoding];
    bool boolValue = bson_iterator_bool(&iterator);
    BSONNumber *value = [BSONNumber boolNumberFromNumber:[NSNumber numberWithBool:boolValue]];
    [dict setValue:value forKey:key];
}

- (void)decodeDoubleIntoDictionary:(NSMutableDictionary *)dict fromIterator:(bson_iterator)iterator
{
    NSString *key = [NSString stringWithCString:bson_iterator_key(&iterator) encoding:NSUTF8StringEncoding];
    double doubleValue = bson_iterator_double(&iterator);
    BSONNumber *value = [BSONNumber doubleNumberFromNumber:[NSNumber numberWithDouble:doubleValue]];
    [dict setValue:value forKey:key];
}

- (void)decodeDateIntoDictionary:(NSMutableDictionary *)dict fromIterator:(bson_iterator)iterator
{
    NSString *key = [NSString stringWithCString:bson_iterator_key(&iterator) encoding:NSUTF8StringEncoding];
    NSDate *value = [NSDate dateWithTimeIntervalSince1970:bson_iterator_date(&iterator)];
    [dict setValue:value forKey:key];
}

- (void)decodeObjectIntoDictionary:(NSMutableDictionary *)dict fromIterator:(bson_iterator)iterator
{
    NSString *key = [NSString stringWithCString:bson_iterator_key(&iterator) encoding:NSUTF8StringEncoding];
    bson obj;
    bson_init(&obj);
    bson_iterator_subobject(&iterator, &obj);
    bson_iterator subiterator;
    bson_iterator_init(&subiterator, &obj);
    BSONDecoder *decoder = [[BSONDecoder alloc]init];
    NSDictionary *subobject = [decoder decodeFromIterator:subiterator];
    [dict setValue:subobject forKey:key];
}

@end
