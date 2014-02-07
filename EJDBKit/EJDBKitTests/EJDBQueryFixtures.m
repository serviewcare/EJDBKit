#import "EJDBQueryFixtures.h"
#import "EJDBQueryBuilder.h"
#import "EJDBFIQueryBuilder.h"

@implementation EJDBQueryFixtures

+ (NSDictionary *)complexQuery
{
    return
    @{
      @"a" : @"strvalue",
      @"b" : @{@"$not": @"strvalue"},
      @"c" : @{@"$icase": @"strvalue"},
      @"d" : @{@"$begin": @"somebegin"},
      @"e" : @{@"$not" : @{@"$begin" : @"notbegin"}},
      @"f" : @{@"$gt" : @1},
      @"g" : @{@"$gte" : @1},
      @"h" : @{@"$lt": @10},
      @"i" : @{@"$lte": @10},
      @"j" : @{@"$bt" : @[@1,@5]},
      @"k" : @{@"$in" : @[@1,@2,@3]},
      @"l" : @{@"$icase" : @{@"$in" : @[@"d",@"e",@"f"]}},
      @"m" : @{@"$nin" : @[@1,@2,@3]},
      @"n" : @{@"$icase" : @{@"$nin" : @[@"d",@"e",@"f"]}},
      @"o" : @{@"$exists" : @YES},
      @"p" : @{@"$exists" : @NO},
      @"q" : @{@"$strand" : @[@"g",@"h",@"i"]},
      @"r" : @{@"$stror": @[@"g",@"h",@"i"]},
      @"s" : @{@"$elemMatch": @{@"aa": @"someValue",@"bb" : @10,@"cc":@{@"$not":@20}}}
      };
}


+ (EJDBQueryBuilder *)testQueryBuilderObject
{
    EJDBQueryBuilder *builder = [[EJDBQueryBuilder alloc] init];
    [builder path:@"a" matches:@"strvalue"];
    [builder path:@"b" notMatches:@"strvalue"];
    [builder path:@"c" matchesIgnoreCase:@"strvalue"];
    [builder path:@"d" beginsWith:@"somebegin"];
    [builder path:@"e" notBeginsWith:@"notbegin"];
    [builder path:@"f" greaterThan:@1];
    [builder path:@"g" greaterThanOrEqualTo:@1];
    [builder path:@"h" lessThan:@10];
    [builder path:@"i" lessThanOrEqualTo:@10];
    [builder path:@"j" between:@[@1,@5]];
    [builder path:@"k" in:@[@1,@2,@3]];
    [builder path:@"l" inIgnoreCase:@[@"d",@"e",@"f"]];
    [builder path:@"m" notIn:@[@1,@2,@3]];
    [builder path:@"n" notInIgnoreCase:@[@"d",@"e",@"f"]];
    [builder path:@"o" exists:YES];
    [builder path:@"p" exists:NO];
    [builder path:@"q" stringAllIn:@[@"g",@"h",@"i"]];
    [builder path:@"r" stringAnyIn:@[@"g",@"h",@"i"]];
    EJDBQueryBuilder *elemsBuilder = [[EJDBQueryBuilder alloc]init];
    [elemsBuilder path:@"aa" matches:@"someValue"];
    [elemsBuilder path:@"bb" matches:@10];
    [elemsBuilder path:@"cc" notMatches:@20];
    [builder path:@"s" elementsMatch:elemsBuilder];
    return builder;
}

+ (EJDBFIQueryBuilder *)testFIQueryBuilderObject
{
    return
    [EJDBFIQueryBuilder build].match(@"a",@"strvalue")
    .notMatch(@"b",@"strvalue")
    .matchIgnoreCase(@"c",@"strvalue")
    .beginsWith(@"d",@"somebegin")
    .notBeginsWith(@"e",@"notbegin")
    .greaterThan(@"f",@1)
    .greaterThanOrEqualTo(@"g",@1)
    .lessThan(@"h",@10)
    .lessThanOrEqualTo(@"i",@10)
    .between(@"j",@[@1,@5])
    .in(@"k",@[@1,@2,@3])
    .inIgnoreCase(@"l",@[@"d",@"e",@"f"])
    .notIn(@"m",@[@1,@2,@3])
    .notInIgnoreCase(@"n",@[@"d",@"e",@"f"])
    .exists(@"o")
    .notExists(@"p")
    .stringAllIn(@"q",@[@"g",@"h",@"i"])
    .stringAnyIn(@"r",@[@"g",@"h",@"i"])
    .elemsMatch(@"s",
                [EJDBFIQueryBuilder build].match(@"aa",@"someValue")
                .match(@"bb",@10)
                .notMatch(@"cc",@20)
                );
}

+ (NSDictionary *)carsJoin
{
    return @{@"$do" : @{@"car" : @{@"$join" : @"cars" }}};
}

+ (NSDictionary *)carsJoinWithCriteria
{
   NSMutableDictionary *query = [NSMutableDictionary dictionaryWithDictionary:[self carsJoin]];
   query[@"month"] = @"June";
   return [NSDictionary dictionaryWithDictionary:query];
}


@end
