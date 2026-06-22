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

import { display } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x0000;
const TAG = 'BreakpointSystem';

/**
 * 设备类型枚举
 */
export enum DeviceType {
  PHONE = 'phone',           // 手机 (< 600vp)
  TABLET = 'tablet',         // 平板 (600-840vp)
  FOLDABLE = 'foldable',     // 折叠屏 (840-1024vp)
  LARGE_SCREEN = 'large'     // 大屏 (> 1024vp)
}

/**
 * 字体大小配置接口
 */
export interface FontSizeConfig {
  small: number;
  medium: number;
  large: number;
  title: number;
}

/**
 * 图标大小配置接口
 */
export interface IconSizeConfig {
  small: number;
  medium: number;
  large: number;
}

/**
 * 断点配置接口
 */
export interface BreakpointConfig {
  deviceType: DeviceType;
  minVpWidth: number;
  maxVpWidth: number;
  fontSize: FontSizeConfig;
  iconSize: IconSizeConfig;
  buttonHeight: number;
  controlPanelWidth: string;
  videoControlSize: number;
}

/**
 * 响应式布局断点系统
 * 用于适配不同屏幕尺寸的设备
 */
export class BreakpointSystem {
  private static instance: BreakpointSystem;
  private currentDeviceType: DeviceType = DeviceType.PHONE;
  private screenWidth: number = 0;
  private screenHeight: number = 0;
  private breakpointConfigs: Map<DeviceType, BreakpointConfig> = new Map();
  
  private constructor() {
    this.initBreakpointConfigs();
  }
  
  public static getInstance(): BreakpointSystem {
    if (!BreakpointSystem.instance) {
      BreakpointSystem.instance = new BreakpointSystem();
    }
    return BreakpointSystem.instance;
  }
  
  /**
   * 初始化断点配置
   */
  private initBreakpointConfigs(): void {
    // 手机配置
    const phoneFontSize: FontSizeConfig = { small: 12, medium: 14, large: 16, title: 18 };
    const phoneIconSize: IconSizeConfig = { small: 20, medium: 24, large: 28 };
    const phoneConfig: BreakpointConfig = {
      deviceType: DeviceType.PHONE,
      minVpWidth: 0,
      maxVpWidth: 600,
      fontSize: phoneFontSize,
      iconSize: phoneIconSize,
      buttonHeight: 50,
      controlPanelWidth: '100%',
      videoControlSize: 60
    };
    
    // 平板配置
    const tabletFontSize: FontSizeConfig = { small: 14, medium: 16, large: 18, title: 22 };
    const tabletIconSize: IconSizeConfig = { small: 24, medium: 28, large: 32 };
    const tabletConfig: BreakpointConfig = {
      deviceType: DeviceType.TABLET,
      minVpWidth: 600,
      maxVpWidth: 840,
      fontSize: tabletFontSize,
      iconSize: tabletIconSize,
      buttonHeight: 60,
      controlPanelWidth: '80%',
      videoControlSize: 80
    };
    
    // 折叠屏配置
    const foldableFontSize: FontSizeConfig = { small: 16, medium: 18, large: 20, title: 24 };
    const foldableIconSize: IconSizeConfig = { small: 28, medium: 32, large: 36 };
    const foldableConfig: BreakpointConfig = {
      deviceType: DeviceType.FOLDABLE,
      minVpWidth: 840,
      maxVpWidth: 1024,
      fontSize: foldableFontSize,
      iconSize: foldableIconSize,
      buttonHeight: 70,
      controlPanelWidth: '70%',
      videoControlSize: 90
    };
    
    // 大屏配置
    const largeFontSize: FontSizeConfig = { small: 18, medium: 20, large: 24, title: 28 };
    const largeIconSize: IconSizeConfig = { small: 32, medium: 36, large: 40 };
    const largeScreenConfig: BreakpointConfig = {
      deviceType: DeviceType.LARGE_SCREEN,
      minVpWidth: 1024,
      maxVpWidth: 9999,
      fontSize: largeFontSize,
      iconSize: largeIconSize,
      buttonHeight: 80,
      controlPanelWidth: '60%',
      videoControlSize: 100
    };
    
    this.breakpointConfigs.set(DeviceType.PHONE, phoneConfig);
    this.breakpointConfigs.set(DeviceType.TABLET, tabletConfig);
    this.breakpointConfigs.set(DeviceType.FOLDABLE, foldableConfig);
    this.breakpointConfigs.set(DeviceType.LARGE_SCREEN, largeScreenConfig);
  }
  
