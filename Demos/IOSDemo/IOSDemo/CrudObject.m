#import "CrudObject.h"

@implementation CrudObject

- (NSString *)oidPropertyName
{
   return @"oid";
}

- (NSDictionary *)toDictionary
{
    return @{@"type" : NSStringFromClass([self class]), @"name" : _name, @"age" : _age, @"money" : _money};
}

- (void)fromDictionary:(NSDictionary *)dictionary
{
    for (NSString *key in [dictionary keyEnumerator])
    {
        [self setValue:[dictionary objectForKey:key] forKey:key];
    }
}

@end
