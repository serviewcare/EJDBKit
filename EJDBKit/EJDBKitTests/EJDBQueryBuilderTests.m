#import "EJDBQueryBuilderTests.h"
#import "EJDBQueryBuilder.h"

@implementation EJDBQueryBuilderTests

- (NSDictionary *)complexQuery
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

- (EJDBQueryBuilder *)testBuilderObject
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

- (void)testSimpleQuery
{
    EJDBQueryBuilder *builder = [[EJDBQueryBuilder alloc]init];
    [builder path:@"a" matches:@"someValue"];
    NSDictionary *builtQuery = builder.query;
    NSDictionary *expectedQuery = @{@"a": @"someValue"};
    STAssertTrue([builtQuery isEqualToDictionary:expectedQuery], @"Built query should equal expected query!");
}

- (void)testBeginsWithOperatorQuery
{
    EJDBQueryBuilder *builder = [[EJDBQueryBuilder alloc]init];
    [builder path:@"a" beginsWith:@"beg"];
    NSDictionary *builtQuery = builder.query;
    NSDictionary *expectedQuery = @{@"a": @{@"$begin": @"beg"}};
    STAssertTrue([builtQuery isEqualToDictionary:expectedQuery], @"Built query should equal expected query!");
}

- (void)testNumberOperatorQuery
{
    EJDBQueryBuilder *builder = [[EJDBQueryBuilder alloc]init];
    [builder path:@"a" greaterThan:@50];
    NSDictionary *builtQuery = builder.query;
    NSDictionary *expectedQuery = @{@"a": @{@"$gt": @50}};
    STAssertTrue([builtQuery isEqualToDictionary:expectedQuery], @"Built query should equal expected query!");
}



@end
