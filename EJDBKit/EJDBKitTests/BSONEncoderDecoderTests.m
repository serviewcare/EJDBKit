#import "BSONEncoderDecoderTests.h"
#import "BSONEncoder.h"
#import "EJDBCollection.h"
#import "EJDBDatabase+DBTestExtensions.h"

/**
 Some of these test objects are shamelessly ripped from the official ejdb github repo at https://github.com/Softmotions/ejdb
 Yeah, so I'm lazy...what of it? :)
*/

@interface BSONEncoderDecoderTests ()
@property (strong,nonatomic) EJDBDatabase *db;
@end

@implementation BSONEncoderDecoderTests

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

- (NSDictionary *)A1Object
{
    return @{
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
}

- (NSDictionary *)A2Object
{
    return @{
      @"_id" : @"123456789012345678901234",
      @"name" : @"Адаманский",
      @"phone" : @"444-123-333",
      @"longscore" : @0xFFFFFFFFFF02LL,
      @"dblscore" : @0.93,
      @"address" :
          @{
              @"city" : @"Novosibirsk",
              @"country" : @"Russian Federation",
              @"zip" : @"630090",
              @"street" : @"Pirogova"
              },
      @"labels" :
          @[
              @{@"0" : @"red"},@{@"1" : @"green"},@{@"2" : @"with gap, label"}
              ],
      @"drinks" :
          @[
              @{@"0" : @4},@{@"1" : @556667},@{@"2": @77676.22}
              ]
      };
}

- (void)testEncodingDecodingA1Object
{
    NSDictionary *inDictionary = [self A1Object];
    EJDBCollection *collection = [_db ensureCollectionWithName:@"foo" error:NULL];
    [collection saveObject:inDictionary];
    NSArray *results = [_db findObjectsWithQuery:@{@"name" : @"Антонов"} inCollection:collection error:NULL];
    NSDictionary *outDictionary = results[0];
    STAssertTrue([inDictionary isEqualToDictionary:outDictionary], @"Encoded and Decoded dictionaries should be the same!");
}

- (void)testEncodingDecodingA2Object
{
    NSDictionary *inDictionary = [self A2Object];
    EJDBCollection *collection = [_db ensureCollectionWithName:@"foo" error:NULL];
    [collection saveObject:inDictionary];
    NSArray *results = [_db findObjectsWithQuery:@{@"name" : @"Адаманский"} inCollection:collection error:NULL];
    NSDictionary *outDictionary = results[0];
    STAssertTrue([inDictionary isEqualToDictionary:outDictionary], @"Encoded and Decoded dictionaries should be the same!");
}


- (void)testEncodingDecodingNSData
{
    NSData *imageDataIn = [NSData dataWithContentsOfFile:[[NSBundle bundleForClass:[self class]]
                                                          pathForResource:@"ejdblogo3" ofType:@"png"]];
    NSDictionary *inDictionary = @{@"name":@"logo",@"image": imageDataIn};
    EJDBCollection *collection = [_db ensureCollectionWithName:@"foo" error:NULL];
    [collection saveObject:inDictionary];
    NSArray *results = [_db findObjectsWithQuery:@{@"name" : @"logo"} inCollection:collection error:NULL];
    NSDictionary *outDictionary = results[0];
    NSData *imageDataOut = [outDictionary objectForKey:@"image"];
    STAssertTrue([imageDataIn isEqualToData:imageDataOut], @"Image in and Image out data should be equal!");
}

- (void)testEncodingDecodingNSNull
{
    NSDictionary *inDictionary = @{@"name": @"null obj",@"nullval":[NSNull null]};
    EJDBCollection *collection = [_db ensureCollectionWithName:@"foo" error:NULL];
    [collection saveObject:inDictionary];
    NSArray *results = [_db findObjectsWithQuery:@{@"name" : @"null obj"} inCollection:collection error:NULL];
    NSDictionary *outDictionary = results[0];
    STAssertTrue([[inDictionary objectForKey:@"nullval"]
                  isEqual:[outDictionary objectForKey:@"nullval"]], @"Out null obj should match in!");
}

- (void)testShouldThrowExceptionOnInvalidOID
{
    BOOL threwException = NO;
    NSDictionary *inDictionary = @{@"_id": @"123"};
    BSONEncoder *encoder = [[BSONEncoder alloc]init];
    @try {
        [encoder encodeDictionary:inDictionary];
    }
    @catch (NSException *exception) {
        threwException = YES;
    }
    @finally {
        [encoder finish];
        encoder = nil;
        STAssertTrue(threwException, @"Encoding should have thrown an Exception for invalid oid!");
    }
}

- (void)testShouldThrowExceptionOnUnsupportedType
{
    BOOL threwException = NO;
    NSDictionary *inDictionary = @{@"unsupported type" : [NSSet setWithArray:@[@1,@2]]};
    BSONEncoder *encoder = [[BSONEncoder alloc]init];
    @try {
        [encoder encodeDictionary:inDictionary];
    }
    @catch (NSException *exception) {
        threwException = YES;
    }
    @finally {
        [encoder finish];
        encoder = nil;
        STAssertTrue(threwException, @"Encoding should have thrown an Exception for unsupported type!");
    }
}

@end