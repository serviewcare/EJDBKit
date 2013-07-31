#import <UIKit/UIKit.h>

@interface CrudViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)addObjectButtonPressed:(id)sender;

@end
