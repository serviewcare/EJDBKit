#import "EJDBQueryTests.h"
#import "EJDBDatabase+DBTestExtensions.h"
#import "EJDBQuery.h"
#import "EJDBCollection.h"
#import "EJDBQueryBuilder.h"
#import "EJDBFIQueryBuilder.h"
#import "EJDBTestFixtures.h"


@interface EJDBQueryTests ()
@property (strong,nonatomic) EJDBDatabase *db;
@property (strong,nonatomic) EJDBCollection *collection;
@end


@implementation EJDBQueryTests

- (void)setUp
{
    [super setUp];
    _db = [EJDBDatabase createAndOpenDb];
    _collection = [_db ensureCollectionWithName:@"foo" error:NULL];
}

- (void)tearDown
{
    [EJDBDatabase closeAndDeleteDb:_db];
    _collection = nil;
    [super tearDown];
}

- (void)testFetchCount
{
    [_collection saveObjects:[EJDBTestFixtures simpleDictionaries]];
    EJDBQuery *query = [[EJDBQuery alloc]initWithCollection:_collection query:@{@"name":@{@"$begin": @"j"}}];
    XCTAssertTrue([query fetchCount] == 2, @"Fetch count should return exactly 2 records!");
}

- (void)testFetchCountWithError
{
    NSError *error;
    [_collection saveObjects:[EJDBTestFixtures simpleDictionaries]];
    EJDBQuery *query = [[EJDBQuery alloc]initWithCollection:_collection query:@{@"$begin" : @"j"}];
    [query fetchCountWithError:&error];
    XCTAssertNotNil(error, @"Fetch count error should not be nil!");
}

- (void)testFetchObject
{
    NSString *name = [[EJDBTestFixtures simpleDictionaries][0] objectForKey:@"name"];
    [_collection saveObjects:[EJDBTestFixtures simpleDictionaries]];
    EJDBQuery *query = [[EJDBQuery alloc]initWithCollection:_collection
                                                      query:@{@"name":@{@"$begin":@"j"}}
                                                      hints:@{@"$fields":@{@"name": @1}}];
    NSDictionary *object = [query fetchObject];
    XCTAssertNotNil(object, @"Fetched object should not be nil!");
    XCTAssertTrue([[object objectForKey:@"name"] isEqualToString:name], @"Saved name should equal fetched name!");
}


- (void)testFetchObjectWithEJDBQueryBuilder
{
    NSString *name = [[EJDBTestFixtures simpleDictionaries][0] objectForKey:@"name"];
    [_collection saveObjects:[EJDBTestFixtures simpleDictionaries]];
    EJDBQueryBuilder *builder = [[EJDBQueryBuilder alloc]init];
    [builder path:@"name" beginsWith:@"j"];
    [builder onlyFields:@[@"name"]];
    EJDBQuery *query = [[EJDBQuery alloc]initWithCollection:_collection queryBuilder:builder];
    NSDictionary *object = [query fetchObject];
    XCTAssertNotNil(object, @"Fetched object should not be nil!");
    XCTAssertTrue([[object objectForKey:@"name"] isEqualToString:name], @"Saved name should equal fetched name!");
}

- (void)testFetchObjectWithEJDBFIQueryBuilder
{
    NSString *name = [[EJDBTestFixtures simpleDictionaries][0] objectForKey:@"name"];
    [_collection saveObjects:[EJDBTestFixtures simpleDictionaries]];
    EJDBFIQueryBuilder *builder = [EJDBFIQueryBuilder build].beginsWith(@"name",@"j").onlyFields(@[@"name"]);
    EJDBQuery *query = [[EJDBQuery alloc]initWithCollection:_collection queryBuilder:builder];
    NSDictionary *object = [query fetchObject];
    XCTAssertNotNil(object, @"Fetched object should not be nil!");
    XCTAssertTrue([[object objectForKey:@"name"] isEqualToString:name], @"Saved name should equal fetched name!");
}

- (void)testEmptyQueryAndHintsWithQueryBuilderSuccess
{
    EJDBQueryBuilder *builder = [[EJDBQueryBuilder alloc] init];
    EJDBQuery *query = [[EJDBQuery alloc]initWithCollection:_collection queryBuilder:builder];
    NSDictionary *object = [query fetchObject];
    XCTAssertNil(object, @"object should be nil for empty query!");
}

