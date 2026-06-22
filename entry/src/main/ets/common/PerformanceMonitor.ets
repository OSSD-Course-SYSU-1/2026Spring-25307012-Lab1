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

const DOMAIN = 0x0000;
const TAG = 'PerformanceMonitor';

/**
 * 性能监控数据接口
 */
interface PerformanceData {
  operation: string;
  startTime: number;
  endTime?: number;
  duration?: number;
  success: boolean;
  errorMessage?: string;
}

/**
 * 性能统计接口
 */
interface PerformanceStat {
  count: number;
  totalDuration: number;
  maxDuration: number;
}

/**
 * 性能统计结果接口
 */
interface PerformanceStatResult {
  count: number;
  avgDuration: number;
  maxDuration: number;
}

/**
 * 性能监控和日志工具类
 * 用于监控应用性能和记录详细日志
 */
export class PerformanceMonitor {
  private static instance: PerformanceMonitor;
  private performanceDataList: PerformanceData[] = [];
  private maxRecordCount: number = 100; // 最大记录数量
  
  private constructor() {}
  
  public static getInstance(): PerformanceMonitor {
    if (!PerformanceMonitor.instance) {
      PerformanceMonitor.instance = new PerformanceMonitor();
    }
    return PerformanceMonitor.instance;
  }
  
  /**
   * 开始性能监控
   * @param operation 操作名称
   * @returns 操作ID（用于结束监控）
   */
  public startMonitor(operation: string): number {
    const startTime = Date.now();
    const data: PerformanceData = {
      operation: operation,
      startTime: startTime,
      success: false
    };
    
    this.performanceDataList.push(data);
    
    // 限制记录数量
    if (this.performanceDataList.length > this.maxRecordCount) {
      this.performanceDataList.shift();
    }
    
    hilog.info(DOMAIN, TAG, 'Start monitor: %{public}s, time: %{public}d', 
      operation, startTime);
    
    return this.performanceDataList.length - 1;
  }
  
  /**
   * 结束性能监控
   * @param operationId 操作ID
   * @param success 是否成功
   * @param errorMessage 错误信息（可选）
   */
  public endMonitor(operationId: number, success: boolean, errorMessage?: string): void {
    if (operationId < 0 || operationId >= this.performanceDataList.length) {
      hilog.error(DOMAIN, TAG, 'Invalid operation ID: %{public}d', operationId);
      return;
    }
    
    const data = this.performanceDataList[operationId];
    data.endTime = Date.now();
    data.duration = data.endTime - data.startTime;
    data.success = success;
    data.errorMessage = errorMessage;
    
    hilog.info(DOMAIN, TAG, 
      'End monitor: %{public}s, duration: %{public}dms, success: %{public}s', 
      data.operation, data.duration, success ? 'true' : 'false');
    
    // 如果操作时间过长，记录警告
    if (data.duration > 1000) {
      hilog.warn(DOMAIN, TAG, 
        'Performance warning: %{public}s took %{public}dms', 
        data.operation, data.duration);
    }
  }
  
  /**
   * 记录信息日志
   * @param tag 标签
   * @param message 消息
   */
  public logInfo(tag: string, message: string): void {
    hilog.info(DOMAIN, tag, message);
  }
  
  /**
   * 记录警告日志
   * @param tag 标签
   * @param message 消息
   */
  public logWarn(tag: string, message: string): void {
    hilog.warn(DOMAIN, tag, message);
  }
  
  /**
   * 记录错误日志
   * @param tag 标签
   * @param message 消息
   */
  public logError(tag: string, message: string): void {
    hilog.error(DOMAIN, tag, message);
  }
  
  /**
   * 记录调试日志
   * @param tag 标签
   * @param message 消息
   */
  public logDebug(tag: string, message: string): void {
    hilog.debug(DOMAIN, tag, message);
  }
  
  /**
   * 获取性能统计信息
   * @returns 性能统计信息
   */
  public getPerformanceStats(): Map<string, PerformanceStatResult> {
    const stats = new Map<string, PerformanceStat>();
    
    this.performanceDataList.forEach(data => {
      if (data.duration !== undefined) {
        const existing = stats.get(data.operation);
        if (existing) {
          existing.count++;
          existing.totalDuration += data.duration;
          existing.maxDuration = Math.max(existing.maxDuration, data.duration);
        } else {
          const newStat: PerformanceStat = {
            count: 1,
            totalDuration: data.duration,
            maxDuration: data.duration
          };
          stats.set(data.operation, newStat);
        }
      }
    });
    
    // 计算平均时间
    const result = new Map<string, PerformanceStatResult>();
    stats.forEach((value, key) => {
      const resultStat: PerformanceStatResult = {
        count: value.count,
        avgDuration: value.totalDuration / value.count,
        maxDuration: value.maxDuration
      };
      result.set(key, resultStat);
    });
    
    return result;
  }
  
  /**
   * 清除性能数据
   */
  public clearPerformanceData(): void {
    this.performanceDataList = [];
    hilog.info(DOMAIN, TAG, 'Performance data cleared');
  }
  
  /**
   * 打印性能统计报告
   */
  public printPerformanceReport(): void {
    const stats = this.getPerformanceStats();
    hilog.info(DOMAIN, TAG, '========== Performance Report ==========');
    
    stats.forEach((value, key) => {
      hilog.info(DOMAIN, TAG, 
        'Operation: %{public}s, Count: %{public}d, Avg: %{public}dms, Max: %{public}dms',
        key, value.count, value.avgDuration, value.maxDuration);
    });
    
    hilog.info(DOMAIN, TAG, '========================================');
  }
}
