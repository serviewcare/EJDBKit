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

+ (NSArray *)carDictionaries
{
    NSDictionary *obj1 = @{@"_id" : @"50fe0a9935cf1e0300000000" ,@"model" : @"Honda Accord", @"year" : @2005};
    NSDictionary *obj2 = @{@"_id" : @"50fe0a9935cf1e0300000001",@"model" : @"Toyota Corolla", @"year" : @2011};
    NSDictionary *obj3 = @{@"_id" : @"50fe0a9935cf1e0300000002",@"model" : @"Toyota Camry", @"year" : @2008};
    return @[obj1,obj2,obj3];
}

+ (NSArray *)ordersDictionaries
{
    NSDictionary *obj1 = @{@"_id" : @"50fe0f3735cf1e0300000003",@"car" : @"50fe0a9935cf1e0300000000", @"pickUpDate" : @"2013052007",@"returnDate" : @"2013052718", @"customer" : @"andy"};
    NSDictionary *obj2 = @{@"_id" : @"50fe0f3735cf1e0300000004",@"car" : @"50fe0a9935cf1e0300000002", @"pickUpDate" : @"2013051116",@"returnDate" : @"2013051513", @"customer" : @"john"};
    NSDictionary *obj3 = @{@"_id" : @"50fe0f3735cf1e0300000005",@"car" : @"50fe0a9935cf1e0300000002", @"pickUpDate" : @"2013051517",@"returnDate" : @"2013052112", @"customer" : @"antony"};

    return @[obj1,obj2,obj3];
}

+ (NSDictionary *)topCarsDictionary
{
    NSDictionary *obj1 = @{@"_id" : @"50fe106b35cf1e0300000006",@"month" : @"June",@"cars" : @[@"50fe0a9935cf1e0300000002",@"50fe0a9935cf1e0300000000"]};
    return obj1;
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
                           @"_id" : @"234567890123456789012345",
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