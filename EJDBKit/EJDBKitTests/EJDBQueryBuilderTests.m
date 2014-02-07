#import "EJDBQueryBuilderTests.h"
#import "EJDBQueryFixtures.h"
#import "EJDBQueryBuilder.h"
#import "EJDBQueryOrderByHint.h"

@implementation EJDBQueryBuilderTests

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
    EJDBQueryBuilder *builder = [EJDBQueryFixtures testQueryBuilderObject];
    NSDictionary *builtQuery = builder.query;
    NSDictionary *expectedQuery = [EJDBQueryFixtures complexQuery];
    XCTAssertTrue([builtQuery isEqualToDictionary:expectedQuery], @"Built query should equal expected query!");
}

- (void)testComplexQueryWithAndOrJoin
{
    EJDBQueryBuilder *builder = [EJDBQueryFixtures testQueryBuilderObject];
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
    EJDBQueryBuilder *carJoinBuilder = [[EJDBQueryBuilder alloc]init];
    [carJoinBuilder path:@"car" addCollectionToJoin:@"cars"];
    XCTAssertEqualObjects(carJoinBuilder.query, [EJDBQueryFixtures carsJoin], @"Generated do dictionary should equal expected do dictionary!");
    XCTAssertEqualObjects(carJoinBuilder.joins, [EJDBQueryFixtures carsJoin][@"$do"], @"Generated joins dictionary should equal expected joins dictionary!");
}

- (void)testJoinToCollectionQueryWithCriteria
{
    EJDBQueryBuilder *carJoinBuilder = [[EJDBQueryBuilder alloc]init];
    [carJoinBuilder path:@"month" matches:@"June"];
    [carJoinBuilder path:@"car" addCollectionToJoin:@"cars"];
    XCTAssertTrue([carJoinBuilder.query count] == 2, @"Generated query should have exactly 2 keys!");
    XCTAssertNotNil(carJoinBuilder.query[@"$do"], @"Generated query should contain a $do entry!");
    XCTAssertNotNil(carJoinBuilder.query[@"month"], @"Generated query should contain a month entry!");
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