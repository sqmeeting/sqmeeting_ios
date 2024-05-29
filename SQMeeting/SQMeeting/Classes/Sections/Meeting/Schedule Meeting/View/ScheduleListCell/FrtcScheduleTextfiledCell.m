#import "FrtcScheduleTextfiledCell.h"
#import "UIImage+Extensions.h"
#import "Masonry.h"
#import "FrtcScheduleMeetingModel.h"
#import "UIControl+Extensions.h"
#import "UITextField+Extensions.h"

@interface FrtcScheduleTextfiledCell() <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *editBtn;

@end

@implementation FrtcScheduleTextfiledCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageFromColor:kCellSelecteColor]];
        [self configView];
        CALayer *layer = [CALayer new];
        layer.backgroundColor = KLineColor.CGColor;
        layer.frame = CGRectMake(KLeftSpacing, 50 - 1, KScreenWidth - KLeftSpacing*2 , 0.5);
        [self.contentView.layer addSublayer:layer];
    }
    return self;
}

- (void)dealloc {
    
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (self.textFieldDidEndEditing) {
        NSString *content = [self.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        self.textFieldDidEndEditing(content);
    }
}

- (void)setModel:(FrtcScheduleMeetingModel *)model {
    _model = model;
    _textField.text = _model.title;
}

- (void)configView {
    
    _textField = [UITextField new];
    _textField.textColor = KTextColor;
    _textField.fLengthLimit = 30;
    _textField.font = [UIFont boldSystemFontOfSize:16.f];
    _textField.delegate = self;
    [self.contentView addSubview:_textField];
    
    _editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_editBtn setImage:[UIImage imageNamed:@"schedule_edit"] forState:UIControlStateNormal];
    [_editBtn setTitleColor:UIColor.redColor forState:UIControlStateNormal];
    @WeakObj(self);
    [_editBtn addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
        @StrongObj(self)
        [self.textField becomeFirstResponder];
    }];
    [self.contentView addSubview:_editBtn];
    
    [_editBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-KLeftSpacing);
        make.centerY.equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    
    [_textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(0);
        make.left.mas_equalTo(KLeftSpacing);
        make.right.equalTo(_editBtn.mas_left).mas_offset(-10).priority(750);
    }];
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
