#import "FrtcHistoryMeetingListView.h"
#import "UIStackView+Extensions.h"
#import "Masonry.h"
#import "UIControl+Extensions.h"
#import "FrtcPopUpHistoryListCell.h"
#import "UIGestureRecognizer+Extensions.h"
#import "FrtcNewMeetingRoomListModel.h"
#import "FrtcHomeMeetingListPresenter.h"

#define KPopupHistoryMeetingCell @"KPopupHistoryMeetingCell"
#define KHistoryMeetingHeight  250
#define KHistoryTableCellHeight  40

@interface FrtcHistoryMeetingListView () <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, strong) UIButton *clearBtn;

@end


@implementation FrtcHistoryMeetingListView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        [self addView];
    }
    return self;
}

- (void)addView {
    self.backgroundColor = UIColor.clearColor;
    self.layer.cornerRadius = KCornerRadius;
    
    self.layer.borderColor = KLineColor.CGColor;
    self.layer.borderWidth = 1.f;
    self.layer.shadowColor = UIColor.blackColor.CGColor;
    self.layer.shadowRadius = KCornerRadius;
    self.layer.shadowOffset = CGSizeMake(3, 3);
    
    self.contentView = [[UIView alloc]init];
    self.contentView.backgroundColor = UIColor.whiteColor;
    [self addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(0);
    }];
    
    [self.contentView addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(8);
        make.bottom.mas_equalTo(-KHistoryTableCellHeight);
    }];
    
    if (self.isHistory) {
        [self.contentView addSubview:self.clearBtn];
        [self.clearBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.tableView.mas_bottom);
            make.left.right.mas_equalTo(0);
            make.height.mas_equalTo(KHistoryTableCellHeight);
        }];
    }
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    [UIView animateWithDuration:0.25
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
        [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(190);
        }];
        [self.contentView.superview layoutIfNeeded];
    } completion:nil];
}

- (void)disMiss {
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
        [self.contentView layoutIfNeeded];
        [self.contentView.superview layoutIfNeeded];
        self.clearBtn.alpha = 0.f;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - UITableViewDelegate,UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isHistory) {
        return self.historyArray.count;
    }
    return self.array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FrtcPopUpHistoryListCell *cell = [tableView dequeueReusableCellWithIdentifier:KPopupHistoryMeetingCell forIndexPath:indexPath];
    if (self.isHistory) {
        FHomeMeetingListModel *info = self.historyArray[indexPath.row];
        cell.titleLabel.text = info.meetingName;
        cell.detailLabel.text = info.meetingNumber;
        return cell;
    }else{
        FNewMeetingRoomListInfo *info = self.array[indexPath.row];
        cell.titleLabel.text = info.meetingroom_name;
        cell.detailLabel.text = info.meeting_number;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _selectedIndex = indexPath.row;
    if (self.isHistory) {
        if (self.historyArray.count > indexPath.row) {
            FHomeMeetingListModel *info = self.historyArray[indexPath.row];
            if (_historySelectedBlock) {
                _historySelectedBlock(info);
            }
        }
    }else{
        if (self.array.count > _selectedIndex) {
            FNewMeetingRoomListInfo *info = self.array[_selectedIndex];
            if (_selectedBlock) {
                _selectedBlock(info);
            }
        }
    }
    [self disMiss];
}

#pragma mark - UIGestureRecognizerDelegate

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([NSStringFromClass([touch.view class]) isEqualToString:NSStringFromClass([self class])]) {
        return YES;
    }
    return NO;
}

#pragma mark - lazy
- (UIButton *)clearBtn {
    @WeakObj(self);
    if (!_clearBtn) {
        _clearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_clearBtn setTitle:NSLocalizedString(@"clear_history", nil) forState:UIControlStateNormal];
        [_clearBtn setTitleColor:KTextColor666666 forState:UIControlStateNormal];
        _clearBtn.titleLabel.font = [UIFont systemFontOfSize:14.f];
        _clearBtn.backgroundColor = KBGColor;
        [_clearBtn setTitleColor:KDetailTextColor forState:UIControlStateNormal];
        [_clearBtn addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
            @StrongObj(self)
            if (self.clearhistoryBlock) {
                self.clearhistoryBlock();
            }
        }];
    }
    return _clearBtn;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = KHistoryTableCellHeight;
        _tableView.backgroundColor = UIColor.whiteColor;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[FrtcPopUpHistoryListCell class] forCellReuseIdentifier:KPopupHistoryMeetingCell];
    }
    return _tableView;
}

@end
