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
*//*
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
import { WindowUtil } from '../common/WindowUtil';
import { VideoPlayer } from '../view/VideoPlayer';
import { VideoData } from '../common/VideoData';
import CommonConstants from '../constants/CommonConstants';
import { MyDataSource, VideoDataModel } from '../common/VideoDataModel';

const DOMAIN = 0x0000; // Tag domain.

@Entry
@Component
struct Index {
  private swiperController: SwiperController = new SwiperController();
  private windowUtil: WindowUtil = WindowUtil.getInstance(); // Window-related utility class
  @State videoInfoList: Array<VideoDataModel> = []; // Video resource list
  @State isFullLandscapeScreen: boolean = false;
  @State isStart: boolean = true; // Playing or pause
  @State currentIndex: number = 0; // Index of the currently playing video
  @State screenWidth: number = 0; // Screen width

  // 新增状态变量
  @State playCount: number = 0; // 播放计数器
  @State showToast: boolean = false; // 显示提示
  @State toastMessage: string = ''; // 提示消息
  @State isLiked: boolean = false; // 点赞状态
  @State likeCount: number = 0; // 点赞计数

  aboutToAppear() {
    this.videoInfoList = [...VideoData];
    AppStorage.setOrCreate('swiperController', this.swiperController);
    // Get screenWidth
    this.getScreenWidth();
    // Monitor window size changes
    this.windowUtil.registerOnWindowSizeChange((size) => {
      hilog.info(DOMAIN, 'testTag', '%{public}s',
        'registerOnWindowSizeChange:' + ' width:' + size.width + ',height:' + size.height);
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
      hilog.info(DOMAIN, 'testTag', '%{public}s', 'this.screenWidth:' + this.screenWidth);
    });
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

  // 新增：临时提示
  showTemporaryToast(message: string) {
    this.toastMessage = message;
    this.showToast = true;
    setTimeout(() => {
      this.showToast = false;
    }, 1500);
  }

  // 新增：重置播放计数
  resetPlayCount() {
    this.playCount = 0;
    this.showTemporaryToast('播放计数已重置');
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
                  .fontSize(22)
                  .fontColor([this.isLiked ? '#FF4444' : Color.White])
                Text(`${this.likeCount}`)
                  .fontSize(12)
                  .fontColor(Color.White)
              }
            }
            .type(ButtonType.Circle)
            .height(50)
            .backgroundColor('rgba(255,255,255,0.15)')
            .onClick((): void => this.handleLike())

            Blank()
              .width(30)

            // 重置计数器按钮
            Button() {
              Column() {
                SymbolGlyph($r('sys.symbol.arrow_counterclockwise'))
                  .fontSize(22)
                  .fontColor([Color.White])
                Text('重置')
                  .fontSize(12)
                  .fontColor(Color.White)
              }
            }
            .type(ButtonType.Circle)
            .height(50)
            .backgroundColor('rgba(255,255,255,0.15)')
            .onClick((): void => this.resetPlayCount())

            Blank()
              .width(30)

            // 分享按钮
            Button() {
              Column() {
                SymbolGlyph($r('sys.symbol.share'))
                  .fontSize(22)
                  .fontColor([Color.White])
                Text('分享')
                  .fontSize(12)
                  .fontColor(Color.White)
              }
            }
            .type(ButtonType.Circle)
            .height(50)
            .backgroundColor('rgba(255,255,255,0.15)')
            .onClick((): void => this.showTemporaryToast('分享功能开发中...'))
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .padding({ top: 5, bottom: 15 })
        }
        .width('100%')
        .backgroundColor('rgba(0,0,0,0.85)')
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      // Toast提示浮层
      if (this.showToast) {
        Column() {
          Text(this.toastMessage)
            .fontSize(16)
            .fontColor(Color.White)
            .padding({ left: 20, right: 20, top: 10, bottom: 10 })
            .backgroundColor('rgba(0,0,0,0.8)')
            .borderRadius(25)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .hitTestBehavior(HitTestMode.None)
      }
    }
    .width('100%')
    .height('100%')
  }
}