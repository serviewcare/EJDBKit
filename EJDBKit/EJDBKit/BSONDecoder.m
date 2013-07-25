#import "BSONDecoder.h"
#import "BSONNumber.h"

@implementation BSONDecoder


- (NSDictionary *)decodeFromIterator:(bson_iterator)iterator
{
    NSMutableDictionary *decodedDict = [[NSMutableDictionary alloc]initWithCapacity:10];
    
    while (bson_iterator_more(&iterator))
    {
        bson_type type = bson_iterator_next(&iterator);
        NSString *key = [NSString stringWithCString:bson_iterator_key(&iterator) encoding:NSUTF8StringEncoding];
        
        if (type == BSON_STRING)
        {
            NSString *value = [NSString stringWithCString:bson_iterator_string(&iterator) encoding:NSUTF8StringEncoding];
            [decodedDict setValue:value forKey:key];
            
        }
        else if (type == BSON_OID)
        {
            bson_oid_t *oid = bson_iterator_oid(&iterator);
            char str[24];
            bson_oid_to_string(oid, str);
            NSString *value = [NSString stringWithCString:str encoding:NSUTF8StringEncoding];
            [decodedDict setValue:value forKey:key];
        }
        else if (type == BSON_INT)
        {
            int intValue = bson_iterator_int(&iterator);
            BSONNumber *value = [BSONNumber intNumberFromNumber:[NSNumber numberWithInt:intValue]];
            [decodedDict setValue:value forKey:key];
        }
        else if (type == BSON_BOOL)
        {
            bool boolValue = bson_iterator_bool(&iterator);
            BSONNumber *value = [BSONNumber boolNumberFromNumber:[NSNumber numberWithBool:boolValue]];
            [decodedDict setValue:value forKey:key];
        }
        else if (type == BSON_DOUBLE)
        {
            double doubleValue = bson_iterator_double(&iterator);
            BSONNumber *value = [BSONNumber doubleNumberFromNumber:[NSNumber numberWithDouble:doubleValue]];
            [decodedDict setValue:value forKey:key];
        }
        else if (type == BSON_DATE)
        {
            NSDate *value = [NSDate dateWithTimeIntervalSince1970:bson_iterator_date(&iterator)];
            [decodedDict setValue:value forKey:key];
        }
    }
    
    return [NSDictionary dictionaryWithDictionary:decodedDict];
}

@end
