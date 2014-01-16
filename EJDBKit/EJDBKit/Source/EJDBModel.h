#import <Foundation/Foundation.h>
#import "BSONArchiving.h"

@interface EJDBModel : NSObject<BSONArchiving>
@property (copy,nonatomic) NSString *oid;
@end
