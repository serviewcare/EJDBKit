#import "EJDBObject.h"
#import <objc/objc-runtime.h>

@implementation EJDBObject

- (NSString *)oidPropertyName
{
    return @"oid";
}

- (NSString *)type
{
    return NSStringFromClass([self class]);
}

- (NSDictionary *)toDictionary
{
    NSDictionary *propertyDictionary = [self propertyTypeDictionary];
    NSMutableDictionary *BSONDictionary = [NSMutableDictionary dictionary];
    [BSONDictionary setObject:[self type] forKey:@"type"];
    if ([self oid]) [BSONDictionary setObject:[self oid] forKey:@"_id"];
    for (NSString *key in [propertyDictionary keyEnumerator])
    {
        [BSONDictionary setObject:[self valueForKey:key] forKey:key];
    }
    return BSONDictionary;
}

- (void)fromDictionary:(NSDictionary *)dictionary
{
    NSDictionary *propertyDictionary = [self propertyTypeDictionary];
    for (NSString *key in [propertyDictionary keyEnumerator])
    {
        [self setValue:[dictionary objectForKey:key] forKey:key];
    }
}

- (NSString *)propertyTypeStringOfProperty:(objc_property_t) property {
    const char *attr = property_getAttributes(property);
    NSString *const attributes = [NSString stringWithCString:attr encoding:NSUTF8StringEncoding];
    
    NSRange const typeRangeStart = [attributes rangeOfString:@"T@\""];  // start of type string
    if (typeRangeStart.location != NSNotFound) {
        NSString *const typeStringWithQuote = [attributes substringFromIndex:typeRangeStart.location + typeRangeStart.length];
        NSRange const typeRangeEnd = [typeStringWithQuote rangeOfString:@"\""]; // end of type string
        if (typeRangeEnd.location != NSNotFound) {
            NSString *const typeString = [typeStringWithQuote substringToIndex:typeRangeEnd.location];
            return typeString;
        }
    }
    return nil;
}

- (NSDictionary *)propertyTypeDictionary {
    NSMutableDictionary *propertyMap = [NSMutableDictionary dictionary];
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for(i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        if(propName) {
            
            NSString *propertyName = [NSString stringWithCString:propName encoding:NSUTF8StringEncoding];
            NSString *propertyType = [self propertyTypeStringOfProperty:property];
            
            if (propertyType)
            {
                Class klass = NSClassFromString(propertyType);
                if ([klass isSubclassOfClass:[NSString class]] ||
                    [klass isSubclassOfClass:[NSDate class]] ||
                    [klass isSubclassOfClass:[NSArray class]] ||
                    [klass isSubclassOfClass:[NSDictionary class]] ||
                    [klass isSubclassOfClass:[NSNumber class]] ||
                    [klass isSubclassOfClass:[NSData class]] ||
                    [klass isSubclassOfClass:[NSNull class]] ||
                    [klass conformsToProtocol:@protocol(BSONArchiving)]
                    )
                {
                    [propertyMap setValue:propertyType forKey:propertyName];
                }
            }
        }
    }
    free(properties);
    return propertyMap;
}

@end