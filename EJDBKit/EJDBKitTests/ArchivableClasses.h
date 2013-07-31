#import <Foundation/Foundation.h>
#import "BSONArchiving.h"

@interface CustomArchivableClass : NSObject <BSONArchiving>
@property (copy,nonatomic) NSString *oid;
@property (copy,nonatomic) NSString *name;
@property (strong,nonatomic) NSNumber *age;
@end

@interface BogusOIDClass : CustomArchivableClass

@end

@interface ArchivableClasses : NSObject
+ (CustomArchivableClass *)validArchivableClass;
+ (BogusOIDClass *)boguisOIDClass;
@end


