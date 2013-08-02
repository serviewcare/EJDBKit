#import "CrudObject.h"

@implementation CrudObject

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
    return @{@"type" : [self type],@"name" : _name, @"age" : _age, @"money" : _money, @"scores" : _scores};
}

- (void)fromDictionary:(NSDictionary *)dictionary
{
    for (NSString *key in [dictionary keyEnumerator])
    {
        [self setValue:[dictionary objectForKey:key] forKey:key];
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    value = [key isEqual:@"type"] ? [self type] : [NSNull null];
}

- (id)copyWithZone:(NSZone *)zone
{
    CrudObject *obj = [[CrudObject alloc]init];
    [obj setOid:_oid];
    [obj setName:_name];
    [obj setAge:_age];
    [obj setMoney:_money];
    [obj setScores:_scores];
    return obj;
}

@end
