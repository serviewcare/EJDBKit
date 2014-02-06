#import "EJDBModel.h"
#import "EJDBDatabase.h"
#import "EJDBQueryBuilder.h"
#import "EJDBQuery.h"
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

- (NSArray *)joinableModelArrayProperties
{
    return @[];
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

- (id)modelRepresentationFromModel:(EJDBModel *)model
{
    if ([model isEqual:[NSNull null]] || ![model oid]) return [NSNull null];
    id collectionName = [model collectionName] == nil ? [NSNull null] : [model collectionName];
    return @{@"_id": [model oid], @"collectionName" : collectionName, @"type" : [model type]};
}

- (id)modelFromRepresentation:(NSDictionary *)representation forClass:(Class)class
{
    if([representation[@"_id"] isEqual:[NSNull null]] || [representation[@"collectionName"] isEqual:[NSNull null]] || !_database) return nil;
    EJDBCollection *collection = [EJDBCollection collectionWithName:representation[@"collectionName"] db:_database];
    NSDictionary *modelObjectDict = [collection fetchObjectWithOID:representation[@"_id"]];
    id modelObject = [[class alloc]initWithDatabase:_database];
    [modelObject fromDictionary:modelObjectDict];
    return modelObject;
}


- (NSArray *)joinedModelsFromArray:(NSArray *)array
{
    if ([array count] == 0) return array;
    
    NSDictionary *firstObject = array[0];
    NSString *collectionName = firstObject[@"collectionName"];
    NSMutableArray *oids = [NSMutableArray array];
    for (id object in array)
    {
        [oids addObject:object[@"_id"]];
    }
    
    EJDBQueryBuilder *builder = [[EJDBQueryBuilder alloc]init];
    [builder path:@"_id" in:[NSArray arrayWithArray:oids]];    
    EJDBCollection *collection = [_database collectionWithName:collectionName];
    EJDBQuery *query = [[EJDBQuery alloc]initWithCollection:collection queryBuilder:builder];
    NSArray *fetchedObjects = [query fetchObjects];
    return fetchedObjects;
}


/*
- (NSArray *)joinedModelsFromArray:(NSArray *)array
{
    
    return nil;
}
*/

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
                propertyKeysAndValues[key] = [self modelRepresentationFromModel:object];
            }
            else if ([class isSubclassOfClass:[NSArray class]])
            {
                NSArray *array = [self valueForKey:key];
                if ([array isEqual:[NSNull null]])
                {
                    propertyKeysAndValues[key] = array;
                    continue;
                }
                NSMutableArray *modelObjects = [NSMutableArray array];
                for (id object in array)
                {
                    if ([object isKindOfClass:[EJDBModel class]])
                    {
                        id modelRepresentation = [self modelRepresentationFromModel:object];
                        [modelObjects addObject:modelRepresentation];
                    }
                    else
                    {
                        [modelObjects addObject:object];
                    }
                }
                propertyKeysAndValues[key] = [NSArray arrayWithArray:modelObjects];
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
                if (![dictionary[key] isEqual:[NSNull null]] && [class isSubclassOfClass:[EJDBModel class]])
                {
                    NSDictionary *modelInfo = dictionary[key];
                    id modelObject = [self modelFromRepresentation:modelInfo forClass:class];
                    if (!modelObject) continue;
                    value = modelObject;
                }
                else if (![dictionary[key] isEqual:[NSNull null]] && [class isSubclassOfClass:[NSArray class]])
                {
                    if ([[self joinableModelArrayProperties] containsObject:key])
                    {
                        value = [self joinedModelsFromArray:dictionary[key]];
                    }
                    else
                    {
                        NSMutableArray *values = [NSMutableArray array];
                        NSArray *array = dictionary[key];
                        for (id object in array)
                        {
                            id anObject;
                            if ([object isKindOfClass:[NSDictionary class]])
                            {
                                if ([object objectForKey:@"type"] && [object objectForKey:@"collectionName"])
                                {
                                    anObject = [self modelFromRepresentation:object forClass:class];
                                }
                                [value addObject:anObject];
                            }
                            else
                            {
                                [values addObject:object];
                            }
                        }
                        value = [NSArray arrayWithArray:values];
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