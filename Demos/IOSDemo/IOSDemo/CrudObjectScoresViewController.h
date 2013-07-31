#import <UIKit/UIKit.h>
@class CrudObject;

@interface CrudObjectScoresViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (strong,nonatomic) CrudObject *crudObject;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *editButton;


- (IBAction)addScoreButtonPressed:(id)sender;


@end
