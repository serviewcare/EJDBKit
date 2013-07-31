
#import "ArchivableClasses.h"


@implementation CustomArchivableClass

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
    return @{@"type" : [self type], @"name" : _name,@"age" : _age};
}

- (void)fromDictionary:(NSDictionary *)dictionary
{
    for (id key in [dictionary keyEnumerator])
    {
        [self setValue:[dictionary objectForKey:key] forKey:key];
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    value = [key isEqual:@"type"] ? [self type] : [NSNull null];
}

@end

@implementation BogusOIDClass

- (NSDictionary *)toDictionary
{
    return @{@"_id" : @"123", @"name" : self.name, @"age" : self.age };
}

@end


@implementation ArchivableClasses

+ (CustomArchivableClass *)validArchivableClass
{
    return [[CustomArchivableClass alloc]init];
}

+ (BogusOIDClass *)boguisOIDClass
{
    return [[BogusOIDClass alloc]init];
}

@end

