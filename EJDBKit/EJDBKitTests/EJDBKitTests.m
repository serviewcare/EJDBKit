#import "EJDBKitTests.h"
#import "EJDBKit.h"

@interface EJDBKitTests ()
@property (strong,nonatomic) EJDBDatabase *db;
@end

@implementation EJDBKitTests

- (void)setUp
{
    [super setUp];
    NSString *dbPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"test.ejdb"];
    [[NSFileManager defaultManager] removeItemAtPath:dbPath error:nil];
    _db = [[EJDBDatabase alloc]initWithPath:dbPath];
    BOOL success = [_db open];
    STAssertTrue(success, @"Db should open successfully!");
    
}

- (void)tearDown
{
    [_db close];
    
    [super tearDown];
}

- (NSArray *)simpleTestFields
{
    EJDBField *name = [[EJDBField alloc]initWithKey:@"name" fieldType:EJDBFieldTypeString value:@"Joe blow"];
    EJDBField *age = [[EJDBField alloc]initWithKey:@"age" fieldType:EJDBFieldTypeInt value:@36];
    EJDBField *money = [[EJDBField alloc]initWithKey:@"money" fieldType:EJDBFieldTypeDouble value:@1234567.89];
    EJDBField *isMarried = [[EJDBField alloc]initWithKey:@"isMarried" fieldType:EJDBFieldTypeBool value:@NO];
    EJDBField *date = [[EJDBField alloc]initWithKey:@"date" fieldType:EJDBFieldTypeDate value:[NSDate date]];
    
    return [NSArray arrayWithObjects:name,age,money,isMarried,date, nil];
}

- (NSArray *)complexTestNonObjectArrayFields
{
    NSMutableArray *fields = [NSMutableArray arrayWithArray:[self simpleTestFields]];
    EJDBField *val1 = [[EJDBField alloc]initWithKey:@"val1" fieldType:EJDBFieldTypeString value:@"This is val1."];
    EJDBField *val2 = [[EJDBField alloc]initWithKey:@"val1" fieldType:EJDBFieldTypeInt value:@22];
    EJDBField *arr = [[EJDBField alloc]initWithKey:@"arr" fieldType:EJDBFieldTypeArray value:@[val1,val2]];
    [fields addObject:arr];
    return [NSArray arrayWithArray:fields];
}

- (NSArray *)complexTestObjectArrayFields
{
    NSMutableArray *fields = [NSMutableArray arrayWithArray:[self simpleTestFields]];
    //EJDBRecord *record = [[EJDBRecord alloc]init];
    EJDBRecord *record1 = [[EJDBRecord alloc]initWithFields:[self simpleTestFields]];
    EJDBRecord *record2 = [[EJDBRecord alloc]initWithFields:[self simpleTestFields]];
    EJDBField *field1 = [[EJDBField alloc]initWithKey:@"otherPeople" fieldType:EJDBFieldTypeObjectArray value:record1];
    EJDBField *field2 = [[EJDBField alloc]initWithKey:@"otherPeople" fieldType:EJDBFieldTypeObjectArray value:record2];
    [fields addObject:field1];
    [fields addObject:field2];
    return [NSArray arrayWithArray:fields];
}

- (void)testCollectionDoesNotExist
{
    EJDBCollection *collection = [_db collectionWithName:@"foo"];
    STAssertNil(collection, @"collection should be nil!");
}

- (void)testCollectionCreatedSuccessfully
{
    EJDBCollection *fooCollection = [_db createCollectionWithName:@"foo" options:NULL];
    STAssertNotNil(fooCollection, @"collection should not be nil!");
    
}

- (void)testSingleRecordSavedSuccessfully
{
    EJDBCollection *fooCollection = [_db createCollectionWithName:@"foo"];
    EJDBRecord *record = [[EJDBRecord alloc]init];
    for (EJDBField *field in [self simpleTestFields])
    {
        [record addField:field];
    }
    [record close];
    BOOL success = [fooCollection saveRecord:record];
    STAssertTrue(success, @"collection should save record successfully!");
    ejdbexport(_db.db, "/var/tmp/ejdbexport", NULL, JBJSONEXPORT, NULL);
}

- (void)testSingleRecordWithConvenienceInitSavedSuccessfully
{
    EJDBCollection *fooCollection = [_db createCollectionWithName:@"foo"];
    EJDBRecord *record = [[EJDBRecord alloc]initWithFields:[self simpleTestFields]];
    [record close];
    BOOL success = [fooCollection saveRecord:record];
    STAssertTrue(success, @"collection should save record successfully with convenience initializer!");
}

/*
- (void)testSingleRecordWithArraySavedSuccessfully
{
    EJDBCollection *fooCollection = [_db createCollectionWithName:@"foo"];
    EJDBRecord *record = [[EJDBRecord alloc]initWithFields:[self complexTestNonObjectArrayFields]];
    [record close];
    BOOL success = [fooCollection saveRecord:record];
    STAssertTrue(success, @"record with array should save successfully!");
    //ejdbexport(_db.db, "/var/tmp/ejdbexport", NULL, JBJSONEXPORT, NULL);
}

- (void)testSingleRecordWithArrayObjectsSavedSuccessfully
{
    EJDBCollection *fooCollection = [_db createCollectionWithName:@"foo"];
    EJDBRecord *record = [[EJDBRecord alloc]initWithFields:[self complexTestObjectArrayFields]];
    [record close];
    BOOL success = [fooCollection saveRecord:record];
    STAssertTrue(success, @"record with array should save successfully!");
    ejdbexport(_db.db, "/var/tmp/ejdbexport", NULL, JBJSONEXPORT, NULL);
}
*/


@end
