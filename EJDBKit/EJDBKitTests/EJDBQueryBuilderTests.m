#import "EJDBQueryBuilderTests.h"
#import "EJDBQueryBuilder.h"
#import "EJDBQueryOrderByHint.h"

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
    XCTAssertTrue([builtQuery isEqualToDictionary:expectedQuery], @"Built query should equal expected query!");
}

- (void)testBeginsWithOperatorQuery
{
    EJDBQueryBuilder *builder = [[EJDBQueryBuilder alloc]init];
    [builder path:@"a" beginsWith:@"beg"];
    NSDictionary *builtQuery = builder.query;
    NSDictionary *expectedQuery = @{@"a": @{@"$begin": @"beg"}};
    XCTAssertTrue([builtQuery isEqualToDictionary:expectedQuery], @"Built query should equal expected query!");
}

- (void)testNumberOperatorQuery
{
    EJDBQueryBuilder *builder = [[EJDBQueryBuilder alloc]init];
    [builder path:@"a" greaterThan:@50];
    NSDictionary *builtQuery = builder.query;
    NSDictionary *expectedQuery = @{@"a": @{@"$gt": @50}};
    XCTAssertTrue([builtQuery isEqualToDictionary:expectedQuery], @"Built query should equal expected query!");
}

- (void)testNestedOperatorQuery
{
    EJDBQueryBuilder *builder = [[EJDBQueryBuilder alloc]init];
    [builder path:@"a" notBeginsWith:@"beg"];
    NSDictionary *builtQuery = builder.query;
    NSDictionary *expectedQuery = @{@"a": @{@"$not": @{@"$begin": @"beg"}}};
    XCTAssertTrue([builtQuery isEqualToDictionary:expectedQuery], @"Built query should equal expected query!");
}

- (void)testComplexQuery
{
    EJDBQueryBuilder *builder = [self testBuilderObject];
    NSDictionary *builtQuery = builder.query;
    NSDictionary *expectedQuery = [self complexQuery];
    XCTAssertTrue([builtQuery isEqualToDictionary:expectedQuery], @"Built query should equal expected query!");
}

- (void)testComplexQueryWithAndOrJoin
{
    EJDBQueryBuilder *builder = [self testBuilderObject];
    EJDBQueryBuilder *match1 = [[EJDBQueryBuilder alloc]init];
    [match1 path:@"t" matches:@1];
    [match1 path:@"u" matches:@2];
    EJDBQueryBuilder *match2 = [[EJDBQueryBuilder alloc]init];
    [match2 path:@"v" matches:@3];
    [match2 path:@"w" matches:@4];
    EJDBQueryBuilder *join1 = [[EJDBQueryBuilder alloc]init];
    [join1 orJoin:@[match1]];
    EJDBQueryBuilder *join2 = [[EJDBQueryBuilder alloc]init];
    [join2 orJoin:@[match2]];
    [builder andJoin:@[join1,join2]];
    NSDictionary *builtQuery = builder.query;
    NSMutableDictionary *complexQueryAndOrJoin = [NSMutableDictionary dictionaryWithDictionary:[self complexQuery]];
    [complexQueryAndOrJoin setObject:@[
     @{@"$or": @[@{@"t": @1,@"u":@2}]},
     @{@"$or": @[@{@"v": @3,@"w":@4}]}
     ]
                              forKey:@"$and"];
    NSDictionary *expectedQuery = [NSDictionary dictionaryWithDictionary:complexQueryAndOrJoin];
    XCTAssertTrue([builtQuery isEqualToDictionary:expectedQuery], @"Built query should equal expected query!");
}

- (void)testProjection
{
    EJDBQueryBuilder *builder = [[EJDBQueryBuilder alloc]init];
    [builder path:@"a" greaterThan:@10];
    [builder projectionForPath:@"a"];
    NSDictionary *builtQuery = builder.query;
    NSDictionary *expectedQuery = @{@"a" : @{@"$gt": @10},@"a.$" : @1};
    XCTAssertTrue([builtQuery isEqualToDictionary:expectedQuery], @"Built query should equal expected query!");
}

- (void)testComplexQueryWithHints
{
    EJDBQueryBuilder *builder = [[EJDBQueryBuilder alloc]init];
    [builder maxRecords:@10];
    [builder skipRecords:@0];
    [builder onlyFields:@[@"a",@"f",@"q"]];
    [builder orderBy:@[
     [EJDBQueryOrderByHint orderPath:@"a" direction:EJDBQuerySortDesc],
     [EJDBQueryOrderByHint orderPath:@"f" direction:EJDBQuerySortAsc]
    ]];
    NSDictionary *builtHints = builder.hints;
    NSDictionary *expectedHints = @{@"$fields": @{@"a": @YES,@"f":@YES,@"q":@YES},
                                    @"$max":@10,
                                    @"$skip":@0,
                                    @"$orderby": @{@"a": @-1,@"f":@1}
                                    };
    XCTAssertTrue([builtHints isEqualToDictionary:expectedHints], @"Built hints should equal expected hints!");    
}
@end