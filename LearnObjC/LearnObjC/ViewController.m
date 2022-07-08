//
//  ViewController.m
//  LearnObjC
//
//  Created by czeras on 2022/6/5.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic,strong) UICollectionView *collectionView;
// 数据源
@property (nonatomic,strong) NSMutableArray *dataArray;

@end

@implementation ViewController

-(NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

-(UICollectionView *)collectionView{
    if (!_collectionView) {
        WaterFlowLayout *layout = [[WaterFlowLayout alloc]init];
        layout.delegate = self;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight-(50 + XBottomSafeAeraH+WTNaviBarMaxY)) collectionViewLayout:layout];
        _collectionView.backgroundColor = UIColorFromRGB(0xFAFAFA, 1);
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView registerClass:[WTWaterCollectionCell class] forCellWithReuseIdentifier:NSStringFromClass([WTWaterCollectionCell class])];
    }
    return _collectionView;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUpUI];
    

    
    self.pageNo = 1;
    
    @weakify(self);
    
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self);
        self.pageNo = 1;
        [self communityCourseListWithType:self.pageTagIndex pageNo:self.pageNo pageSize:kMaxPageNum];
        [self.collectionView.mj_header endRefreshing];
    }];
    self.collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @strongify(self)
        [self communityCourseListWithType:self.pageTagIndex pageNo:++self.pageNo pageSize:kMaxPageNum];
        [self.collectionView.mj_footer endRefreshing];
    }];
    self.collectionView.mj_footer.hidden = YES;
    self.wtEmptyView.hidden = NO;
    [self.collectionView.mj_header beginRefreshing];
}

-(void)setUpUI{
    [self.view addSubview:self.collectionView];
    
    [self.view addSubview:self.wtEmptyView];
    [self.view sendSubviewToBack:self.wtEmptyView];
    self.wtEmptyView.hidden = YES;
    [self.wtEmptyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.height.mas_equalTo(ScreenHeight - (50 + XBottomSafeAeraH+WTNaviBarMaxY));
    }];
    
    self.wtEmptyView.imageView.image = [UIImage imageNamed:@"empty_icon"];
    self.wtEmptyView.titleLabel.text = @"暂时还没有内容哦～";
}

- (void)refreshData{
    self.pageNo = 1;
    [self communityCourseListWithType:self.pageTagIndex pageNo:self.pageNo pageSize:kMaxPageNum];
}

-(void)notiUpdataLocModel:(NSNotification *)noti{
    
    CommunityCourseListModel *tmpModel = noti.userInfo[@"info"];
    for (int i=0; i<self.dataArray.count; i++) {
        CommunityCourseListModel *tmpDataModel = self.dataArray[i];
        
        if (tmpModel.id  == tmpDataModel.id) {
            
            tmpDataModel.like = tmpModel.like;
            tmpDataModel.isLike = tmpModel.isLike;
            
            [self.dataArray replaceObjectAtIndex:i withObject:tmpDataModel];
        
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            
            [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
        }
    }
}

#pragma mark -- 网络请求 ----

/// 获取教程列表
/// @param type 1：3D秀  2：指南
/// @param pageNo <#pageNo description#>
/// @param pageSize <#pageSize description#>
-(void)communityCourseListWithType:(NSInteger)type pageNo:(int)pageNo pageSize:(int)pageSize{
    NSDictionary *parDict = @{
        @"pageNumber":@(pageNo),
        @"pageSize":@(pageSize),
        @"type":@(self.pageTagIndex+1)
    };
    
    @weakify(self);
    [ToolClass showGifLoadingToView:self.view];
    [WTApiInterface communityCourseList:parDict finishblock:^(id response, NSString *errStr, int state) {
        @strongify(self);
        [ToolClass hideGifLoadingToView:self.view];
        if (state!=0) {
            self.wtEmptyView.hidden = NO;
            if (errStr && [errStr isNotBlank]) {
                [ToolClass showMsg:errStr];
            }
            return;
        }
        
        id resData= response[@"data"][@"list"];
        if ([resData isKindOfClass:[NSArray class]]) {
            if (pageNo == 1) {
                [self.dataArray removeAllObjects];
            }
        
            NSArray *resDataArr = resData;
        
            NSArray *listModels = [CommunityCourseListModel mj_objectArrayWithKeyValuesArray:resDataArr];
            
            
            CommunityCourseListModel *ttt = listModels[0];
            WTLog(@" ----<> -- %@ ",ttt.title);
            
            
            [self.dataArray addObjectsFromArray:listModels];
            
            WTLog(@"Time:--%@ dataCount: %lu",[NSThread currentThread],(unsigned long)self.dataArray.count);
            
            [self.collectionView reloadData];
            self.collectionView.mj_footer.hidden = (listModels.count<10);
            self.wtEmptyView.hidden = (self.dataArray.count != 0);
        }
        else{
            self.wtEmptyView.hidden = NO;
            [self.dataArray removeAllObjects];
            [self.collectionView reloadData];
            self.collectionView.mj_footer.hidden = YES;
        }
    }];
}

// 点赞 请求
-(void)communityCourseLikeWithId:(int)Id index:(NSIndexPath *)indexpath{
    @weakify(self);
    [WTApiInterface communityCourseLike:@{@"id":@(Id)} finishblock:^(id response, NSString *errStr, int state) {
        @strongify(self);
        if (state!=0) {
            if (errStr && [errStr isNotBlank]) {
                [ToolClass showMsg:errStr];
            }
            return;
        }
        CommunityCourseListModel *tmpModel = self.dataArray[indexpath.item];
        // 刷新数据
        if (self.pageTagIndex == 0) {
            // 更新模型
            [self updataItem:tmpModel andIndex:indexpath];
            
            [UIView performWithoutAnimation:^{
                // 刷新指定行
                [self.collectionView reloadItemsAtIndexPaths:@[indexpath]];
            }];
        }
        else {
            // 更新模型
            [self updataItem:tmpModel andIndex:indexpath];
            // 刷新指定行
            [UIView performWithoutAnimation:^{
                [self.collectionView reloadItemsAtIndexPaths:@[indexpath]];
            }];
        }
    }];
}

// 设置新模型
-(void)updataItem:(CommunityCourseListModel *)item andIndex:(NSIndexPath *)index{
    
    CommunityCourseListModel *tmpModel = item;
    if (item.isLike) {
        item.isLike = 0;
        item.like -=1;
    }
    else {
        item.isLike = 1;
        item.like += 1;
    }
    
    [self.dataArray replaceObjectAtIndex:index.item withObject:tmpModel];
}


#pragma mark-- 代理方法 ----
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    WTWaterCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([WTWaterCollectionCell class]) forIndexPath:indexPath];
    cell.listModel = self.dataArray[indexPath.item];
    
    @weakify(self);
    cell.selectItemBlock = ^(CommunityCourseListModel * _Nonnull model) {
        @strongify(self);
        if ([ToolClass isLogin:self toViewController:nil]) {
            // 点赞
            [self communityCourseLikeWithId:model.id index:indexPath];
        }
    };
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    CommunityCourseListModel *tmpModel = self.dataArray[indexPath.item];
    
    // 当前资源类型： mediaType 1:图文 2:视频
    if (tmpModel.mediaType == 1) {

        if ([ToolClass isLogin:self toViewController:nil]) {
            WTDetailPictureController *detailVC = [[WTDetailPictureController alloc] init];
            detailVC.Id = tmpModel.id;
            [self.navigationController pushViewController:detailVC animated:YES];
        }
    }
    else {
        // 需要登录
        if ([ToolClass isLogin:self toViewController:nil]) {
            WTDetailVideoController *detailVC = [[WTDetailVideoController alloc] init];
            detailVC.Id = tmpModel.id;
            [self.navigationController pushViewController:detailVC animated:YES];
        }
    }
}


