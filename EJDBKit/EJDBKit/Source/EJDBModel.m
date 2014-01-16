#import "EJDBModel.h"
#import <objc/objc-runtime.h>

@interface EJDBModel ()
@property (nonatomic,readonly) NSDictionary *propertyGetters;
@property (nonatomic,readonly) NSDictionary *propertySetters;
@property (nonatomic,readonly) NSDictionary *propertyTypes;
@property (nonatomic) NSMutableDictionary *values;
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

- (void)parseProperties
{
    NSMutableDictionary *propertyGetters = [NSMutableDictionary dictionary];
    NSMutableDictionary *propertySetters = [NSMutableDictionary dictionary];
    NSMutableDictionary *propertyTypes = [NSMutableDictionary dictionary];
    Class klass = [self class];
    while (klass != [NSObject class])
    {
        unsigned int outCount,i;
        objc_property_t *properties = class_copyPropertyList(klass, &outCount);
        for (i = 0;i < outCount;i++)
        {
            objc_property_t property = properties[i];
            char *dynamic = property_copyAttributeValue(property, "D");
            if (dynamic)
            {
                free(dynamic);
                NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
                
                if ([self checkIfReadOnlyProperty:property])
                {
                    free(properties);
                    @throw [NSException exceptionWithName:@"EJDBKitUnsupportedDynamicPropertyAttribute!"
                                                   reason:[NSString stringWithFormat:@"The property: %@ contains a readonly attribute!",propertyName]
                                                 userInfo:nil];
                    return;
                }
                
                if (![self loadPropertyTypeFromProperty:property withName:propertyName intoDictionary:propertyTypes])
                {
                    free(properties);
                    @throw [NSException exceptionWithName:@"EJDBKitUnsupportedDynamicPropertyType!"
                                                   reason:[NSString stringWithFormat:@"The property: %@ is an unsupported type!",propertyName]
                                                 userInfo:nil];
                    return;
                }
                [self loadGetterFromProperty:property withName:propertyName intoDictionary:propertyGetters];
                [self loadSetterFromProperty:property withName:propertyName intoDictionary:propertySetters];
            }
        }
        free(properties);
        klass = [klass superclass];
    }
    _propertyGetters = propertyGetters;
    _propertySetters = propertySetters;
    _propertyTypes = propertyTypes;
    _values = [[NSMutableDictionary alloc] init];
}

- (BOOL)checkIfReadOnlyProperty:(objc_property_t)property
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

- (BOOL)loadPropertyTypeFromProperty:(objc_property_t)property withName:(NSString *)propertyName intoDictionary:(NSMutableDictionary *)dictionary
{
    BOOL isSupportedType = YES;
    char *type = property_copyAttributeValue(property, "T");
    if (type)
    {
        NSString *typeString = [NSString stringWithUTF8String:type];
        if (![typeString hasPrefix:@"@"])
        {
            if (![typeString isEqualToString:@"i"] && ![typeString isEqualToString:@"B"] &&
                ![typeString isEqualToString:@"f"] && ![typeString isEqualToString:@"d"])
            {
                isSupportedType = NO;
            }
        }
        else
        {
            NSString *classString = [typeString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@\""]];
            Class klass =  NSClassFromString(classString);
            if (![klass isSubclassOfClass:[NSString class]] && ![klass isSubclassOfClass:[NSNumber class]] &&
                ![klass isSubclassOfClass:[NSDate class]] && ![klass isSubclassOfClass:[NSDictionary class]] &&
                ![klass isSubclassOfClass:[NSArray class]] && ![klass isSubclassOfClass:[EJDBModel class]])
            {
                isSupportedType = NO;
            }
        }
        if (isSupportedType)
        {
            [dictionary setObject:typeString forKey:propertyName];
        }
        free(type);
    }
    return isSupportedType;
}

- (void)loadGetterFromProperty:(objc_property_t)property withName:(NSString *)propertyName intoDictionary:(NSMutableDictionary *)dictionary
{
    char *getterName = property_copyAttributeValue(property, "G");
    if (getterName)
    {
        [dictionary setObject:propertyName forKey:[NSString stringWithUTF8String:getterName]];
        free(getterName);
    }
    else
    {
        [dictionary setObject:propertyName forKey:propertyName];
    }

}

- (void)loadSetterFromProperty:(objc_property_t)property withName:(NSString *)propertyName intoDictionary:(NSMutableDictionary *)dictionary
{
    char *setterName = property_copyAttributeValue(property, "S");
    if (setterName)
    {
        [dictionary setObject:propertyName forKey:[NSString stringWithUTF8String:setterName]];
        free(setterName);
    }
    else
    {
        NSString *selector = [propertyName stringByReplacingCharactersInRange:NSMakeRange(0, 1)
                                                                   withString:[[propertyName substringToIndex:1] uppercaseString]];
        selector = [NSString stringWithFormat:@"set%@:",selector];
        [dictionary setObject:propertyName forKey:selector];
    }

}

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
    for (NSString *key in [_propertyGetters keyEnumerator])
    {
        NSMethodSignature *signature = [self methodSignatureForSelector:NSSelectorFromString(_propertyGetters[key])];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setSelector:NSSelectorFromString(_propertyGetters[key])];
        [self forwardInvocation:invocation];
        propertyKeysAndValues[key] = [self dynamicValueForKey:key] == nil ? [NSNull null] : self.values[key];
    }
    
    return [NSDictionary dictionaryWithDictionary:propertyKeysAndValues];
}

