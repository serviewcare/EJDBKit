#import "EJDBErrorTests.h"
#import "EJDBDatabase.h"

@interface EJDBErrorTests ()
@property (strong,nonatomic) EJDBDatabase *db;
@end

@implementation EJDBErrorTests

- (void)setUp
{
    [super setUp];
    _db = [[EJDBDatabase alloc]initWithPath:NSTemporaryDirectory() dbFileName:@"errtest.db"];
}

- (void)tearDown
{
    [_db close];
    [[NSFileManager defaultManager] removeItemAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"errtest.db"] error:nil];
    _db = nil;
    [super tearDown];
}

- (void)testOpenError
{
    NSError *error;
    [_db openWithError:&error];
    BOOL success = [_db openWithError:&error];
    STAssertFalse(success, @"Db Open should not be successful!");
    STAssertNotNil(error, @"Error should not be nil!");
}

- (void)testCreateCollectionError
{
    NSError *error;
    EJDBCollection *collection = [_db ensureCollectionWithName:@"foo" error:&error];
    STAssertNil(collection, @"Collection should be nil!");
    STAssertNotNil(error, @"Error should not be nil!");
}

- (void)testFindInCollectionError
{
    NSError *error;
    [_db openWithError:NULL];
    EJDBCollection *collection = [_db ensureCollectionWithName:@"foo" error:NULL];
    [_db findObjectsWithQuery:@{@"$name":@"whatever"} inCollection:collection error:&error];
    STAssertNotNil(error, @"Error should not be nil!");
}

- (void)testCreateQueryError
{
    NSError *error;
    [_db openWithError:NULL];
    EJDBCollection *collection = [_db ensureCollectionWithName:@"foo" error:NULL];
    [_db createQuery:@{@"$bogus":@"value"} forCollection:collection error:&error];
    STAssertNotNil(error, @"Error should not be nil!");
}

- (void)testTransactionError
{
    [_db openWithError:NULL];
    EJDBCollection *collection = [_db ensureCollectionWithName:@"foo" error:NULL];
    [_db transactionInCollection:collection transaction:^BOOL(EJDBCollection *collection,NSError **error) {
        [_db createQuery:@{@"$bogus":@"value"} forCollection:collection error:error];
        STAssertNotNil(*error, @"Error should not be nil!");
        return YES;
    }];
}

@end
