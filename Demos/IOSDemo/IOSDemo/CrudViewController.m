#import "CrudViewController.h"
#import "CrudObjectViewController.h"
#import "EJDBKit.h"
#import "CrudObject.h"

@interface CrudViewController ()
@property (strong,nonatomic) EJDBDatabase *db;
@property (strong,nonatomic) EJDBCollection *collection;
@property (strong,nonatomic) NSMutableArray *rows;
@end

@implementation CrudViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self openDb];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [_db close];
}

- (void)openDb
{
    _rows = [[NSMutableArray alloc]init];
    _db = [[EJDBDatabase alloc]initWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@""] dbFileName:@"test.db"];
    [_db openWithError:NULL];
    _collection = [_db ensureCollectionWithName:@"crud" error:NULL];
    [self fetchObjects];
}

- (void)fetchObjects
{
    [_rows removeAllObjects];
    NSArray *results = [_db findObjectsWithQuery:nil inCollection:_collection error:NULL];
    [_rows addObjectsFromArray:results];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_rows count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CrudCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:1];
    UILabel *ageLabel = (UILabel *)[cell.contentView viewWithTag:2];
    UILabel *moneyLabel = (UILabel *)[cell.contentView viewWithTag:3];
    
    CrudObject *crudObj = _rows[indexPath.row];
    nameLabel.text = crudObj.name;
    ageLabel.text = [crudObj.age stringValue];
    moneyLabel.text = [crudObj.money stringValue];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CrudObjectViewController *crudObjCtl = [self.storyboard instantiateViewControllerWithIdentifier:@"CrudObjectViewController"];
    crudObjCtl.collection = _collection;
    crudObjCtl.crudObject = [[_rows objectAtIndex:indexPath.row] copy];
    [self.navigationController pushViewController:crudObjCtl animated:YES];
}

- (IBAction)addObjectButtonPressed:(id)sender
{
    CrudObjectViewController *crudObjCtl = [self.storyboard instantiateViewControllerWithIdentifier:@"CrudObjectViewController"];
    crudObjCtl.collection = _collection;
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:crudObjCtl];
    [self.navigationController presentViewController:navController animated:YES completion:NULL];
}

@end
