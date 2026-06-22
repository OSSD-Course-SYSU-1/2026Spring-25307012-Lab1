/*
 * Copyright (C) 2026 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { hilog } from '@kit.PerformanceAnalysisKit';
import { display } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { WindowUtil } from '../common/WindowUtil';
import { VideoPlayer } from '../view/VideoPlayer';
import { VideoData } from '../common/VideoData';
import CommonConstants from '../constants/CommonConstants';
import { MyDataSource, VideoDataModel } from '../common/VideoDataModel';
import { ShareUtil } from '../common/ShareUtil';
import { BreakpointSystem, DeviceType } from '../common/BreakpointSystem';
import { DistributedManager, MigrationState } from '../common/DistributedManager';
import { MigrationPanel } from '../view/MigrationPanel';

const DOMAIN = 0x0000; // Tag domain.

@Entry
@Component
struct Index {
  private swiperController: SwiperController = new SwiperController();
  private windowUtil: WindowUtil = WindowUtil.getInstance(); // Window-related utility class
  private breakpointSystem: BreakpointSystem = BreakpointSystem.getInstance();
  private distributedManager: DistributedManager = DistributedManager.getInstance();
  
  @State videoInfoList: Array<VideoDataModel> = []; // Video resource list
  @State isFullLandscapeScreen: boolean = false;
  @State isStart: boolean = true; // Playing or pause
  @State currentIndex: number = 0; // Index of the currently playing video
  @State screenWidth: number = 0; // Screen width
  @State screenHeight: number = 0; // Screen height
  
  // 新增状态变量
  @State playCount: number = 0; // 播放计数器
  @State isLiked: boolean = false; // 点赞状态
  @State likeCount: number = 0; // 点赞计数
  
  // 响应式布局状态
  @State currentDeviceType: DeviceType = DeviceType.PHONE;
  @State isMigrationAvailable: boolean = false;
  
  // 流转面板引用
  private migrationPanelRef: MigrationPanel | null = null;

  aboutToAppear() {
    this.videoInfoList = [...VideoData];
    AppStorage.setOrCreate('swiperController', this.swiperController);
    
    // 初始化分布式管理器
    this.initDistributedManager();
    
    // Get screenWidth
    this.getScreenWidth();
    // Monitor window size changes
    this.windowUtil.registerOnWindowSizeChange((size) => {
      hilog.info(DOMAIN, 'testTag', '%{public}s',
        'registerOnWindowSizeChange:' + ' width:' + size.width + ',height:' + size.height);
      
      // 更新屏幕尺寸
      this.screenWidth = size.width;
      this.screenHeight = size.height;
      
      // 更新响应式布局
      this.breakpointSystem.updateScreenSize(size.width, size.height);
      this.currentDeviceType = this.breakpointSystem.getCurrentDeviceType();
      
      if (size.width > size.height) {
        this.isFullLandscapeScreen = true;
      } else {
        this.isFullLandscapeScreen = false;
      }
      // Update screenWidth
      this.getScreenWidth();
    });
  }

  getScreenWidth() {
    display.getAllDisplays((err: BusinessError, data: Array<display.Display>) => {
      const errCode: number = err.code;
      if (errCode) {
        hilog.error(DOMAIN, 'testTag', '%{public}s',
          `Failed to obtain all the display objects. Code: ${err.code}, message: ${err.message}`);
        return;
      }
      this.screenWidth = this.getUIContext().px2vp(data[0].width);
      this.screenHeight = this.getUIContext().px2vp(data[0].height);
      
      // 更新响应式布局系统
      this.breakpointSystem.updateScreenSize(this.screenWidth, this.screenHeight);
      this.currentDeviceType = this.breakpointSystem.getCurrentDeviceType();
      
      hilog.info(DOMAIN, 'testTag', '%{public}s', 
        `Screen: ${this.screenWidth}x${this.screenHeight}, Device: ${this.currentDeviceType}`);
    });
  }
  
  // 初始化分布式管理器
  async initDistributedManager() {
    try {
      const context = getContext(this) as common.UIAbilityContext;
      const success = await this.distributedManager.initialize(context);
      
      if (success) {
        this.isMigrationAvailable = this.distributedManager.isSupported();
        hilog.info(DOMAIN, 'testTag', 'DistributedManager initialized, available: %{public}s', 
          this.isMigrationAvailable.toString());
      }
    } catch (error) {
      hilog.error(DOMAIN, 'testTag', 'Failed to init DistributedManager: %{public}s', 
        JSON.stringify(error));
    }
  }
  
  // 显示流转面板
  showMigrationPanel() {
    if (this.migrationPanelRef) {
      this.migrationPanelRef.show(() => {
        this.showTemporaryToast('流转成功！');
      });
    } else {
      this.showTemporaryToast('流转功能未初始化');
    }
  }
  
  // 处理流转数据恢复
  handleMigrationRestore(migrationData: string) {
    const state = this.distributedManager.parseMigrationData(migrationData);
    if (state) {
      this.currentIndex = state.currentIndex;
      this.playCount = state.playCount;
      this.isLiked = state.isLiked;
      this.likeCount = state.likeCount;
      this.isStart = state.isStart;
      
      // 切换到指定视频
      this.swiperController.changeIndex(this.currentIndex);
      
      this.showTemporaryToast(`已从其他设备恢复播放\n当前第${this.currentIndex + 1}个视频`);
      hilog.info(DOMAIN, 'testTag', 'Migration state restored: %{public}s', JSON.stringify(state));
    }
  }

  // 新增：播放计数方法
  incrementPlayCount() {
    this.playCount++;
    this.showTemporaryToast(`播放次数: ${this.playCount}`);
  }

  // 新增：点赞方法
  handleLike() {
    this.isLiked = !this.isLiked;
    if (this.isLiked) {
      this.likeCount++;
      this.showTemporaryToast('感谢点赞！❤️');
    } else {
      this.likeCount--;
      this.showTemporaryToast('已取消点赞');
    }
  }

  // 新增：切换播放/暂停
  togglePlayPause() {
    this.isStart = !this.isStart;
    if (this.isStart) {
      this.showTemporaryToast('▶ 继续播放');
    } else {
      this.showTemporaryToast('⏸ 暂停播放');
    }
  }

  // 新增：上一视频
  previousVideo() {
    if (this.currentIndex > 0) {
      this.currentIndex--;
      this.swiperController.changeIndex(this.currentIndex);
      this.showTemporaryToast(`切换到第${this.currentIndex + 1}个视频`);
    } else {
      this.showTemporaryToast('已经是第一个视频了');
    }
  }

  // 新增：下一视频
  nextVideo() {
    if (this.currentIndex < this.videoInfoList.length - 1) {
      this.currentIndex++;
      this.swiperController.changeIndex(this.currentIndex);
      this.showTemporaryToast(`切换到第${this.currentIndex + 1}个视频`);
    } else {
      this.showTemporaryToast('已经是最后一个视频了');
    }
  }

  // 新增：临时提示（使用官方Toast API）
  showTemporaryToast(message: string) {
    try {
      promptAction.showToast({
        message: message,
        duration: 1500
      });
    } catch (error) {
      hilog.error(DOMAIN, 'testTag', 'ShowToast failed: %{public}s', JSON.stringify(error));
    }
  }

  // 新增：重置播放计数
  resetPlayCount() {
    this.playCount = 0;
    this.showTemporaryToast('播放计数已重置');
  }

  // 新增：分享功能
  async handleShare() {
    try {
      const context = getContext(this) as common.UIAbilityContext;
      const shareUtil = ShareUtil.getInstance();
      
      // 分享视频信息
      const success = await shareUtil.shareVideoInfo(
        context,
        this.currentIndex,
        this.videoInfoList.length,
        this.playCount
      );
      
      if (success) {
        hilog.info(DOMAIN, 'testTag', 'Share success');
      } else {
        this.showTemporaryToast('分享失败，请重试');
      }
    } catch (error) {
      hilog.error(DOMAIN, 'testTag', 'Share failed: %{public}s', JSON.stringify(error));
      this.showTemporaryToast('分享功能异常');
    }
  }

  build() {
    Stack() {
      // 视频层
      Column() {
        Swiper(this.swiperController) {
          LazyForEach(new MyDataSource(this.videoInfoList), (item: VideoDataModel, index: number) => {
            VideoPlayer({
              isFullLandscapeScreen: this.isFullLandscapeScreen,
              videoIndex: index,
              activeIndex: this.currentIndex,
              screenWidth: this.screenWidth,
              onVideoPlay: (): void => this.incrementPlayCount()
            })
          }, (item: string) => item)
        }
        .cachedCount(CommonConstants.CACHED_COUNT)
        .vertical(true)
        .loop(true)
        .curve(Curve.Linear)
        .duration(CommonConstants.SWIPER_DURATION)
        .indicator(false)
        .onAnimationStart((index: number, targetIndex: number) => {
          hilog.info(DOMAIN, 'testTag', '%{public}s',
            `onAnimationStart index:${index} , targetIndex: ${targetIndex}`);
          this.currentIndex = targetIndex;
          this.incrementPlayCount();
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Color.Black)

      // 控制面板层 - 覆盖在视频上方
      Column() {
        // 顶部信息栏
        Row() {
          Text(`🎬 视频 ${this.currentIndex + 1}/${this.videoInfoList.length}`)
            .fontSize(16)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)

          Blank()

          Text(`📊 总播放: ${this.playCount}`)
            .fontSize(14)
            .fontColor('#FFD700')
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 10, bottom: 10 })
        .backgroundColor('rgba(0,0,0,0.7)')

        Blank() // 将控制面板推到底部

        // 底部控制区域
        Column() {
          // 按钮控制栏
          Row() {
            // 上一视频按钮
            Button() {
              Column() {
                SymbolGlyph($r('sys.symbol.chevron_left'))
                  .fontSize(24)
                  .fontColor([Color.White])
                Text('上一个')
                  .fontSize(12)
                  .fontColor(Color.White)
              }
            }
            .type(ButtonType.Circle)
            .height(60)
            .backgroundColor('rgba(255,255,255,0.2)')
            .onClick((): void => this.previousVideo())

            Blank()
              .width(20)

            // 播放/暂停按钮
            Button() {
              Column() {
                SymbolGlyph(this.isStart ? $r('sys.symbol.pause_fill') : $r('sys.symbol.play_fill'))
                  .fontSize(28)
                  .fontColor([Color.White])
                Text(this.isStart ? '暂停' : '播放')
                  .fontSize(12)
                  .fontColor(Color.White)
              }
            }
            .type(ButtonType.Circle)
            .height(70)
            .backgroundColor('rgba(255,255,255,0.3)')
            .onClick((): void => this.togglePlayPause())

            Blank()
              .width(20)

            // 下一视频按钮
            Button() {
              Column() {
                SymbolGlyph($r('sys.symbol.chevron_right'))
                  .fontSize(24)
                  .fontColor([Color.White])
                Text('下一个')
                  .fontSize(12)
                  .fontColor(Color.White)
              }
            }
            .type(ButtonType.Circle)
            .height(60)
            .backgroundColor('rgba(255,255,255,0.2)')
            .onClick((): void => this.nextVideo())
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .padding({ top: 10, bottom: 10 })

          // 第二排功能按钮
          Row() {
            // 点赞按钮
            Button() {
              Column() {
                SymbolGlyph(this.isLiked ? $r('sys.symbol.heart_fill') : $r('sys.symbol.heart'))
                  .fontSize(this.breakpointSystem.getIconSize('medium'))
                  .fontColor([this.isLiked ? '#FF4444' : Color.White])
                Text(`${this.likeCount}`)
                  .fontSize(this.breakpointSystem.getFontSize('small'))
                  .fontColor(Color.White)
              }
            }
            .type(ButtonType.Circle)
            .height(this.breakpointSystem.getButtonHeight())
            .backgroundColor('rgba(255,255,255,0.15)')
            .onClick((): void => this.handleLike())

            Blank()
              .width(30)

            // 重置计数器按钮
            Button() {
              Column() {
                SymbolGlyph($r('sys.symbol.arrow_counterclockwise'))
                  .fontSize(this.breakpointSystem.getIconSize('medium'))
                  .fontColor([Color.White])
                Text('重置')
                  .fontSize(this.breakpointSystem.getFontSize('small'))
                  .fontColor(Color.White)
              }
            }
            .type(ButtonType.Circle)
            .height(this.breakpointSystem.getButtonHeight())
            .backgroundColor('rgba(255,255,255,0.15)')
            .onClick((): void => this.resetPlayCount())

            Blank()
              .width(30)

            // 分享按钮
            Button() {
              Column() {
                SymbolGlyph($r('sys.symbol.share'))
                  .fontSize(this.breakpointSystem.getIconSize('medium'))
                  .fontColor([Color.White])
                Text('分享')
                  .fontSize(this.breakpointSystem.getFontSize('small'))
                  .fontColor(Color.White)
              }
            }
            .type(ButtonType.Circle)
            .height(this.breakpointSystem.getButtonHeight())
            .backgroundColor('rgba(255,255,255,0.15)')
            .onClick(() => { this.handleShare(); })
            
            // 流转按钮（仅在有可用设备时显示）
            if (this.isMigrationAvailable) {
              Blank()
                .width(30)
              
              Button() {
                Column() {
                  SymbolGlyph($r('sys.symbol.phone'))
                    .fontSize(this.breakpointSystem.getIconSize('medium'))
                    .fontColor([Color.White])
                  Text('流转')
                    .fontSize(this.breakpointSystem.getFontSize('small'))
                    .fontColor(Color.White)
                }
              }
              .type(ButtonType.Circle)
              .height(this.breakpointSystem.getButtonHeight())
              .backgroundColor('rgba(76, 175, 80, 0.3)')
              .onClick(() => { this.showMigrationPanel(); })
            }
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .padding({ top: 5, bottom: 15 })
        }
        .width(this.breakpointSystem.getControlPanelWidth())
        .backgroundColor('rgba(0,0,0,0.85)')
        .borderRadius(this.breakpointSystem.isLargeScreen() ? 16 : 0)
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      
      // 流转面板
      MigrationPanel({
        currentIndex: this.currentIndex,
        playCount: this.playCount,
        isLiked: this.isLiked,
        likeCount: this.likeCount,
        isStart: this.isStart,
        volume: 5,
        currentTime: 0
      })
    }
    .width('100%')
    .height('100%')
  }
}