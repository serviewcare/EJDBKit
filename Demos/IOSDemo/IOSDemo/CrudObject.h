#import <UIKit/UIKit.h>
#import "BSONArchiving.h"

@interface CrudObject : NSObject<BSONArchiving>
@property (copy,nonatomic) NSString *oid;
@property (copy,nonatomic) NSString *name;
@property (strong,nonatomic) NSNumber *age;
@property (strong,nonatomic) NSNumber *money;
@end
