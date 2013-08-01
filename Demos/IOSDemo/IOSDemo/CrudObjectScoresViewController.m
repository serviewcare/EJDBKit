#import "CrudObjectScoresViewController.h"
#import "CrudObject.h"

@interface CrudObjectScoresViewController ()<UIAlertViewDelegate>
@property (strong,nonatomic) NSMutableArray *crudScores;
@property (strong,nonatomic) NSArray *savedCrudScores;
@end

@implementation CrudObjectScoresViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self setupNavbarButtons];
    [self loadScores];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [_tableView setEditing:editing animated:YES];
}

- (void)setupNavbarButtons
{
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed)];
    self.navigationItem.leftBarButtonItem = cancelButtonItem;
    UIBarButtonItem *saveButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonPressed)];
    self.navigationItem.rightBarButtonItem = saveButtonItem;
    [_editButton addTarget:self action:@selector(editButtonPressed) forControlEvents:UIControlEventTouchUpInside];
}

- (void)cancelButtonPressed
{
    [self dismissViewControllerAnimated:YES completion:^{
        _crudObject.scores = _savedCrudScores;
    }];
}

- (void)saveButtonPressed
{
    _crudObject.scores = [NSArray arrayWithArray:_crudScores];
    [self dismissViewControllerAnimated:YES completion:NULL];
}


- (void)editButtonPressed
{
    if (_tableView.isEditing)
    {
        _tableView.editing = NO;
        [_editButton setTitle:@"Edit" forState:UIControlStateNormal];
    }
    else
    {
        _tableView.editing = YES;
        [_editButton setTitle:@"Done" forState:UIControlStateNormal];
    }
}

- (void)loadScores
{
    _crudScores = [NSMutableArray array];
    [_crudScores addObjectsFromArray:_crudObject.scores];
    _savedCrudScores = _crudObject.scores;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_crudScores count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CrudScoresCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = [_crudScores[indexPath.row]stringValue];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_crudScores removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        if ([_crudScores count] == 0) [_editButton setTitle:@"Edit" forState:UIControlStateNormal];
    }
}

- (IBAction)addScoreButtonPressed:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"New score" message:@"Please enter a numeric score" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Save",@"Cancel", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView textFieldAtIndex:0].keyboardType = UIKeyboardTypeDecimalPad;
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        UITextField *txtField = [alertView textFieldAtIndex:buttonIndex];
        NSString *scoreString = [txtField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([scoreString length] > 0)
        {
            [_crudScores addObject:[NSNumber numberWithDouble:[scoreString doubleValue]]];
            _crudObject.scores = [NSArray arrayWithArray:_crudScores];
            [_tableView reloadData];
        }
    }
}

@end
