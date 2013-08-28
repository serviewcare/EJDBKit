#import "EJDBFIQueryBuilderTests.h"
#import "EJDBQueryOrderByHint.h"
#import "EJDBFIQueryBuilder.h"

@implementation EJDBFIQueryBuilderTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

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

- (EJDBFIQueryBuilder *)testBuilderObject
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

- (void)testSimpleQuery
{
    EJDBFIQueryBuilder *builder = [EJDBFIQueryBuilder build].match(@"a",@"someValue");
    NSDictionary *builtQuery = builder.query;
    NSDictionary *expectedQuery = @{@"a": @"someValue"};
    STAssertTrue([builtQuery isEqualToDictionary:expectedQuery], @"Built query should equal expected query!");
}

- (void)testBeginsWithOperatorQuery
{
    EJDBFIQueryBuilder *builder = [EJDBFIQueryBuilder build].beginsWith(@"a",@"beg");
    NSDictionary *builtQuery = builder.query;
    NSDictionary *expectedQuery = @{@"a": @{@"$begin": @"beg"}};
    STAssertTrue([builtQuery isEqualToDictionary:expectedQuery], @"Built query should equal expected query!");
}

- (void)testNumberOperatorQuery
{
    EJDBFIQueryBuilder *builder = [EJDBFIQueryBuilder build].greaterThan(@"a",@50);
    NSDictionary *builtQuery = builder.query;
    NSDictionary *expectedQuery = @{@"a": @{@"$gt": @50}};
    STAssertTrue([builtQuery isEqualToDictionary:expectedQuery], @"Built query should equal expected query!");
}

- (void)testNestedOperatorQuery
{
    EJDBFIQueryBuilder *builder = [EJDBFIQueryBuilder build].notBeginsWith(@"a",@"beg");
    NSDictionary *builtQuery = builder.query;
    NSDictionary *expectedQuery = @{@"a": @{@"$not": @{@"$begin": @"beg"}}};
    STAssertTrue([builtQuery isEqualToDictionary:expectedQuery], @"Built query should equal expected query!");
}

- (void)testComplexQuery
{
   EJDBFIQueryBuilder *builder = [self testBuilderObject];
   NSDictionary *builtQuery = builder.query;
   NSDictionary *expectedQuery = [self complexQuery];
   STAssertTrue([builtQuery isEqualToDictionary:expectedQuery], @"Built query should equal expected query!");
}

- (void)testComplexQueryWithAndOrJoin
{
     
    EJDBFIQueryBuilder *builder =
    [self testBuilderObject].andJoin
    (
     @[
       [EJDBFIQueryBuilder build].orJoin(@[[EJDBFIQueryBuilder build].match(@"t",@1).match(@"u",@2)]),
       [EJDBFIQueryBuilder build].orJoin(@[[EJDBFIQueryBuilder build].match(@"v",@3).match(@"w",@4)])
      ]
    );
    
    NSDictionary *builtQuery = builder.query;
    NSMutableDictionary *complexQueryAndOrJoin = [NSMutableDictionary dictionaryWithDictionary:[self complexQuery]];
    [complexQueryAndOrJoin setObject:@[
                                    @{@"$or": @[@{@"t": @1,@"u":@2}]},
                                    @{@"$or": @[@{@"v": @3,@"w":@4}]}
                               ]
                              forKey:@"$and"];
    NSDictionary *expectedQuery = [NSDictionary dictionaryWithDictionary:complexQueryAndOrJoin];
    STAssertTrue([builtQuery isEqualToDictionary:expectedQuery], @"Built query should equal expected query!");
}

- (void)testProjection
{
    EJDBFIQueryBuilder *builder = [EJDBFIQueryBuilder build].greaterThan(@"a",@10)
                                                            .projection(@"a");
    NSDictionary *builtQuery = builder.query;
    NSDictionary *expectedQuery = @{@"a" : @{@"$gt": @10},@"a.$" : @1};
    STAssertTrue([builtQuery isEqualToDictionary:expectedQuery], @"Built query should equal expected query!");
}

- (void)testComplexQueryWithHints
{
    EJDBFIQueryBuilder *builder =
    [self testBuilderObject].maxRecords(@10)
                            .skipRecords(@0)
                            .onlyFields(@[@"a",@"f",@"q"])
                            .orderBy(@[
                                       [EJDBQueryOrderByHint orderPath:@"a" direction:EJDBQuerySortDesc],
                                       [EJDBQueryOrderByHint orderPath:@"f" direction:EJDBQuerySortAsc]
                                     ]);
    
    NSDictionary *builtHints = builder.hints;
    NSDictionary *expectedHints = @{@"$fields": @{@"a": @YES,@"f":@YES,@"q":@YES},
                                    @"$max":@10,
                                    @"$skip":@0,
                                    @"$orderby": @{@"a": @-1,@"f":@1}
                                   };
    STAssertTrue([builtHints isEqualToDictionary:expectedHints], @"Built hints should equal expected hints!");
}

@end