- (void)testEmptyFIQueryAndHintsWithFIQueryBuilderSuccess
{
    EJDBFIQueryBuilder *builder = [EJDBFIQueryBuilder build];
    EJDBQuery *query = [[EJDBQuery alloc]initWithCollection:_collection queryBuilder:builder];
    NSDictionary *object = [query fetchObject];
    XCTAssertNil(object, @"object should be nil for empty query!");
}

- (void)testFetchObjectWithError
{
    NSError *error;
    [_collection saveObjects:[EJDBTestFixtures simpleDictionaries]];
    EJDBQuery *query = [[EJDBQuery alloc]initWithCollection:_collection
                                                      query:@{@"$name":@{@"$begin":@"j"}}
                                                      hints:@{@"$fields":@{@"name": @1}}];
    NSDictionary *object = [query fetchObjectWithError:&error];
    XCTAssertNil(object, @"Fetched object should be nil!");
    XCTAssertNotNil(error, @"Fetched object error should not be nil!");
}

- (void)testFetchObjects
{
    [_collection saveObjects:[EJDBTestFixtures simpleDictionaries]];
    EJDBQuery *query = [[EJDBQuery alloc]initWithCollection:_collection query:@{@"name": @{@"$begin":@"j"}}];
    NSArray *results = [query fetchObjects];
    XCTAssertTrue([results count] == 2, @"Fetched objects count should be exactly 2!");
    XCTAssertTrue([query recordCount] == 2, @"Record count should be exactly 2!");
}

- (void)testFetchObjectsWithQueryBuilder
{
    [_collection saveObjects:[EJDBTestFixtures simpleDictionaries]];
    EJDBQueryBuilder *builder = [[EJDBQueryBuilder alloc]init];
    [builder path:@"name" beginsWith:@"j"];
    EJDBQuery *query = [[EJDBQuery alloc]initWithCollection:_collection queryBuilder:builder];
    NSArray *results = [query fetchObjects];
    XCTAssertTrue([results count] == 2, @"Fetched objects count should be exactly 2!");
    XCTAssertTrue([query recordCount] == 2, @"Record counts should be exactly 2!");
}

- (void)testFetchObjectsWithFIQueryBuilder
{
    [_collection saveObjects:[EJDBTestFixtures simpleDictionaries]];
    EJDBFIQueryBuilder *builder = [EJDBFIQueryBuilder build].beginsWith(@"name",@"j");
    EJDBQuery *query = [[EJDBQuery alloc]initWithCollection:_collection queryBuilder:builder];
    NSArray *results = [query fetchObjects];
    XCTAssertTrue([results count] == 2, @"Fetched objects count should be exactly 2!");
    XCTAssertTrue([query recordCount] == 2, @"Record counts should be exactly 2!");
}

- (void)testFetchObjectsWithError
{
    NSError *error;
    [_collection saveObjects:[EJDBTestFixtures simpleDictionaries]];
    EJDBQuery *query = [[EJDBQuery alloc]initWithCollection:_collection query:@{@"$name": @{@"$begin":@"j"}}];
    NSArray *results = [query fetchObjectsWithError:&error];
    XCTAssertNil(results, @"Results should be nil!");
    XCTAssertNotNil(error, @"Fetched objects error should not be nil!");
}

- (void)testMultipleFetchesSuccess
{
    [_collection saveObjects:[EJDBTestFixtures simpleDictionaries]];
    EJDBQuery *query = [[EJDBQuery alloc]initWithCollection:_collection query:nil];
    NSArray *results = [query fetchObjects];
    XCTAssertTrue([results count] == 3, @"First fetch should return exactly 3 results!");
    [_collection saveObject:@{@"name": @"foo"}];
    NSArray *results2 = [query fetchObjects];
    XCTAssertTrue([results2 count] == 4, @"Second fetch should return exactly 4 results!");
}

- (void)testRecordCount
{
    [_collection saveObjects:[EJDBTestFixtures simpleDictionaries]];
    EJDBQuery *query = [[EJDBQuery alloc]initWithCollection:_collection query:nil];
    [query fetchObjects];
    XCTAssertTrue([query recordCount] == 3, @"Record count should be exactly 3!");
}

@end