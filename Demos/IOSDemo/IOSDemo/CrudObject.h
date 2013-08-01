#import <UIKit/UIKit.h>
#import "EJDBKit/BSONArchiving.h"

@interface CrudObject : NSObject<BSONArchiving,NSCopying>
@property (copy,nonatomic) NSString *oid;
@property (copy,nonatomic) NSString *name;
@property (strong,nonatomic) NSNumber *age;
@property (strong,nonatomic) NSNumber *money;
@property (strong,nonatomic) NSArray *scores;
@end
