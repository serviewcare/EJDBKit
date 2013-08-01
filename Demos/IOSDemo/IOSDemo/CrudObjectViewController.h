#import <UIKit/UIKit.h>
//#import "EJDBCollection.h"
#import "EJDBKit/EJDBCollection.h"

@class CrudObject;

@interface CrudObjectViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
@property (copy,nonatomic) CrudObject *crudObject;
@property (weak,nonatomic) EJDBCollection *collection;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end
