
#import "ArchivableClasses.h"


@implementation CustomArchivableClass

- (NSString *)oidPropertyName
{
    return @"oid";
}

- (NSDictionary *)toDictionary
{
    return @{@"type": NSStringFromClass([self class]), @"name" : _name, @"age" : _age};
}

- (void)fromDictionary:(NSDictionary *)dictionary
{
    for (id key in [dictionary keyEnumerator])
    {
        [self setValue:[dictionary objectForKey:key] forKey:key];
    }
}
@end

@implementation BogusOIDClass

- (NSDictionary *)toDictionary
{
    return @{@"type" : NSStringFromClass([self class]), @"_id" : @"123", @"name" : self.name, @"age" : self.age };
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

