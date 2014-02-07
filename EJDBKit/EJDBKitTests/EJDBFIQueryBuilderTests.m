#import "EJDBFIQueryBuilderTests.h"
#import "EJDBQueryFixtures.h"
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

- (void)testSimpleQuery
{
    EJDBFIQueryBuilder *builder = [EJDBFIQueryBuilder build].match(@"a",@"someValue");
    NSDictionary *builtQuery = builder.query;
    NSDictionary *expectedQuery = @{@"a": @"someValue"};
    XCTAssertTrue([builtQuery isEqualToDictionary:expectedQuery], @"Built query should equal expected query!");
}

- (void)testBeginsWithOperatorQuery
{
    EJDBFIQueryBuilder *builder = [EJDBFIQueryBuilder build].beginsWith(@"a",@"beg");
    NSDictionary *builtQuery = builder.query;
    NSDictionary *expectedQuery = @{@"a": @{@"$begin": @"beg"}};
    XCTAssertTrue([builtQuery isEqualToDictionary:expectedQuery], @"Built query should equal expected query!");
}

- (void)testNumberOperatorQuery
{
    EJDBFIQueryBuilder *builder = [EJDBFIQueryBuilder build].greaterThan(@"a",@50);
    NSDictionary *builtQuery = builder.query;
    NSDictionary *expectedQuery = @{@"a": @{@"$gt": @50}};
    XCTAssertTrue([builtQuery isEqualToDictionary:expectedQuery], @"Built query should equal expected query!");
}

- (void)testNestedOperatorQuery
{
    EJDBFIQueryBuilder *builder = [EJDBFIQueryBuilder build].notBeginsWith(@"a",@"beg");
    NSDictionary *builtQuery = builder.query;
    NSDictionary *expectedQuery = @{@"a": @{@"$not": @{@"$begin": @"beg"}}};
    XCTAssertTrue([builtQuery isEqualToDictionary:expectedQuery], @"Built query should equal expected query!");
}

- (void)testComplexQuery
{
   EJDBFIQueryBuilder *builder = [EJDBQueryFixtures testFIQueryBuilderObject]; //[self testBuilderObject];
   NSDictionary *builtQuery = builder.query;
   NSDictionary *expectedQuery = [EJDBQueryFixtures complexQuery];
   XCTAssertTrue([builtQuery isEqualToDictionary:expectedQuery], @"Built query should equal expected query!");
}

- (void)testComplexQueryWithAndOrJoin
{
     
    EJDBFIQueryBuilder *builder =
    [EJDBQueryFixtures testFIQueryBuilderObject].andJoin
    (
     @[
       [EJDBFIQueryBuilder build].orJoin(@[[EJDBFIQueryBuilder build].match(@"t",@1).match(@"u",@2)]),
       [EJDBFIQueryBuilder build].orJoin(@[[EJDBFIQueryBuilder build].match(@"v",@3).match(@"w",@4)])
      ]
    );
    
    NSDictionary *builtQuery = builder.query;
    NSMutableDictionary *complexQueryAndOrJoin = [NSMutableDictionary dictionaryWithDictionary:[EJDBQueryFixtures complexQuery]];
    [complexQueryAndOrJoin setObject:@[
                                    @{@"$or": @[@{@"t": @1,@"u":@2}]},
                                    @{@"$or": @[@{@"v": @3,@"w":@4}]}
                               ]
                              forKey:@"$and"];
    NSDictionary *expectedQuery = [NSDictionary dictionaryWithDictionary:complexQueryAndOrJoin];
    XCTAssertTrue([builtQuery isEqualToDictionary:expectedQuery], @"Built query should equal expected query!");
}


- (void)testJoinToCollectionQuery
{
    EJDBFIQueryBuilder *carJoinBuilder = [EJDBFIQueryBuilder build].addJoinToCollection(@"car",@"cars");
    XCTAssertEqualObjects(carJoinBuilder.query, [EJDBQueryFixtures carsJoin], @"Generated do dictionary should equal expected do dictionary!");
    XCTAssertEqualObjects(carJoinBuilder.joins, [EJDBQueryFixtures carsJoin][@"$do"], @"Generated joins dictionary should equal expected joins dictionary!");
}

- (void)testJoinToCollectionQueryWithCriteria
{
    EJDBFIQueryBuilder *carJoinBuilder = [EJDBFIQueryBuilder build].match(@"month",@"June").addJoinToCollection(@"car",@"cars");
    XCTAssertTrue([carJoinBuilder.query count] == 2, @"Generated query should have exactly 2 keys!");
    XCTAssertNotNil(carJoinBuilder.query[@"$do"], @"Generated query should contain a $do entry!");
    XCTAssertNotNil(carJoinBuilder.query[@"month"], @"Generated query should contain a month entry!");
}


- (void)testProjection
{
    EJDBFIQueryBuilder *builder = [EJDBFIQueryBuilder build].greaterThan(@"a",@10)
                                                            .projection(@"a");
    NSDictionary *builtQuery = builder.query;
    NSDictionary *expectedQuery = @{@"a" : @{@"$gt": @10},@"a.$" : @1};
    XCTAssertTrue([builtQuery isEqualToDictionary:expectedQuery], @"Built query should equal expected query!");
}

- (void)testComplexQueryWithHints
{
    EJDBFIQueryBuilder *builder =
    [EJDBQueryFixtures testFIQueryBuilderObject].maxRecords(@10)
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
    XCTAssertTrue([builtHints isEqualToDictionary:expectedHints], @"Built hints should equal expected hints!");
}
@end