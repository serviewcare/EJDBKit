#import "EJDBQueryTests.h"
#import "EJDBDatabase+DBTestExtensions.h"
#import "EJDBQuery.h"
#import "EJDBCollection.h"
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
    [super tearDown];
}

- (void)testFetchCount
{
    [_collection saveObjects:[EJDBTestFixtures simpleDictionaries]];
    EJDBQuery *query = [_db createQuery:@{@"name":@{@"$begin":@"j"}} forCollection:_collection error:NULL];
    STAssertTrue([query fetchCount] == 2, @"Fetch count should return exactly 2 records!");
}

- (void)testFetchObject
{
    NSString *name = [[EJDBTestFixtures simpleDictionaries][0] objectForKey:@"name"];
    [_collection saveObjects:[EJDBTestFixtures simpleDictionaries]];
    EJDBQuery *query = [_db createQuery:@{@"name":@{@"$begin":@"j"}} hints:@{@"$fields":@{@"name": @1}} forCollection:_collection error:NULL];
    NSDictionary *object = [query fetchObject];
    STAssertNotNil(object, @"Fetched object should not be nil!");
    STAssertTrue([[object objectForKey:@"name"] isEqualToString:name], @"Saved name should equal fetched name!");
}

- (void)testFetchObjects
{
    [_collection saveObjects:[EJDBTestFixtures simpleDictionaries]];
    EJDBQuery *query = [_db createQuery:@{@"name": @{@"$begin":@"j"}} forCollection:_collection error:NULL];
    NSArray *results = [query fetchObjects];
    STAssertTrue([results count] == 2, @"Fetched objects count should be exactly 2!");
    STAssertTrue([query recordCount] == 2, @"Record count should be exactly 2!");
}

@end