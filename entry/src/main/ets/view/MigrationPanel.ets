/*
 * Copyright (c) 2026 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { hilog } from '@kit.PerformanceAnalysisKit';
import { DistributedManager, DeviceInfo, MigrationState } from '../common/DistributedManager';
import { BreakpointSystem } from '../common/BreakpointSystem';

const DOMAIN = 0x0000;
const TAG = 'MigrationPanel';

/**
 * 分布式流转控制面板组件
 * 提供跨设备流转的UI界面
 */
@Component
export struct MigrationPanel {
  @Prop currentIndex: number = 0;
  @Prop playCount: number = 0;
  @Prop isLiked: boolean = false;
  @Prop likeCount: number = 0;
  @Prop isStart: boolean = true;
  @Prop volume: number = 5;
  @Prop currentTime: number = 0;
  
  @State isVisible: boolean = false;
  @State deviceList: DeviceInfo[] = [];
  @State isMigrating: boolean = false;
  @State selectedDeviceId: string = '';
  
  private distributedManager: DistributedManager = DistributedManager.getInstance();
  private breakpointSystem: BreakpointSystem = BreakpointSystem.getInstance();
  private onMigrationSuccess?: () => void;
  
  aboutToAppear(): void {
    this.updateDeviceList();
  }
  
  /**
   * 更新设备列表
   */
  private updateDeviceList(): void {
    this.deviceList = this.distributedManager.getDeviceList();
  }
  
  /**
   * 显示流转面板
   */
  public show(onSuccess?: () => void): void {
    this.updateDeviceList();
    this.isVisible = true;
    this.onMigrationSuccess = onSuccess;
  }
  
  /**
   * 隐藏流转面板
   */
  public hide(): void {
    this.isVisible = false;
  }
  
  /**
   * 执行流转
   */
  private async performMigration(deviceId: string): Promise<void> {
    if (this.isMigrating) {
      return;
    }
    
    this.isMigrating = true;
    this.selectedDeviceId = deviceId;
    
    try {
      const state: MigrationState = {
        currentIndex: this.currentIndex,
        playCount: this.playCount,
        isLiked: this.isLiked,
        likeCount: this.likeCount,
        isStart: this.isStart,
        volume: this.volume,
        currentTime: this.currentTime
      };
      
      const success = await this.distributedManager.migrateToDevice(deviceId, state);
      
      if (success) {
        hilog.info(DOMAIN, TAG, 'Migration successful');
        if (this.onMigrationSuccess) {
          this.onMigrationSuccess();
        }
        this.hide();
      } else {
        hilog.error(DOMAIN, TAG, 'Migration failed');
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'Migration error: %{public}s', JSON.stringify(error));
    } finally {
      this.isMigrating = false;
      this.selectedDeviceId = '';
    }
  }
  
  build() {
    if (this.isVisible) {
      Column() {
        // 半透明背景
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0, 0, 0, 0.6)')
          .onClick(() => this.hide())
        
        // 设备选择面板
        Column() {
          // 标题
          Row() {
            Text('🔄 选择流转设备')
              .fontSize(this.breakpointSystem.getFontSize('large'))
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .padding({ top: 20, bottom: 15 })
          
          Divider()
            .color('#FFFFFF30')
            .width('80%')
          
          // 设备列表
          if (this.deviceList.length > 0) {
            Column() {
              ForEach(this.deviceList, (device: DeviceInfo) => {
                Row() {
                  // 设备图标
                  SymbolGlyph(this.getDeviceIcon(device.deviceType))
                    .fontSize(this.breakpointSystem.getIconSize('medium'))
                    .fontColor([Color.White])
                  
                  Column() {
                    Text(device.deviceName)
                      .fontSize(this.breakpointSystem.getFontSize('medium'))
                      .fontColor(Color.White)
                      .fontWeight(FontWeight.Medium)
                    
                    Text(this.getDeviceTypeText(device.deviceType))
                      .fontSize(this.breakpointSystem.getFontSize('small'))
                      .fontColor('#FFFFFF80')
                  }
                  .alignItems(HorizontalAlign.Start)
                  .margin({ left: 15 })
                  .layoutWeight(1)
                  
                  // 流转按钮
                  if (this.isMigrating && this.selectedDeviceId === device.deviceId) {
                    LoadingProgress()
                      .width(24)
                      .height(24)
                      .color(Color.White)
                  } else {
                    Button('流转')
                      .fontSize(this.breakpointSystem.getFontSize('small'))
                      .fontColor(Color.White)
                      .backgroundColor('#4CAF50')
                      .height(36)
                      .enabled(!this.isMigrating)
                      .onClick(() => this.performMigration(device.deviceId))
                  }
                }
                .width('100%')
                .padding({ left: 20, right: 20, top: 12, bottom: 12 })
                .backgroundColor('rgba(255, 255, 255, 0.1)')
                .borderRadius(8)
                .margin({ top: 10 })
              })
            }
            .width('100%')
            .padding({ left: 20, right: 20 })
          } else {
            // 无可用设备
            Column() {
              SymbolGlyph($r('sys.symbol.phone'))
                .fontSize(48)
                .fontColor([Color.White])
              
              Text('未发现可用设备')
                .fontSize(this.breakpointSystem.getFontSize('medium'))
                .fontColor('#FFFFFF80')
                .margin({ top: 15 })
              
              Text('请确保其他设备已登录同一华为账号\n并开启了分布式开关')
                .fontSize(this.breakpointSystem.getFontSize('small'))
                .fontColor('#FFFFFF60')
                .textAlign(TextAlign.Center)
                .margin({ top: 10 })
                .lineHeight(20)
            }
            .width('100%')
            .padding(30)
          }
          
          // 关闭按钮
          Button('关闭')
            .width('80%')
            .height(this.breakpointSystem.getButtonHeight())
            .fontSize(this.breakpointSystem.getFontSize('medium'))
            .fontColor(Color.White)
            .backgroundColor('rgba(255, 255, 255, 0.2)')
            .margin({ top: 20, bottom: 20 })
            .onClick(() => this.hide())
        }
        .width(this.breakpointSystem.getControlPanelWidth())
        .backgroundColor('#1a1a1a')
        .borderRadius(16)
        .padding({ top: 10, bottom: 10 })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
    }
  }
  
  /**
   * 获取设备图标
   */
  private getDeviceIcon(deviceType: string): Resource {
    switch (deviceType) {
      case 'phone':
        return $r('sys.symbol.phone');
      case 'tablet':
        return $r('sys.symbol.rectangle_on_rectangle');
      case 'tv':
        return $r('sys.symbol.rectangle');
      case 'wearable':
        return $r('sys.symbol.watch');
      default:
        return $r('sys.symbol.phone');
    }
  }
  
  /**
   * 获取设备类型文本
   */
  private getDeviceTypeText(deviceType: string): string {
    switch (deviceType) {
      case 'phone':
        return '手机';
      case 'tablet':
        return '平板';
      case 'tv':
        return '电视';
      case 'wearable':
        return '手表';
      default:
        return '设备';
    }
  }
}