- (void)fromDictionary:(NSDictionary *)dictionary
{
    for (id key in [dictionary keyEnumerator])
    {
        [self setValue:[dictionary objectForKey:key] forKey:key];
    }
}

- (id)dynamicValueForKey:(NSString *)key
{
    return [self.values objectForKey:key];
}

- (void)setDynamicValue:(id)value forKey:(NSString *)key
{
    if (value == nil) {
        [self.values setObject:[NSNull null] forKey:key];
    } else {
        [self.values setObject:value forKey:key];
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    NSString *selectorAsString = NSStringFromSelector(aSelector);
    NSString *propertyName = nil;
    
    // Getter
    propertyName = [self.propertyGetters objectForKey:selectorAsString];
    if (propertyName)
    {
        NSString *propertyType = [self.propertyTypes objectForKey:propertyName];
        return [NSMethodSignature signatureWithObjCTypes:
                [[NSString stringWithFormat:@"%@@:", propertyType] UTF8String]];
    }
    
    // Setter
    propertyName = [self.propertySetters objectForKey:selectorAsString];
    if (propertyName)
    {
        NSString *propertyType = [self.propertyTypes objectForKey:propertyName];
        return [NSMethodSignature signatureWithObjCTypes:
                [[NSString stringWithFormat:@"v@:%@", propertyType] UTF8String]];
    }
    
    return [super methodSignatureForSelector:aSelector];
}


- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    NSString *selectorAsString = NSStringFromSelector([anInvocation selector]);
    NSString *propertyName = nil;
    
    // Getter
    propertyName = [self.propertyGetters objectForKey:selectorAsString];
    if (propertyName)
    {
       NSString *propertyType = [self.propertyTypes objectForKey:propertyName];
        
       if (![propertyType hasPrefix:@"@"])
       {
           [self fetchPrimitiveValueForPropertyName:propertyName invocation:anInvocation];
           return;
       }
       else
       {
           id value = [self dynamicValueForKey:propertyName];
           if (value == nil) value = [NSNull null];
           [anInvocation setReturnValue:&value];
           [anInvocation retainArguments];
           return;
       }
        
    }
    
    // Setter
    propertyName = [self.propertySetters objectForKey:selectorAsString];
    if (propertyName)
    {
        NSString *propertyType = [self.propertyTypes objectForKey:propertyName];
       
        if (![propertyType hasPrefix:@"@"])
        {
            [self savePrimitiveValueForPropertyName:propertyName invocation:anInvocation];
            return;
        }
        else
        {
            __unsafe_unretained id value = nil;
            [anInvocation getArgument:&value atIndex:2];
            [self setDynamicValue:value forKey:propertyName];
            return;
        }
    }
    [super forwardInvocation:anInvocation];
}

- (void)fetchPrimitiveValueForPropertyName:(NSString *)propertyName invocation:(NSInvocation *)anInvocation
{
    NSNumber *aNumber = [self dynamicValueForKey:propertyName];
    NSString *propertyType = [self.propertyTypes objectForKey:propertyName];
    
    if ([propertyType isEqualToString:@"i"])
    {
        int value = [aNumber intValue];
        [anInvocation setReturnValue:&value];
    }
    else if ([propertyType isEqualToString:@"B"])
    {
        bool value = [aNumber boolValue];
        [anInvocation setReturnValue:&value];
    }
    else if ([propertyType isEqualToString:@"f"])
    {
        float value = [aNumber floatValue];
        [anInvocation setReturnValue:&value];
    }
    else if ([propertyType isEqualToString:@"d"])
    {
        double value = [aNumber doubleValue];
        [anInvocation setReturnValue:&value];
    }
}


- (void)savePrimitiveValueForPropertyName:(NSString *)propertyName invocation:(NSInvocation *)anInvocation
{
    NSString *propertyType = [self.propertyTypes objectForKey:propertyName];
    
    if ([propertyType isEqualToString:@"i"])
    {
        int value;
        [anInvocation getArgument:&value atIndex:2];
        [self setDynamicValue:[NSNumber numberWithInt:value] forKey:propertyName];
    }
    else if ([propertyType isEqualToString:@"B"])
    {
        bool value;
        [anInvocation getArgument:&value atIndex:2];
        [self setDynamicValue:[NSNumber numberWithBool:value] forKey:propertyName];
    }
    else if ([propertyType isEqualToString:@"f"])
    {
        float value;
        [anInvocation getArgument:&value atIndex:2];
        [self setDynamicValue:[NSNumber numberWithFloat:value] forKey:propertyName];
    }
    else if ([propertyType isEqualToString:@"d"])
    {
        double value;
        [anInvocation getArgument:&value atIndex:2];
        [self setDynamicValue:[NSNumber numberWithDouble:value] forKey:propertyName];
    }
}

@end