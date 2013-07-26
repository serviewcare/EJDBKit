#import "BSONDecoder.h"
#import "BSONNumber.h"

@interface BSONDecoder ()
@property (strong,nonatomic) NSMutableDictionary *decodedDict;
@property (strong,nonatomic) NSMutableArray *decodedArray;
@end


@implementation BSONDecoder

- (id)init
{
    self = [super init];
    if (self)
    {
        _decodedDict = [[NSMutableDictionary alloc]initWithCapacity:10];
        _decodedArray = [[NSMutableArray alloc]init];
    }
    return self;
}

- (NSDictionary *)decodeFromIterator:(bson_iterator)iterator
{
    while (bson_iterator_more(&iterator))
    {
        bson_type type = bson_iterator_next(&iterator);
        
        NSString *key = [NSString stringWithCString:bson_iterator_key(&iterator) encoding:NSUTF8StringEncoding];
        id value = [self valueFromIterator:iterator forBSONType:type];
        [_decodedDict setValue:value forKey:key];
    }
    return [NSDictionary dictionaryWithDictionary:_decodedDict];
}

- (id)valueFromIterator:(bson_iterator)iterator forBSONType:(bson_type)type
{
    id value = nil;
    
    if (type == BSON_STRING)
    {
        value = [self decodeStringFromIterator:iterator];
    }
    else if (type == BSON_OID)
    {
        value = [self decodeOIDFromIterator:iterator];
    }
    else if (type == BSON_INT)
    {
        value = [self decodeIntegerFromIterator:iterator];
    }
    else if (type == BSON_BOOL)
    {
        value = [self decodeBoolFromIterator:iterator];
    }
    else if (type == BSON_DOUBLE)
    {
        value = [self decodeDoubleFromIterator:iterator];
    }
    else if (type == BSON_DATE)
    {
        value = [self decodeDateFromIterator:iterator];
    }
    else if (type == BSON_ARRAY)
    {
        value = [self decodeArrayFromIterator:iterator];
    }
    else if (type == BSON_OBJECT)
    {
        value = [self decodeDictionaryFromIterator:iterator];
    }
    return value;
}

- (NSString *)decodeStringFromIterator:(bson_iterator)iterator
{
     return [NSString stringWithCString:bson_iterator_string(&iterator) encoding:NSUTF8StringEncoding];
}

- (NSString *)decodeOIDFromIterator:(bson_iterator)iterator
{
    bson_oid_t *oid = bson_iterator_oid(&iterator);
    char str[24];
    bson_oid_to_string(oid, str);
    return [NSString stringWithCString:str encoding:NSUTF8StringEncoding];
    
}

- (BSONNumber *)decodeIntegerFromIterator:(bson_iterator)iterator
{
    int intValue = bson_iterator_int(&iterator);
    return [BSONNumber intNumberFromNumber:[NSNumber numberWithInt:intValue]];
}

- (BSONNumber *)decodeBoolFromIterator:(bson_iterator)iterator
{
    bool boolValue = bson_iterator_bool(&iterator);
    return [BSONNumber boolNumberFromNumber:[NSNumber numberWithBool:boolValue]];
}

- (BSONNumber *)decodeDoubleFromIterator:(bson_iterator)iterator
{
    double doubleValue = bson_iterator_double(&iterator);
    return [BSONNumber doubleNumberFromNumber:[NSNumber numberWithDouble:doubleValue]];
}

- (NSDate *)decodeDateFromIterator:(bson_iterator)iterator
{
    return [NSDate dateWithTimeIntervalSince1970:bson_iterator_date(&iterator)];
}

- (NSDictionary *)decodeDictionaryFromIterator:(bson_iterator)iterator
{
    bson obj;
    bson_init(&obj);
    bson_iterator_subobject(&iterator, &obj);
    bson_iterator subiterator;
    bson_iterator_init(&subiterator, &obj);
    BSONDecoder *decoder = [[BSONDecoder alloc]init];
    return [decoder decodeFromIterator:subiterator];
}

- (NSArray *)decodeArrayFromIterator:(bson_iterator)iterator
{
    bson obj;
    bson_init(&obj);
    bson_iterator_subobject(&iterator, &obj);
    bson_iterator arrayIterator;
    bson_iterator_init(&arrayIterator, &obj);
    NSMutableArray *array = [NSMutableArray array];
    while (bson_iterator_more(&arrayIterator))
    {
        bson_type type = bson_iterator_next(&arrayIterator);
        if (type != BSON_EOO)
        {
            id value = [self valueFromIterator:arrayIterator forBSONType:type];
            [array addObject:value];
        }
    }

    return [NSArray arrayWithArray:array];
}

@end