  /**
   * 更新屏幕尺寸并计算设备类型
   */
  public updateScreenSize(width: number, height: number): void {
    this.screenWidth = width;
    this.screenHeight = height;
    
    // 根据宽度判断设备类型
    if (width < 600) {
      this.currentDeviceType = DeviceType.PHONE;
    } else if (width < 840) {
      this.currentDeviceType = DeviceType.TABLET;
    } else if (width < 1024) {
      this.currentDeviceType = DeviceType.FOLDABLE;
    } else {
      this.currentDeviceType = DeviceType.LARGE_SCREEN;
    }
    
    hilog.info(DOMAIN, TAG, 'Device type updated: %{public}s, width: %{public}d', 
      this.currentDeviceType, width);
  }
  
  /**
   * 获取当前设备类型
   */
  public getCurrentDeviceType(): DeviceType {
    return this.currentDeviceType;
  }
  
  /**
   * 获取当前断点配置
   */
  public getCurrentConfig(): BreakpointConfig {
    const config = this.breakpointConfigs.get(this.currentDeviceType);
    if (!config) {
      return this.breakpointConfigs.get(DeviceType.PHONE)!;
    }
    return config;
  }
  
  /**
   * 获取字体大小
   */
  public getFontSize(type: 'small' | 'medium' | 'large' | 'title'): number {
    const config = this.getCurrentConfig();
    if (type === 'small') {
      return config.fontSize.small;
    } else if (type === 'medium') {
      return config.fontSize.medium;
    } else if (type === 'large') {
      return config.fontSize.large;
    } else {
      return config.fontSize.title;
    }
  }
  
  /**
   * 获取图标大小
   */
  public getIconSize(type: 'small' | 'medium' | 'large'): number {
    const config = this.getCurrentConfig();
    if (type === 'small') {
      return config.iconSize.small;
    } else if (type === 'medium') {
      return config.iconSize.medium;
    } else {
      return config.iconSize.large;
    }
  }
  
  /**
   * 获取按钮高度
   */
  public getButtonHeight(): number {
    const config = this.getCurrentConfig();
    return config.buttonHeight;
  }
  
  /**
   * 获取控制面板宽度
   */
  public getControlPanelWidth(): string {
    const config = this.getCurrentConfig();
    return config.controlPanelWidth;
  }
  
  /**
   * 获取视频控制尺寸
   */
  public getVideoControlSize(): number {
    const config = this.getCurrentConfig();
    return config.videoControlSize;
  }
  
  /**
   * 是否是大屏设备
   */
  public isLargeScreen(): boolean {
    return this.currentDeviceType === DeviceType.LARGE_SCREEN || 
           this.currentDeviceType === DeviceType.FOLDABLE;
  }
  
  /**
   * 是否是平板设备
   */
  public isTablet(): boolean {
    return this.currentDeviceType === DeviceType.TABLET;
  }
  
  /**
   * 是否是手机设备
   */
  public isPhone(): boolean {
    return this.currentDeviceType === DeviceType.PHONE;
  }
  
  /**
   * 获取屏幕宽度
   */
  public getScreenWidth(): number {
    return this.screenWidth;
  }
  
  /**
   * 获取屏幕高度
   */
  public getScreenHeight(): number {
    return this.screenHeight;
  }
  
  /**
   * 计算响应式尺寸（根据屏幕宽度比例）
   */
  public calculateResponsiveSize(baseSize: number): number {
    const baseWidth = 375; // 基准宽度（iPhone 6/7/8）
    const scale = this.screenWidth / baseWidth;
    return Math.round(baseSize * scale);
  }
}
