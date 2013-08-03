#import <Foundation/Foundation.h>
#import "BSONArchiving.h"

@interface CustomArchivableClass : NSObject <BSONArchiving>
@property (copy,nonatomic) NSString *oid;
@property (copy,nonatomic) NSString *name;
@property (strong,nonatomic) NSNumber *age;
@end

@interface BogusOIDClass : CustomArchivableClass

@end

@interface EJDBTestFixtures : NSObject

+ (NSArray *)simpleDictionaries;
+ (NSArray *)complexDictionaries;
+ (CustomArchivableClass *)validArchivableClass;
+ (BogusOIDClass *)bogusOIDClass;

@end
