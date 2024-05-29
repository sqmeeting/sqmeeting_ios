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

@interface FrtcHistoryMeetingListView () <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) NSArray<FNewMeetingRoomListInfo *> *array;
@property (nonatomic, strong) NSArray<FHomeMeetingListModel *> *historyArray;
@property (nonatomic, assign, getter=isHistory) BOOL history;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, strong) UIButton *clearBtn;

@end

static MeetingBlockselection actionBlockSelect = nil;
static HistoryMeetingBlockselection historyActionBlockSelect = nil;
static ClearHistoryMeetingListBlock clearActionBlock = nil;
static FrtcHistoryMeetingListView *listView = nil;

@implementation FrtcHistoryMeetingListView

+ (void)showWithList:(NSArray<FNewMeetingRoomListInfo *> *)listArray selectIndex:(MeetingBlockselection)blockSelect{
    listView = [[FrtcHistoryMeetingListView alloc]initWithFrame:UIScreen.mainScreen.bounds];
    actionBlockSelect = blockSelect;
    listView.array = listArray;
    listView.history = NO;
    [listView.tableView reloadData];
    [[[UIApplication sharedApplication].delegate window] addSubview:listView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithActionBlock:^(id  _Nonnull sender) {
        [listView disMiss];
    }];
    tap.delegate = listView;
    [listView addGestureRecognizer:tap];
}

+ (void)showHistoryWithList:(NSArray<FHomeMeetingListModel *> *)listArray selectIndex:(HistoryMeetingBlockselection)blockSelect clearData:(ClearHistoryMeetingListBlock)clearBlock {
    
    listView = [[FrtcHistoryMeetingListView alloc]initWithFrame:UIScreen.mainScreen.bounds];
    historyActionBlockSelect = blockSelect;
    clearActionBlock = clearBlock;
    listView.historyArray = listArray;
    listView.history = YES;
    [listView.clearBtn setTitle:NSLocalizedString(@"clear_history", nil) forState:UIControlStateNormal];
    [listView.tableView reloadData];
    [[[UIApplication sharedApplication].delegate window] addSubview:listView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithActionBlock:^(id  _Nonnull sender) {
        [listView disMiss];
    }];
    tap.delegate = listView;
    [listView addGestureRecognizer:tap];
}


- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        self.contentView = [[UIView alloc]initWithFrame:CGRectMake(0, KScreenHeight, KScreenWidth, KHistoryMeetingHeight)];
        self.contentView.backgroundColor = UIColor.whiteColor;
        [self addSubview:self.contentView];
        
        CGFloat radius = 12;
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.contentView.bounds byRoundingCorners:( UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(radius, radius)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.contentView.bounds;
        maskLayer.path = path.CGPath;
        self.contentView.layer.mask = maskLayer;
        
        [self.contentView addSubview:self.headerView];
        [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.mas_equalTo(0);
            make.height.mas_equalTo(50);
        }];
        
        [self.contentView addSubview:self.tableView];
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_equalTo(0);
            make.top.equalTo(self.headerView.mas_bottom);
        }];
    }
    return self;
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    [UIView animateWithDuration:0.25
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
        CGRect rect = self.contentView.frame;
        rect.origin.y = KScreenHeight - KHistoryMeetingHeight;
        self.contentView.frame = rect;
    } completion:nil];
}

- (void)disMiss{
    [UIView animateWithDuration:0.25 animations:^{
        CGRect rect =  self.contentView.frame;
        rect.origin.y = KScreenHeight;
        self.contentView.frame = rect;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        actionBlockSelect = nil;
        actionBlockSelect = nil;
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
            if (historyActionBlockSelect) {
                historyActionBlockSelect(info);
            }
        }
    }else{
        if (self.array.count > _selectedIndex) {
            FNewMeetingRoomListInfo *info = self.array[_selectedIndex];
            if (actionBlockSelect) {
                actionBlockSelect(info);
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

- (UIView *)headerView {
    @WeakObj(self);
    if (!_headerView) {
        _headerView = [[UIView alloc]init];
        _clearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_clearBtn setTitle:@"" forState:UIControlStateNormal];
        _clearBtn.titleLabel.font = [UIFont systemFontOfSize:14.f];
        [_clearBtn setTitleColor:KDetailTextColor forState:UIControlStateNormal];
        [_clearBtn addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
            @StrongObj(self)
            if (clearActionBlock) {
                clearActionBlock();
            }
            [self disMiss];
        }];
        
        UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [doneBtn setTitle:NSLocalizedString(@"string_done", nil) forState:UIControlStateNormal];
        doneBtn.titleLabel.font = [UIFont systemFontOfSize:14.f];
        [doneBtn setTitleColor:kMainColor forState:UIControlStateNormal];
        [doneBtn addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
            @StrongObj(self)
            if (self.array.count > self.selectedIndex) {
                FNewMeetingRoomListInfo *info = self.array[self.selectedIndex];
                if (actionBlockSelect) {
                    actionBlockSelect(info);
                }
            }
            [self disMiss];
        }];
        
        UIStackView *stackView = [[UIStackView alloc]init];
        stackView.distribution = UIStackViewDistributionEqualSpacing;
        stackView.alignment     = UIStackViewAlignmentCenter;
        [_headerView addSubview:stackView];
        
        [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(KLeftSpacing);
            make.right.mas_equalTo(-KLeftSpacing);
            make.centerY.equalTo(_headerView);
        }];
        [stackView addArrangedSubviews:@[_clearBtn,doneBtn]];
    }
    return _headerView;
}

#pragma mark - lazy

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 50;
        _tableView.backgroundColor = KBGColor;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[FrtcPopUpHistoryListCell class] forCellReuseIdentifier:KPopupHistoryMeetingCell];
    }
    return _tableView;
}

@end
