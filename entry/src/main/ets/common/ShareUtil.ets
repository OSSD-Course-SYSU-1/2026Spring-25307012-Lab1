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

import { systemShare } from '@kit.ShareKit';
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x0000;
const TAG = 'ShareUtil';

/**
 * 分享工具类
 * 使用HarmonyOS Share Kit实现系统分享功能
 */
export class ShareUtil {
  private static instance: ShareUtil;
  
  private constructor() {}
  
  public static getInstance(): ShareUtil {
    if (!ShareUtil.instance) {
      ShareUtil.instance = new ShareUtil();
    }
    return ShareUtil.instance;
  }
  
  /**
   * 分享文本内容
   * @param context UIAbility上下文
   * @param text 要分享的文本
   * @param title 标题（可选）
   * @param description 描述（可选）
   */
  public async shareText(
    context: common.UIAbilityContext,
    text: string,
    title?: string,
    description?: string
  ): Promise<boolean> {
    try {
      hilog.info(DOMAIN, TAG, 'shareText start, text: %{public}s', text);
      
      // 构造分享数据
      const shareData: systemShare.SharedData = new systemShare.SharedData({
        utd: utd.UniformDataType.PLAIN_TEXT,
        content: text,
        title: title || '分享文本',
        description: description || ''
      });
      
      // 创建分享控制器
      const controller: systemShare.ShareController = new systemShare.ShareController(shareData);
      
      // 注册分享面板关闭监听
      controller.on('dismiss', () => {
        hilog.info(DOMAIN, TAG, 'Share panel closed');
      });
      
      // 显示分享面板
      await controller.show(context, {
        previewMode: systemShare.SharePreviewMode.DETAIL,
        selectionMode: systemShare.SelectionMode.SINGLE
      });
      
      hilog.info(DOMAIN, TAG, 'shareText success');
      return true;
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(DOMAIN, TAG, 'shareText failed. Code: %{public}d, message: %{public}s', 
        err.code, err.message);
      return false;
    }
  }
  
  /**
   * 分享链接
   * @param context UIAbility上下文
   * @param url 链接地址
   * @param title 标题
   * @param description 描述（可选）
   */
  public async shareLink(
    context: common.UIAbilityContext,
    url: string,
    title: string,
    description?: string
  ): Promise<boolean> {
    try {
      hilog.info(DOMAIN, TAG, 'shareLink start, url: %{public}s', url);
      
      // 构造分享数据
      const shareData: systemShare.SharedData = new systemShare.SharedData({
        utd: utd.UniformDataType.HYPERLINK,
        content: url,
        title: title,
        description: description || ''
      });
      
      // 创建分享控制器
      const controller: systemShare.ShareController = new systemShare.ShareController(shareData);
      
      // 注册分享面板关闭监听
      controller.on('dismiss', () => {
        hilog.info(DOMAIN, TAG, 'Share panel closed');
      });
      
      // 显示分享面板
      await controller.show(context, {
        previewMode: systemShare.SharePreviewMode.DETAIL,
        selectionMode: systemShare.SelectionMode.SINGLE
      });
      
      hilog.info(DOMAIN, TAG, 'shareLink success');
      return true;
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(DOMAIN, TAG, 'shareLink failed. Code: %{public}d, message: %{public}s', 
        err.code, err.message);
      return false;
    }
  }
  
  /**
   * 分享视频信息（文本形式）
   * @param context UIAbility上下文
   * @param videoIndex 视频索引
   * @param totalCount 视频总数
   * @param playCount 播放次数
   */
  public async shareVideoInfo(
    context: common.UIAbilityContext,
    videoIndex: number,
    totalCount: number,
    playCount: number
  ): Promise<boolean> {
    const shareText = `🎬 正在观看第${videoIndex + 1}个视频（共${totalCount}个）\n` +
      `📊 总播放次数: ${playCount}\n` +
      `📱 来自HarmonyOS短视频应用`;
    
    return await this.shareText(context, shareText, '短视频播放分享', '分享我的观看进度');
  }
}