// 这里返回的是高
- (CGFloat)waterFlowLayout:(WaterFlowLayout *)WaterFlowLayout heightForRowAtIndexPath:(NSInteger )index itemWidth:(CGFloat)itemWidth {
    
    CommunityCourseListModel *tmpModel = self.dataArray[index];
    
    
    CGSize topImageSize = [tmpModel getPicViewSizeByDesignWidth:itemWidth];
    CGFloat tmpItemHeight = topImageSize.height;
    
//    NSString *tmpTitleStr = nil;
//    if (tmpModel.title.length<=20) {
//        tmpTitleStr = tmpModel.title;
//    }
//    else {
//        tmpTitleStr = [tmpModel.title substringToIndex:20];
//    }
//
//    // 标题
//    NSMutableAttributedString *noteStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",tmpTitleStr]];
//
//    // 设置行间距
//    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
//    paragraphStyle.lineSpacing = 5;
//    [noteStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0,tmpTitleStr.length)];
//
//    // 设置图片插入到 NSMutableAttributedString 中
//    NSTextAttachment *likeAttchment = [[NSTextAttachment alloc]init];
//    likeAttchment.bounds = CGRectMake(0, -2, 24, 13);//设置frame
//
//    if (tmpModel.isHot == 1) {
//        likeAttchment.image = [UIImage imageNamed:@"hot_icon"];//设置图片
//
//        NSAttributedString *yearString = [NSAttributedString attributedStringWithAttachment:(NSTextAttachment *)(likeAttchment)];
//
//        [noteStr insertAttributedString:yearString atIndex:0];//插入到第几个下标
//
//        NSMutableAttributedString *tmpStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",@" "]];
//        [noteStr insertAttributedString:tmpStr atIndex:1];//插入到第几个下标
//    }
//    else {
//        // 这里没有图片
//        NSMutableAttributedString *tmpStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",@""]];
//        [noteStr insertAttributedString:tmpStr atIndex:1];//插入到第几个下标
//    }
//
//    float widthFloat = itemWidth - adaptScaleWidth(8)*2; // 这里的4 和 DefaultColumnMargin 保持一致
//    CGSize tmpSize = [ToolClass sizeLabelToFit:noteStr width:widthFloat font:[UIFont systemFontOfSize:12 weight:UIFontWeightMedium]];
    
    // 更新数据源
//    tmpModel.titleAttrStr = noteStr;
//    tmpModel.titleLabelHeight = tmpSize.height;
    [self.dataArray replaceObjectAtIndex:index withObject:tmpModel];
   
//    return tmpItemHeight + adaptScaleWidth(8) + tmpSize.height + adaptScaleWidth(7) + adaptScaleWidth(16) +adaptScaleWidth(8);
    
    return tmpItemHeight + adaptScaleWidth(8)  + adaptScaleWidth(7) + adaptScaleWidth(16) +adaptScaleWidth(8);
}

- (void)dealloc{
    WTSLog(@" dealloc ")
    if (_collectionView) {
        _collectionView.delegate = nil;
        _collectionView.dataSource = nil;
        _collectionView = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



@end






