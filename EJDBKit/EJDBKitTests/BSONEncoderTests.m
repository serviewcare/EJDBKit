#import "BSONEncoderTests.h"
#import "BSONEncoder.h"
#import "EJDBCollection.h"
#import "EJDBDatabase+DBTestExtensions.h"

/**
 Some of these test objects are shamelessly ripped from the official ejdb github repo at https://github.com/Softmotions/ejdb
 Yeah, so I'm lazy...what of it? :)
*/

@interface BSONEncoderTests ()
@property (strong,nonatomic) EJDBDatabase *db;
@end

@implementation BSONEncoderTests

- (void)setUp
{
    [super setUp];
    _db = [EJDBDatabase createAndOpenDb];
}

- (void)tearDown
{
    [EJDBDatabase closeAndDeleteDb:_db];
    [super tearDown];
}

- (void)testEncodingA1Object
{
    NSDictionary *inDictionary =
    @{
      @"_id" : @"123456789012345678901234",
      @"name" : @"Антонов",
      @"phone" : @"333-222-333",
      @"age" : @33,
      @"longscore" : @0xFFFFFFFFFF01LL,
      @"dblscore" : @0.333333,
      @"address" :
        @{
          @"city" : @"Novosibirsk",
          @"country" : @"Russian Federation",
          @"zip" : @"630090",
          @"street" : @"Pirogova",
          @"room" : @334
         },
      @"complexarr" :
        @[
            @{
                @"foo" : @"bar",
                @"foo2" : @"bar2",
                @"foo3" : @"bar3"
             },
            @{
                @"foo" : @"bar",
                @"foo2" : @"bar3"
            },
            @333
         ]
    };
    
    EJDBCollection *collection = [_db ensureCollectionWithName:@"foo" error:NULL];
    [collection saveObject:inDictionary];
    NSArray *results = [_db findObjectsWithQuery:@{@"name" : @"Антонов"} inCollection:collection error:NULL];
    NSDictionary *outDictionary = results[0];
    STAssertTrue([inDictionary isEqualToDictionary:outDictionary], @"Encoded and Decoded dictionaries should be the same!");
}

@end
