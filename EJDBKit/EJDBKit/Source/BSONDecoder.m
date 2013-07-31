#import "BSONDecoder.h"
#import "BSONArchiving.h"

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
        
        NSString *key = [NSString stringWithCString:bson_iterator_key(&iterator) encoding:NSUTF8StringEncoding];
        id value = [self valueFromIterator:iterator forBSONType:type];
        if (value != nil) [_decodedDict setValue:value forKey:key];
    }
    return [NSDictionary dictionaryWithDictionary:_decodedDict];
}

- (id)decodeObjectFromBSON:(bson *)bsonObject
{
    bson_iterator iterator;
    bson_iterator_init(&iterator, bsonObject);
    NSDictionary *decodedDictionary = [self decodeFromIterator:iterator];
    NSString *type = [decodedDictionary objectForKey:@"type"];
    if (type)
    {
        Class aClass = NSClassFromString(type);
        id obj = [[aClass alloc]init];
        if (![obj conformsToProtocol:@protocol(BSONArchiving)])
        {
            NSException *exception = [NSException exceptionWithName:@"Unsupported BSON Type!"
                                                             reason:[NSString stringWithFormat:@"Cannot encode class: %@!",NSStringFromClass([obj class])]
                                                           userInfo:nil];
            obj = nil;
            @throw exception;
        }
        
        NSMutableDictionary *modifiedDict = [NSMutableDictionary dictionaryWithDictionary:decodedDictionary];
        NSString *oid = [modifiedDict objectForKey:@"_id"];
        if (oid)
        {
            [modifiedDict setValue:[modifiedDict objectForKey:@"_id"] forKey:[obj oidPropertyName]];
            [modifiedDict removeObjectForKey:@"_id"];
        }
        [obj fromDictionary:[NSDictionary dictionaryWithDictionary:modifiedDict]];
        return obj;
    }
    return decodedDictionary;
}

- (id)valueFromIterator:(bson_iterator)iterator forBSONType:(bson_type)type
{
    id value;
    
    switch (type) {
        case BSON_STRING:
            value = [self decodeStringFromIterator:iterator];
            break;
        case BSON_OID:
            value = [self decodeOIDFromIterator:iterator];
            break;
        case BSON_BOOL:
        case BSON_INT:
        case BSON_LONG:
        case BSON_DOUBLE:
        {
            value = [self decodeNumberFromIterator:iterator type:type];
            break;
        }
        case BSON_DATE:
            value = [self decodeDateFromIterator:iterator];
            break;
        case BSON_TIMESTAMP:
            value = [self decodeTimestampFromIterator:iterator];
            break;
        case BSON_ARRAY:
            value = [self decodeArrayFromIterator:iterator];
            break;
        case BSON_OBJECT:
            value = [self decodeDictionaryFromIterator:iterator];
            break;
        case BSON_BINDATA:
            value = [self decodeDataFromIterator:iterator];
            break;
        case BSON_NULL:
            value = [NSNull null];
            break;
        case BSON_EOO:
            value = nil;
            break;
        default:
        {
            NSException *exception = [NSException exceptionWithName:@"Unsupported BSON Type"
                                     reason:[NSString stringWithFormat:@"cannot decode element: %d",type]
                                                           userInfo:nil];
            @throw exception;
            break;
        }
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

- (NSNumber *)decodeNumberFromIterator:(bson_iterator)iterator type:(bson_type)type
{
    NSNumber *number;
    
    switch (type) {
        case BSON_BOOL:
            number = [NSNumber numberWithBool:bson_iterator_bool(&iterator)];
            break;
        case BSON_INT:
            number = [NSNumber numberWithInt:bson_iterator_int(&iterator)];
            break;
        case BSON_LONG:
            number = [NSNumber numberWithLongLong:bson_iterator_long(&iterator)];
        default:
            number = [NSNumber numberWithDouble:bson_iterator_double(&iterator)];
            break;
    }
    return number;
}

- (NSDate *)decodeDateFromIterator:(bson_iterator)iterator
{
    return [NSDate dateWithTimeIntervalSince1970:bson_iterator_date(&iterator)];
}

- (NSDate *)decodeTimestampFromIterator:(bson_iterator)iterator
{
    return [NSDate dateWithTimeIntervalSince1970:bson_iterator_time_t(&iterator)/1000.0];
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

- (NSData *)decodeDataFromIterator:(bson_iterator)iterator
{
    return [NSData dataWithBytes:bson_iterator_bin_data(&iterator) length:bson_iterator_bin_len(&iterator)];
}

@end