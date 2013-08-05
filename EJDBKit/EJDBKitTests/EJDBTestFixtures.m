#import "EJDBTestFixtures.h"

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


@implementation EJDBTestFixtures

+ (NSArray *)simpleDictionaries
{
    NSDictionary *obj1 = @{@"name" : @"joe blow", @"age" : @36, @"address" : @"21 jump street", @"married" : @NO};
    NSDictionary *obj2 = @{@"name" : @"jane doe", @"age" : @32, @"address": @"13 elm street", @"married" : @NO};
    NSDictionary *obj3 = @{@"name" : @"alisha doesit", @"age" : @25, @"address": @"42nd street", @"married" : @NO};
    return @[obj1,obj2,obj3];
}

+ (NSArray *)complexDictionaries
{
    NSDictionary *obj1 = @{
                           @"_id" : @"123456789012345678901234",
                           @"name" : @"Антонов",
                           @"phone" : @"333-222-333",
                           @"age" : @33,
                           @"longscore" : @0xFFFFFFFFFF01LL,
                           @"dblscore" : @0.333333,
                           @"address" :
                               @{
                                   @"city" : @"Novosibirsk",
                                   @"country" : @"Russian Federation",
                                   @"zip" : @"630090",
                                   @"street" : @"Pirogova",
                                   @"room" : @334
                                   },
                           @"complexarr" :
                               @[
                                   @{
                                       @"foo" : @"bar",
                                       @"foo2" : @"bar2",
                                       @"foo3" : @"bar3"
                                       },
                                   @{
                                       @"foo" : @"bar",
                                       @"foo2" : @"bar3"
                                       },
                                   @333
                                   ]
                           };
    
    NSDictionary *obj2 = @{
                           @"_id" : @"123456789012345678901234",
                           @"name" : @"Адаманский",
                           @"phone" : @"444-123-333",
                           @"longscore" : @0xFFFFFFFFFF02LL,
                           @"dblscore" : @0.93,
                           @"address" :
                               @{
                                   @"city" : @"Novosibirsk",
                                   @"country" : @"Russian Federation",
                                   @"zip" : @"630090",
                                   @"street" : @"Pirogova"
                                   },
                           @"labels" :
                               @[
                                   @{@"0" : @"red"},@{@"1" : @"green"},@{@"2" : @"with gap, label"}
                                   ],
                           @"drinks" :
                               @[
                                   @{@"0" : @4},@{@"1" : @556667},@{@"2": @77676.22}
                                   ]
                           };


    return @[obj1,obj2];
}

+ (CustomArchivableClass *)validArchivableClass
{
    return [[CustomArchivableClass alloc]init];
}

+ (BogusOIDClass *)bogusOIDClass
{
    return [[BogusOIDClass alloc]init];
}


@end
