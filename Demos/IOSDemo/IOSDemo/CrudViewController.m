#import "CrudViewController.h"
#import "CrudObjectViewController.h"
#import "EJDBKit/EJDBKit.h"
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
    [self setupNotifications];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

- (void)setupNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(collectionObjectSaved:) name:EJDBCollectionObjectSavedNotification object:nil];
}

- (void)collectionObjectSaved:(NSNotification *)notification
{
    CrudObject *object = [notification object];
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"oid == %@",object.oid];
    NSArray *filteredArray = [_rows filteredArrayUsingPredicate:filter];
    if ([ filteredArray count] == 0)
    {
        //insert
        [_rows addObject:object];
        NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:[_rows indexOfObject:[_rows lastObject]] inSection:0];
        [_tableView insertRowsAtIndexPaths:@[lastIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else
    {
        //update
        NSUInteger i = [_rows indexOfObject:filteredArray[0]];
        [_rows replaceObjectAtIndex:i withObject:object];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
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
    UILabel *scoresLabel = (UILabel *)[cell.contentView viewWithTag:4];
    
    CrudObject *crudObj = _rows[indexPath.row];
    nameLabel.text = crudObj.name;
    ageLabel.text = [crudObj.age stringValue];
    moneyLabel.text = [crudObj.money stringValue];
    
    NSMutableString *scoresString = [[NSMutableString alloc] init];
    for (NSNumber *score in crudObj.scores)
    {
        [scoresString appendFormat:@" %@ ",[score stringValue]];
    }
    scoresLabel.text = [scoresString length] > 0 ? scoresString : @"No scores.";
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 126.;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [_tableView setEditing:editing animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [_collection removeObject:_rows[indexPath.row]];
        [_rows removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

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
