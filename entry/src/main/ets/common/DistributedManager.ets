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

import { distributedDeviceManager } from '@kit.DistributedServiceKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { common } from '@kit.AbilityKit';
import { Want } from '@kit.AbilityKit';

const DOMAIN = 0x0000;
const TAG = 'DistributedManager';

/**
 * 设备信息接口
 */
export interface DeviceInfo {
  deviceId: string;
  deviceName: string;
  deviceType: string;
  networkId: string;
}

/**
 * 流转状态接口
 */
export interface MigrationState {
  currentIndex: number;
  playCount: number;
  isLiked: boolean;
  likeCount: number;
  isStart: boolean;
  volume: number;
  currentTime: number;
}

/**
 * 分布式流转管理器
 * 用于管理跨设备的视频播放状态流转
 */
export class DistributedManager {
  private static instance: DistributedManager;
  private deviceManager: distributedDeviceManager.DeviceManager | null = null;
  private deviceList: DeviceInfo[] = [];
  private isMigrationSupported: boolean = false;
  private context: common.UIAbilityContext | null = null;
  
  private constructor() {}
  
  public static getInstance(): DistributedManager {
    if (!DistributedManager.instance) {
      DistributedManager.instance = new DistributedManager();
    }
    return DistributedManager.instance;
  }
  
  /**
   * 初始化分布式管理器
   */
  public async initialize(context: common.UIAbilityContext): Promise<boolean> {
    try {
      this.context = context;
      
      // 创建设备管理器
      this.deviceManager = distributedDeviceManager.createDeviceManager('com.example.PlayShortVideosBasedOnVideo');
      
      if (this.deviceManager) {
        this.isMigrationSupported = true;
        hilog.info(DOMAIN, TAG, 'DistributedManager initialized successfully');
        
        // 注册设备状态监听
        this.registerDeviceStateListener();
        
        // 获取可用设备列表
        await this.updateDeviceList();
        
        return true;
      }
      
      return false;
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'Failed to initialize DistributedManager: %{public}s', 
        JSON.stringify(error));
      return false;
    }
  }
  
  /**
   * 注册设备状态监听
   */
  private registerDeviceStateListener(): void {
    if (!this.deviceManager) {
      return;
    }
    
    try {
      // 监听设备上线
      this.deviceManager.on('deviceStateChange', () => {
        hilog.info(DOMAIN, TAG, 'Device state changed');
        this.updateDeviceList();
      });
      
      hilog.info(DOMAIN, TAG, 'Device state listener registered');
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'Failed to register device state listener: %{public}s', 
        JSON.stringify(error));
    }
  }
  
  /**
   * 更新设备列表
   */
  public async updateDeviceList(): Promise<void> {
    if (!this.deviceManager) {
      return;
    }
    
    try {
      // 获取可信设备列表
      const devices = this.deviceManager.getAvailableDeviceListSync();
      
      this.deviceList = [];
      for (let i = 0; i < devices.length; i++) {
        const device = devices[i];
        const info: DeviceInfo = {
          deviceId: device.deviceId || '',
          deviceName: device.deviceName || 'Unknown Device',
          deviceType: device.deviceType || 'unknown',
          networkId: device.networkId || ''
        };
        this.deviceList.push(info);
      }
      
      hilog.info(DOMAIN, TAG, 'Available devices: %{public}d', this.deviceList.length);
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'Failed to update device list: %{public}s', 
        JSON.stringify(error));
    }
  }
  
  /**
   * 获取可用设备列表
   */
  public getDeviceList(): DeviceInfo[] {
    return this.deviceList;
  }
  
  /**
   * 是否支持流转
   */
  public isSupported(): boolean {
    return this.isMigrationSupported && this.deviceList.length > 0;
  }
  
  /**
   * 获取可用设备数量
   */
  public getAvailableDeviceCount(): number {
    return this.deviceList.length;
  }
  
  /**
   * 准备流转数据
   */
  public prepareMigrationData(state: MigrationState): string {
    try {
      const data = JSON.stringify(state);
      hilog.info(DOMAIN, TAG, 'Migration data prepared: %{public}s', data);
      return data;
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'Failed to prepare migration data: %{public}s', 
        JSON.stringify(error));
      return '';
    }
  }
  
  /**
   * 解析流转数据
   */
  public parseMigrationData(data: string): MigrationState | null {
    try {
      const state = JSON.parse(data) as MigrationState;
      hilog.info(DOMAIN, TAG, 'Migration data parsed successfully');
      return state;
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'Failed to parse migration data: %{public}s', 
        JSON.stringify(error));
      return null;
    }
  }
  
  /**
   * 发起流转到指定设备
   */
  public async migrateToDevice(deviceId: string, state: MigrationState): Promise<boolean> {
    if (!this.context || !this.isMigrationSupported) {
      hilog.error(DOMAIN, TAG, 'Migration not supported or context not available');
      return false;
    }
    
    try {
      // 准备流转数据
      const migrationData = this.prepareMigrationData(state);
      
      // 构建Want参数
      const want: Want = {
        deviceId: deviceId,
        bundleName: 'com.example.PlayShortVideosBasedOnVideo',
        abilityName: 'EntryAbility',
        parameters: {
          migrationData: migrationData
        }
      };
      
      // 启动远程Ability
      await this.context.startAbility(want);
      
      hilog.info(DOMAIN, TAG, 'Migration started to device: %{public}s', deviceId);
      return true;
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'Failed to migrate to device: %{public}s', 
        JSON.stringify(error));
      return false;
    }
  }
  
  /**
   * 显示设备选择对话框
   */
  public showDevicePicker(): DeviceInfo[] {
    return this.deviceList;
  }
  
  /**
   * 销毁分布式管理器
   */
  public destroy(): void {
    try {
      if (this.deviceManager) {
        this.deviceManager.off('deviceStateChange');
        distributedDeviceManager.releaseDeviceManager(this.deviceManager);
        this.deviceManager = null;
      }
      
      this.deviceList = [];
      this.isMigrationSupported = false;
      
      hilog.info(DOMAIN, TAG, 'DistributedManager destroyed');
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'Failed to destroy DistributedManager: %{public}s', 
        JSON.stringify(error));
    }
  }
}
