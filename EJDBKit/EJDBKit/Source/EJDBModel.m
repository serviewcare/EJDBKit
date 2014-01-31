#import "EJDBModel.h"
#import "EJDBDatabase.h"
#import <objc/objc-runtime.h>


typedef NS_OPTIONS(int, EJDBModelPropertyType)
{
    EJDBModelPropertyTypeScalar,
    EJDBModelPropertyTypeObject
};


@interface EJDBModelProperty : NSObject
@property (assign,nonatomic) EJDBModelPropertyType propertyType;
@property (copy,nonatomic) NSString *typeEncoding;
- (NSNumber *)defaultValueForNilNumberScalar;
@end

@implementation EJDBModelProperty

- (NSNumber *)defaultValueForNilNumberScalar
{
    NSNumber *defaultValue;
    
    if ([_typeEncoding isEqualToString:@"i"])
    {
        defaultValue = [NSNumber numberWithInt:0];
    }
    else if ([_typeEncoding isEqualToString:@"q"])
    {
        defaultValue = [NSNumber numberWithLongLong:0];
    }
    else if ([_typeEncoding isEqualToString:@"B"])
    {
        defaultValue = [NSNumber numberWithBool:NO];
    }
    else if ([_typeEncoding isEqualToString:@"f"])
    {
        defaultValue = [NSNumber numberWithFloat:0.];
    }
    else if ([_typeEncoding isEqualToString:@"d"])
    {
        defaultValue = [NSNumber numberWithDouble:0.];
    }

    return defaultValue;
}
@end

@interface EJDBModel ()
@property (nonatomic,readonly) NSDictionary *saveableProperties;
@end

@implementation EJDBModel

- (id)init
{
    self = [super init];
    if (self)
    {
        [self parseProperties];
    }
    return self;
}

- (id)initWithDatabase:(EJDBDatabase *)database
{
    self = [self init];
    if (self)
    {
        _database = database;
    }
    return self;
}

- (NSString *)collectionName
{
    return NSStringFromClass([self class]);
}

- (void)parseProperties
{
    NSMutableDictionary *saveableProperties = [NSMutableDictionary dictionary];
    Class klass = [self class];
    while (klass != [NSObject class])
    {
        unsigned int outCount,i;
        objc_property_t *properties = class_copyPropertyList(klass, &outCount);
        for (i = 0;i < outCount;i++)
        {
            objc_property_t property = properties[i];
            char *dynamic = property_copyAttributeValue(property, "D");
            if (!dynamic)
            {
                NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
                
                if (![self isReadOnlyProperty:property])
                {
                    [self savePropertyTypeFromProperty:property withName:propertyName intoDictionary:saveableProperties];
                }
            }
            else
            {
                free(dynamic);
            }
        }
        free(properties);
        klass = [klass superclass];
    }
    _saveableProperties = saveableProperties;
}

- (BOOL)isReadOnlyProperty:(objc_property_t)property
{
    BOOL isReadOnly = NO;
    char *readonly = property_copyAttributeValue(property, "R");
    if (readonly)
    {
        free(readonly);
        isReadOnly = YES;
    }
    return isReadOnly;
}

- (BOOL)savePropertyTypeFromProperty:(objc_property_t)property withName:(NSString *)propertyName intoDictionary:(NSMutableDictionary *)dictionary
{
    BOOL isSupportedType = NO;
    char *type = property_copyAttributeValue(property, "T");
    if (type)
    {
        EJDBModelPropertyType propertyType;
        NSString *typeString;
        NSString *typeEncodingString = [NSString stringWithUTF8String:type];
        if (![typeEncodingString hasPrefix:@"@"])
        {
            if ([typeEncodingString isEqualToString:@"i"] || [typeEncodingString isEqualToString:@"q"] ||
                [typeEncodingString isEqualToString:@"B"] || [typeEncodingString isEqualToString:@"f"] ||
                [typeEncodingString isEqualToString:@"d"])
            {
                typeString = typeEncodingString;
                propertyType = EJDBModelPropertyTypeScalar;
                isSupportedType = YES;
            }
        }
        else
        {
            NSString *classString = [typeEncodingString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@\""]];
            
            Class klass =  NSClassFromString(classString);
            if ([klass isSubclassOfClass:[NSString class]] || [klass isSubclassOfClass:[NSNumber class]] ||
                [klass isSubclassOfClass:[NSDate class]] || [klass isSubclassOfClass:[NSDictionary class]] ||
                [klass isSubclassOfClass:[NSArray class]] || [klass isSubclassOfClass:[NSData class]] || [klass isSubclassOfClass:[EJDBModel class]])
            {
                typeString = classString;
                propertyType = EJDBModelPropertyTypeObject;
                isSupportedType = YES;
            }
        }
        if (isSupportedType)
        {
            EJDBModelProperty *modelProperty = [[EJDBModelProperty alloc]init];
            modelProperty.propertyType = propertyType;
            modelProperty.typeEncoding = [typeString copy];
            [dictionary setObject:modelProperty forKey:propertyName];
        }
        free(type);
    }
    return isSupportedType;
}

