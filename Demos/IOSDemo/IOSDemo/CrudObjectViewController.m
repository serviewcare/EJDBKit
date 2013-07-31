#import "CrudObjectViewController.h"
#import "CrudObject.h"

@interface CrudObjectViewController () <UITextFieldDelegate>
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
    // Dispose of any resources that can be recreated.
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
    if (!_crudObject.name || !_crudObject.age || !_crudObject.money) return;
    
    if ([_collection saveObject:_crudObject])
    {
        [self cancelButtonPressed];
    }
    else
    {
        NSLog(@"Save not successful!");
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CrudFieldCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    UITextField *txtField = (UITextField *)[cell.contentView viewWithTag:2];
    txtField.delegate = self;
    
    if (indexPath.row == 0)
    {
        txtField.text = _crudObject.name;
        txtField.placeholder = @"name";
    }
    else if (indexPath.row == 1)
    {
        txtField.text = [_crudObject.age stringValue];
        txtField.placeholder = @"age";
    }
    else if (indexPath.row == 2)
    {
        txtField.text = [_crudObject.money stringValue];
        txtField.placeholder = @"money";
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    _firstResponderTextField = textField;
    _tableView.frame= CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y, _tableView.frame.size.width, _tableView.frame.size.height - 190);
    CGPoint p = [[textField superview]superview].frame.origin;
    NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:p];
    [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    CGPoint point = [[textField superview]superview].frame.origin;
    NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:point];
    if (indexPath.row == 0)
    {
        _crudObject.name = textField.text;
    }
    else if (indexPath.row == 1)
    {
        _crudObject.age = [NSNumber numberWithInt:[textField.text intValue]];
    }
    else if (indexPath.row == 2)
    {
        _crudObject.money = [NSNumber numberWithDouble:[textField.text doubleValue]];
    }
}

@end
