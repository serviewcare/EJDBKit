#import "CrudObjectViewController.h"
#import "CrudObject.h"
#import "CrudObjectScoresViewController.h"

@interface CrudObjectViewController ()
@property (assign,nonatomic) BOOL isNewObject;
@property (weak,nonatomic) UITextField *firstResponderTextField;
@end

@implementation CrudObjectViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupNavbarButtons];
    [self createCrudObjectIfNecessary];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setupNavbarButtons
{
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed)];
    self.navigationItem.leftBarButtonItem = cancelButtonItem;
    UIBarButtonItem *saveButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonPressed)];
    self.navigationItem.rightBarButtonItem = saveButtonItem;
}

- (void)createCrudObjectIfNecessary
{
    _isNewObject = _crudObject == nil ? YES : NO;
    if (_isNewObject)
    {
        _crudObject = [[CrudObject alloc]init];
        _crudObject.scores = @[]; // Remember...we can't insert a nil into a dictionary!
        //_crudObject.testDict = @{@"test" : @"me just a filler!", @"repeat" : @"I say again, me just a filler!"};
    }
}

- (void)cancelButtonPressed
{
    if (_isNewObject)
    {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)saveButtonPressed
{
    [_firstResponderTextField resignFirstResponder];
    
    UITableViewCell *nameCell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    UITableViewCell *ageCell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    UITableViewCell *moneyCell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    
    _crudObject.name = [(UITextField *)[nameCell.contentView viewWithTag:2] text];
    _crudObject.age = [NSNumber numberWithInt:[[(UITextField *)[ageCell.contentView viewWithTag:2] text]intValue]];
    _crudObject.money =  [NSNumber numberWithDouble:[[(UITextField *)[moneyCell.contentView viewWithTag:2] text]doubleValue]];
    
    if ([_crudObject.name length] == 0 || !_crudObject.age || !_crudObject.money) return;
    
    if ([_collection saveObject:_crudObject])
    {
        [self cancelButtonPressed];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Save failed!" message:@"Couldn't save object" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alertView show];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CrudFieldCell";
    static NSString *ScoresCellIdentifier = @"CrudScoresCell";
    UITableViewCell *cell;
    if (indexPath.row == 3)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:ScoresCellIdentifier forIndexPath:indexPath];
        cell.textLabel.text = @"Scores";
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        UITextField *txtField = (UITextField *)[cell.contentView viewWithTag:2];
        
        if (indexPath.row == 0)
        {
            txtField.keyboardType = UIKeyboardTypeASCIICapable;
            txtField.text = _crudObject.name;
            txtField.placeholder = @"name";
        }
        else if (indexPath.row == 1)
        {
            txtField.keyboardType = UIKeyboardTypeNumberPad;
            txtField.text = [_crudObject.age stringValue];
            txtField.placeholder = @"age";
        }
        else if (indexPath.row == 2)
        {
            txtField.keyboardType = UIKeyboardTypeDecimalPad;
            txtField.text = [_crudObject.money stringValue];
            txtField.placeholder = @"money";
        }
    }
        
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 3)
    {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        CrudObjectScoresViewController *scoresCtl = [self.storyboard instantiateViewControllerWithIdentifier:@"CrudObjectScoresViewController"];
        scoresCtl.crudObject = _crudObject;
        UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:scoresCtl];
        [self.navigationController presentViewController:navController animated:YES completion:NULL];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.;
}

@end