- (id)valueForKey:(NSString *)key
{
    id value = [super valueForKey:key];
    return value == nil ? [NSNull null] : value;
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    if (value == nil) value = [NSNull null];
    [super setValue:value forKey:key];
}

- (void)setNilValueForKey:(NSString *)key
{
    EJDBModelProperty *modelProperty = _saveableProperties[key];
    
    if (modelProperty.propertyType != EJDBModelPropertyTypeObject)
    {
        [self setValue:[modelProperty defaultValueForNilNumberScalar] forKey:key];
    }
    else
    {
        [super setNilValueForKey:key];
    }
}

#pragma mark - BSONArchiving delegate methods

- (NSString *)type
{
    return NSStringFromClass([self class]);
}

- (NSString *)oidPropertyName
{
    return @"oid";
}

- (NSDictionary *)toDictionary
{
    NSMutableDictionary *propertyKeysAndValues = [NSMutableDictionary dictionary];
    for (NSString *key in _saveableProperties.keyEnumerator)
    {
        EJDBModelProperty *modelProperty = _saveableProperties[key];
        if (modelProperty.propertyType == EJDBModelPropertyTypeObject)
        {
            Class class = NSClassFromString(modelProperty.typeEncoding);
            if ([class isSubclassOfClass:[EJDBModel class]])
            {
                id object = [self valueForKey:key];
                if (![object isEqual:[NSNull null]] && [object oid] != nil)
                {
                    id oid = [object oid];
                    id collectionName = [object collectionName] == nil ? [NSNull null] : [object collectionName];
                    propertyKeysAndValues[key] = @{@"_id": oid, @"collectionName" : collectionName, @"type" : [object type]};
                }
                else
                {
                    propertyKeysAndValues[key] = [NSNull null];
                }
            }
            else
            {
                propertyKeysAndValues[key] = [self valueForKey:key];
            }
        }
        else
        {
            propertyKeysAndValues[key] = [self valueForKey:key];
        }
    }
    propertyKeysAndValues[@"type"] = [self type];
    return [NSDictionary dictionaryWithDictionary:propertyKeysAndValues];
}

- (void)fromDictionary:(NSDictionary *)dictionary
{
    for (NSString *key in [dictionary keyEnumerator])
    {
        if ([key isEqualToString:@"_id"])
        {
            _oid = dictionary[key];
        }
        else if (![key isEqualToString:@"type"])
        {
            id value;
            EJDBModelProperty *modelProperty = _saveableProperties[key];
            if (modelProperty.propertyType == EJDBModelPropertyTypeObject)
            {
                Class class = NSClassFromString(modelProperty.typeEncoding);
                if ([class isSubclassOfClass:[EJDBModel class]])
                {
                    NSDictionary *modelInfo = dictionary[key];
                    if ([modelInfo isEqual:[NSNull null]]) continue;
                    if([modelInfo[@"_id"] isEqual:[NSNull null]] || [modelInfo[@"collectionName"] isEqual:[NSNull null]]) continue;
                    if (_database)
                    {
                        EJDBCollection *collection = [EJDBCollection collectionWithName:modelInfo[@"collectionName"] db:_database];
                        NSDictionary *modelObjectDict = [collection fetchObjectWithOID:modelInfo[@"_id"]];
                        id modelObject = [[class alloc]initWithDatabase:_database];
                        [modelObject fromDictionary:modelObjectDict];
                        value = modelObject;
                    }
                }
                else
                {
                    value = dictionary[key];
                }
            }
            else
            {
                value = dictionary[key];
            }
            [self setValue:value forKey:key];
        }
    }
}
@end