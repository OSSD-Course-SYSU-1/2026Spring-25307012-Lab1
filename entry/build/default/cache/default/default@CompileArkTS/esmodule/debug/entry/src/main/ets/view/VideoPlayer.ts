if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface VideoPlayer_Params {
    isForeGround?: boolean;
    activeIndex?: number;
    isFullLandscapeScreen?: boolean;
    videoIndex?: number;
    screenWidth?: number;
    swiperController?: SwiperController | undefined;
    currentTime?: number;
    durationTime?: number;
    isStart?: boolean;
    volume?: number;
    volumeVisible?: boolean;
    windowHeight?: number;
    videoInfoList?: Array<VideoDataModel>;
    curRate?: PlaybackSpeed;
    isAccelerate?: boolean;
    leftRateOpacity?: number;
    rightRateOpacity?: number;
    windowUtil?: WindowUtil;
    controller?: VideoController;
}
import hilog from "@ohos:hilog";
import { WindowUtil } from "@normalized:N&&&entry/src/main/ets/common/WindowUtil&";
import type { VideoDataModel } from '../common/VideoDataModel';
import { formatVideoTime } from "@normalized:N&&&entry/src/main/ets/common/TimeUtils&";
import { SetVolume } from "@normalized:N&&&entry/src/main/ets/view/SetVolume&";
import { VideoData } from "@normalized:N&&&entry/src/main/ets/common/VideoData&";
import CommonConstants from "@normalized:N&&&entry/src/main/ets/constants/CommonConstants&";
const DOMAIN = 0x0000; // Tag domain.
export class VideoPlayer extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__isForeGround = this.createStorageLink('isForeGround', false, "isForeGround");
        this.__activeIndex = new SynchedPropertySimpleOneWayPU(params.activeIndex, this, "activeIndex");
        this.__isFullLandscapeScreen = new SynchedPropertySimpleOneWayPU(params.isFullLandscapeScreen, this, "isFullLandscapeScreen");
        this.__videoIndex = new SynchedPropertySimpleOneWayPU(params.videoIndex, this, "videoIndex");
        this.__screenWidth = new SynchedPropertySimpleOneWayPU(params.screenWidth, this, "screenWidth");
        this.__swiperController = new ObservedPropertyObjectPU(undefined, this, "swiperController");
        this.__currentTime = new ObservedPropertySimplePU(0, this, "currentTime");
        this.__durationTime = new ObservedPropertySimplePU(0, this, "durationTime");
        this.__isStart = new ObservedPropertySimplePU(true, this, "isStart");
        this.__volume = new ObservedPropertySimplePU(5, this, "volume");
        this.__volumeVisible = new ObservedPropertySimplePU(false, this, "volumeVisible");
        this.__windowHeight = new ObservedPropertySimplePU(300, this, "windowHeight");
        this.__videoInfoList = new ObservedPropertyObjectPU([], this, "videoInfoList");
        this.__curRate = new ObservedPropertySimplePU(PlaybackSpeed.Speed_Forward_1_00_X, this, "curRate");
        this.__isAccelerate = new ObservedPropertySimplePU(false, this, "isAccelerate");
        this.__leftRateOpacity = new ObservedPropertySimplePU(0, this, "leftRateOpacity");
        this.__rightRateOpacity = new ObservedPropertySimplePU(1, this, "rightRateOpacity");
        this.windowUtil = WindowUtil.getInstance();
        this.controller = new VideoController();
        this.setInitiallyProvidedValue(params);
        this.declareWatch("isForeGround", this.foregroundStatus);
        this.declareWatch("activeIndex", this.activeIndexChange);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: VideoPlayer_Params) {
        if (params.activeIndex === undefined) {
            this.__activeIndex.set(0);
        }
        if (params.isFullLandscapeScreen === undefined) {
            this.__isFullLandscapeScreen.set(false);
        }
        if (params.videoIndex === undefined) {
            this.__videoIndex.set(0);
        }
        if (params.screenWidth === undefined) {
            this.__screenWidth.set(0);
        }
        if (params.swiperController !== undefined) {
            this.swiperController = params.swiperController;
        }
        if (params.currentTime !== undefined) {
            this.currentTime = params.currentTime;
        }
        if (params.durationTime !== undefined) {
            this.durationTime = params.durationTime;
        }
        if (params.isStart !== undefined) {
            this.isStart = params.isStart;
        }
        if (params.volume !== undefined) {
            this.volume = params.volume;
        }
        if (params.volumeVisible !== undefined) {
            this.volumeVisible = params.volumeVisible;
        }
        if (params.windowHeight !== undefined) {
            this.windowHeight = params.windowHeight;
        }
        if (params.videoInfoList !== undefined) {
            this.videoInfoList = params.videoInfoList;
        }
        if (params.curRate !== undefined) {
            this.curRate = params.curRate;
        }
        if (params.isAccelerate !== undefined) {
            this.isAccelerate = params.isAccelerate;
        }
        if (params.leftRateOpacity !== undefined) {
            this.leftRateOpacity = params.leftRateOpacity;
        }
        if (params.rightRateOpacity !== undefined) {
            this.rightRateOpacity = params.rightRateOpacity;
        }
        if (params.windowUtil !== undefined) {
            this.windowUtil = params.windowUtil;
        }
        if (params.controller !== undefined) {
            this.controller = params.controller;
        }
    }
    updateStateVars(params: VideoPlayer_Params) {
        this.__activeIndex.reset(params.activeIndex);
        this.__isFullLandscapeScreen.reset(params.isFullLandscapeScreen);
        this.__videoIndex.reset(params.videoIndex);
        this.__screenWidth.reset(params.screenWidth);
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__isForeGround.purgeDependencyOnElmtId(rmElmtId);
        this.__activeIndex.purgeDependencyOnElmtId(rmElmtId);
        this.__isFullLandscapeScreen.purgeDependencyOnElmtId(rmElmtId);
        this.__videoIndex.purgeDependencyOnElmtId(rmElmtId);
        this.__screenWidth.purgeDependencyOnElmtId(rmElmtId);
        this.__swiperController.purgeDependencyOnElmtId(rmElmtId);
        this.__currentTime.purgeDependencyOnElmtId(rmElmtId);
        this.__durationTime.purgeDependencyOnElmtId(rmElmtId);
        this.__isStart.purgeDependencyOnElmtId(rmElmtId);
        this.__volume.purgeDependencyOnElmtId(rmElmtId);
        this.__volumeVisible.purgeDependencyOnElmtId(rmElmtId);
        this.__windowHeight.purgeDependencyOnElmtId(rmElmtId);
        this.__videoInfoList.purgeDependencyOnElmtId(rmElmtId);
        this.__curRate.purgeDependencyOnElmtId(rmElmtId);
        this.__isAccelerate.purgeDependencyOnElmtId(rmElmtId);
        this.__leftRateOpacity.purgeDependencyOnElmtId(rmElmtId);
        this.__rightRateOpacity.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__isForeGround.aboutToBeDeleted();
        this.__activeIndex.aboutToBeDeleted();
        this.__isFullLandscapeScreen.aboutToBeDeleted();
        this.__videoIndex.aboutToBeDeleted();
        this.__screenWidth.aboutToBeDeleted();
        this.__swiperController.aboutToBeDeleted();
        this.__currentTime.aboutToBeDeleted();
        this.__durationTime.aboutToBeDeleted();
        this.__isStart.aboutToBeDeleted();
        this.__volume.aboutToBeDeleted();
        this.__volumeVisible.aboutToBeDeleted();
        this.__windowHeight.aboutToBeDeleted();
        this.__videoInfoList.aboutToBeDeleted();
        this.__curRate.aboutToBeDeleted();
        this.__isAccelerate.aboutToBeDeleted();
        this.__leftRateOpacity.aboutToBeDeleted();
        this.__rightRateOpacity.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    // [Start isForeGround]
    private __isForeGround: ObservedPropertyAbstractPU<boolean>;
    get isForeGround() {
        return this.__isForeGround.get();
    }
    set isForeGround(newValue: boolean) {
        this.__isForeGround.set(newValue);
    }
    // [End isForeGround]
    // [Start activeIndexChange]
    private __activeIndex: SynchedPropertySimpleOneWayPU<number>; // Index of the currently playing video
    get activeIndex() {
        return this.__activeIndex.get();
    }
    set activeIndex(newValue: number) {
        this.__activeIndex.set(newValue);
    }
    // [End activeIndexChange]
    private __isFullLandscapeScreen: SynchedPropertySimpleOneWayPU<boolean>; // FullLandscapeScreen state
    get isFullLandscapeScreen() {
        return this.__isFullLandscapeScreen.get();
    }
    set isFullLandscapeScreen(newValue: boolean) {
        this.__isFullLandscapeScreen.set(newValue);
    }
    private __videoIndex: SynchedPropertySimpleOneWayPU<number>; // Video index
    get videoIndex() {
        return this.__videoIndex.get();
    }
    set videoIndex(newValue: number) {
        this.__videoIndex.set(newValue);
    }
    private __screenWidth: SynchedPropertySimpleOneWayPU<number>; // Screen width
    get screenWidth() {
        return this.__screenWidth.get();
    }
    set screenWidth(newValue: number) {
        this.__screenWidth.set(newValue);
    }
    private __swiperController: ObservedPropertyObjectPU<SwiperController | undefined>;
    get swiperController() {
        return this.__swiperController.get();
    }
    set swiperController(newValue: SwiperController | undefined) {
        this.__swiperController.set(newValue);
    }
    private __currentTime: ObservedPropertySimplePU<number>; // Current play time point
    get currentTime() {
        return this.__currentTime.get();
    }
    set currentTime(newValue: number) {
        this.__currentTime.set(newValue);
    }
    private __durationTime: ObservedPropertySimplePU<number>; // Video total time
    get durationTime() {
        return this.__durationTime.get();
    }
    set durationTime(newValue: number) {
        this.__durationTime.set(newValue);
    }
    private __isStart: ObservedPropertySimplePU<boolean>; // Video state
    get isStart() {
        return this.__isStart.get();
    }
    set isStart(newValue: boolean) {
        this.__isStart.set(newValue);
    }
    private __volume: ObservedPropertySimplePU<number>; // Video volume
    get volume() {
        return this.__volume.get();
    }
    set volume(newValue: number) {
        this.__volume.set(newValue);
    }
    private __volumeVisible: ObservedPropertySimplePU<boolean>; // AVVolumePanel visibility state
    get volumeVisible() {
        return this.__volumeVisible.get();
    }
    set volumeVisible(newValue: boolean) {
        this.__volumeVisible.set(newValue);
    }
    private __windowHeight: ObservedPropertySimplePU<number>; // Window height
    get windowHeight() {
        return this.__windowHeight.get();
    }
    set windowHeight(newValue: number) {
        this.__windowHeight.set(newValue);
    }
    private __videoInfoList: ObservedPropertyObjectPU<Array<VideoDataModel>>; // Video resource list
    get videoInfoList() {
        return this.__videoInfoList.get();
    }
    set videoInfoList(newValue: Array<VideoDataModel>) {
        this.__videoInfoList.set(newValue);
    }
    private __curRate: ObservedPropertySimplePU<PlaybackSpeed>; // Video play speed
    get curRate() {
        return this.__curRate.get();
    }
    set curRate(newValue: PlaybackSpeed) {
        this.__curRate.set(newValue);
    }
    private __isAccelerate: ObservedPropertySimplePU<boolean>; // SpeedDialog visibility state
    get isAccelerate() {
        return this.__isAccelerate.get();
    }
    set isAccelerate(newValue: boolean) {
        this.__isAccelerate.set(newValue);
    }
    private __leftRateOpacity: ObservedPropertySimplePU<number>; // SpeedDialog left opacity
    get leftRateOpacity() {
        return this.__leftRateOpacity.get();
    }
    set leftRateOpacity(newValue: number) {
        this.__leftRateOpacity.set(newValue);
    }
    private __rightRateOpacity: ObservedPropertySimplePU<number>; // SpeedDialog right opacity
    get rightRateOpacity() {
        return this.__rightRateOpacity.get();
    }
    set rightRateOpacity(newValue: number) {
        this.__rightRateOpacity.set(newValue);
    }
    private windowUtil: WindowUtil; // Window-related utility class
    private controller: VideoController;
    aboutToAppear(): void {
        this.videoInfoList = [...VideoData];
        this.swiperController = AppStorage.get('swiperController');
    }
    // [Start activeIndexChange_func]
    // Monitor the change of activeIndex when the onchange event occurs.
    activeIndexChange() {
        hilog.info(DOMAIN, 'testTag', '%{public}s', 'activeIndexChange.' + this.activeIndex);
        this.currentTime = 0; // Reset currentTime
        this.controller.reset(); // Reset VideoController
        this.controller.start(); // Start playing
    }
    // [End activeIndexChange_func]
    // [Start foregroundStatus_func]
    // Perception of foreground and background.
    foregroundStatus() {
        if (this.isForeGround) {
            this.controller.start(); // Start playing when in the foreground.
            this.isStart = true;
        }
        else {
            this.controller.pause(); // Pause playback when in the background.
            this.isStart = false;
        }
    }
    // [End foregroundStatus_func]
    showFeatureIconInColumn(src: ResourceStr, content?: ResourceStr, parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Image.create(src);
            Image.width(30);
        }, Image);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (content) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create(content);
                        Text.fontSize(14);
                        Text.lineHeight(19);
                        Text.fontColor(Color.White);
                        Text.margin({ top: 5 });
                    }, Text);
                    Text.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                });
            }
        }, If);
        If.pop();
        Column.pop();
    }
    showFeatureIconInRow(src: ResourceStr, content?: ResourceStr, parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create({ space: 3 });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Image.create(src);
            Image.width(22);
        }, Image);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (content) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create(content);
                        Text.fontSize(14);
                        Text.lineHeight(19);
                        Text.fontColor(Color.White);
                    }, Text);
                    Text.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                });
            }
        }, If);
        If.pop();
        Row.pop();
    }
    // SpeedGesture custom column component
    SpeedGestureColumn(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // [Start SpeedGestureColumn]
            Column.create();
            // [Start SpeedGestureColumn]
            Column.width('20%');
            // [Start SpeedGestureColumn]
            Column.height('100%');
            Gesture.create(GesturePriority.Low);
            LongPressGesture.create({ repeat: true });
            LongPressGesture.onAction((event: GestureEvent | undefined) => {
                // The fast forward icon changes between visible and invisible states.
                this.leftRateOpacity = 1;
                this.rightRateOpacity = 0;
                if (!event) {
                    return;
                }
                if (event.repeat) {
                    this.isAccelerate = true;
                    this.curRate = PlaybackSpeed.Speed_Forward_2_00_X;
                    if (!this.isStart) {
                        this.isStart = true;
                        this.controller.start();
                    }
                }
            });
            LongPressGesture.onActionEnd(() => {
                this.isAccelerate = false;
                this.curRate = PlaybackSpeed.Speed_Forward_1_00_X;
            });
            LongPressGesture.pop();
            Gesture.pop();
        }, Column);
        // [Start SpeedGestureColumn]
        Column.pop();
    }
    // Use longPressGesture on both sides of the video screen to acceleration.
    SpeedGesture(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.justifyContent(FlexAlign.SpaceBetween);
            Row.width('100%');
            Row.height('100%');
        }, Row);
        this.SpeedGestureColumn.bind(this)();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Blank.create();
        }, Blank);
        Blank.pop();
        this.SpeedGestureColumn.bind(this)();
        Row.pop();
    }
    // Show dialog when accelerating.
    SpeedDialog(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.width(140);
            Row.height(32);
            Row.padding({
                left: 16,
                right: 16
            });
            Row.backgroundColor('rgba(31, 31, 38, 0.5)');
            Row.borderRadius(16);
            Row.visibility(this.isAccelerate ? Visibility.Visible : Visibility.Hidden);
            Row.position({
                left: (this.screenWidth - CommonConstants.RATE_DIALOG_WIDTH) / 2,
                top: 100
            });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Image.create({ "id": 16777261, "type": 20000, params: [], "bundleName": "com.example.PlayShortVideosBasedOnVideo", "moduleName": "entry" });
            Context.animation({
                duration: 500,
                curve: Curve.Linear,
                delay: 500,
                iterations: -1,
                playMode: PlayMode.Alternate,
                expectedFrameRateRange: {
                    min: 0,
                    max: 1,
                    expected: 1,
                }
            });
            Image.width(10);
            Image.height(13);
            Image.opacity(this.leftRateOpacity);
            Context.animation(null);
        }, Image);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Image.create({ "id": 16777261, "type": 20000, params: [], "bundleName": "com.example.PlayShortVideosBasedOnVideo", "moduleName": "entry" });
            Context.animation({
                duration: 500,
                curve: Curve.Linear,
                delay: 500,
                iterations: -1,
                playMode: PlayMode.Alternate,
                expectedFrameRateRange: {
                    min: 0,
                    max: 1,
                    expected: 0,
                }
            });
            Image.width(10);
            Image.height(13);
            Image.opacity(this.rightRateOpacity);
            Context.animation(null);
        }, Image);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create({ "id": 16777222, "type": 10003, params: [], "bundleName": "com.example.PlayShortVideosBasedOnVideo", "moduleName": "entry" });
            Text.fontColor(Color.White);
        }, Text);
        Text.pop();
        Row.pop();
    }
    // Playback progress bar.
    PlaybackProgressBar(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.padding({
                left: 25,
                right: 25
            });
            Row.zIndex(1);
            Row.height('auto');
            Row.width('100%');
            Row.position({ y: this.isFullLandscapeScreen ? 310 : 776 });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(formatVideoTime(this.currentTime));
            Text.fontColor(Color.White);
            Text.fontSize(12);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Slider.create({
                value: this.currentTime,
                min: 0,
                max: this.durationTime
            });
            Slider.trackColor(Color.White);
            Slider.opacity(0.6);
            Slider.onChange((value: number) => {
                // Set the video playback progress to jump to the value.
                this.controller.setCurrentTime(value, SeekMode.Accurate);
            });
            Slider.layoutWeight(1);
        }, Slider);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(formatVideoTime(this.durationTime));
            Text.fontColor(Color.White);
            Text.fontSize(12);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Stack.create();
            Stack.width(30);
            Stack.height(30);
            Stack.onClick(() => {
                this.windowUtil.handleFullScreen(true); // Set full screen.
            });
            Stack.visibility(this.isFullLandscapeScreen ? Visibility.None : Visibility.Visible);
        }, Stack);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Image.create({ "id": 16777262, "type": 20000, params: [], "bundleName": "com.example.PlayShortVideosBasedOnVideo", "moduleName": "entry" });
            Image.fillColor({ "id": 125831026, "type": 10001, params: [], "bundleName": "com.example.PlayShortVideosBasedOnVideo", "moduleName": "entry" });
            Image.width({ "id": 16777251, "type": 10002, params: [], "bundleName": "com.example.PlayShortVideosBasedOnVideo", "moduleName": "entry" });
            Image.height({ "id": 16777251, "type": 10002, params: [], "bundleName": "com.example.PlayShortVideosBasedOnVideo", "moduleName": "entry" });
            Image.margin({ left: 20 });
        }, Image);
        Stack.pop();
        Row.pop();
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Stack.create();
            Stack.backgroundColor('#D8D8D8');
            Stack.width('100%');
            Stack.height('100%');
            Stack.layoutWeight(1);
            Stack.onClick(() => {
                // Click the button to play or pause the video.
                hilog.info(DOMAIN, 'testTag', '%{public}s', 'onClick,' + 'activeIndex:' + this.activeIndex);
                this.isStart ? this.controller.pause() : this.controller.start();
                this.isStart = !this.isStart;
            });
            Gesture.create(GesturePriority.Low);
            // Combined gesture: LongPressGesture and PanGesture.
            GestureGroup.create(GestureMode.Sequence);
            // [Start LongPressGesture]
            LongPressGesture.create({ repeat: true });
            // [Start LongPressGesture]
            LongPressGesture.onAction((event: GestureEvent | undefined) => {
                hilog.info(DOMAIN, 'testTag', '%{public}s', 'LongPressGesture:' + event);
                if (event) {
                    this.volumeVisible = true;
                }
            });
            // [Start LongPressGesture]
            LongPressGesture.onActionEnd(() => {
                this.volumeVisible = false;
            });
            // [Start LongPressGesture]
            LongPressGesture.pop();
            // [End LongPressGesture]
            // [Start PanGesture]
            // When dragging after a long press, the PanGesture gesture is triggered.
            PanGesture.create({ direction: PanDirection.Vertical });
            // [End LongPressGesture]
            // [Start PanGesture]
            // When dragging after a long press, the PanGesture gesture is triggered.
            PanGesture.onActionUpdate((event: GestureEvent) => {
                let curVolume = this.volume - this.getUIContext().vp2px(event.offsetY) / this.windowHeight;
                curVolume = curVolume >= 15.0 ? 15.0 : curVolume;
                curVolume = curVolume <= 0.0 ? 0.0 : curVolume;
                this.volume = curVolume;
            });
            // [End LongPressGesture]
            // [Start PanGesture]
            // When dragging after a long press, the PanGesture gesture is triggered.
            PanGesture.onActionEnd(() => {
                setTimeout(() => {
                    this.volumeVisible = false;
                }, 5000);
            });
            // [End LongPressGesture]
            // [Start PanGesture]
            // When dragging after a long press, the PanGesture gesture is triggered.
            PanGesture.pop();
            // Combined gesture: LongPressGesture and PanGesture.
            GestureGroup.pop();
            Gesture.pop();
        }, Stack);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.activeIndex === this.videoIndex) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        // [Start currentProgressRate]
                        Video.create({
                            src: this.videoInfoList[this.activeIndex].uri,
                            controller: this.controller,
                            currentProgressRate: this.curRate
                        });
                        // [Start currentProgressRate]
                        Video.autoPlay(true);
                        // [Start currentProgressRate]
                        Video.loop(false);
                        // [Start currentProgressRate]
                        Video.controls(false);
                        // [Start currentProgressRate]
                        Video.objectFit(ImageFit.Contain);
                        // [Start currentProgressRate]
                        Video.width('100%');
                        // [Start currentProgressRate]
                        Video.height('100%');
                        // [Start currentProgressRate]
                        Video.onPrepared((event) => {
                            if (event) {
                                this.durationTime = event.duration;
                            }
                        });
                        // [Start currentProgressRate]
                        Video.onUpdate((event) => {
                            if (event) {
                                this.currentTime = event.time;
                            }
                        });
                        // [Start currentProgressRate]
                        Video.onFinish(() => {
                            hilog.info(DOMAIN, 'testTag', '%{public}s', 'onFinish and showNext.');
                            this.swiperController?.showNext();
                        });
                    }, Video);
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Video.create({});
                        Video.controls(false);
                        Video.objectFit(ImageFit.Contain);
                        Video.width('100%');
                        Video.height('100%');
                    }, Video);
                });
            }
        }, If);
        If.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // Start and stop button.
            Button.createWithChild({ stateEffect: true });
            // Start and stop button.
            Button.height(56);
            // Start and stop button.
            Button.aspectRatio(1);
            // Start and stop button.
            Button.opacity(0.2);
            // Start and stop button.
            Button.backgroundColor(Color.Transparent);
            // Start and stop button.
            Button.visibility(this.isStart ? Visibility.Hidden : Visibility.Visible);
        }, Button);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Image.create({ "id": 16777269, "type": 20000, params: [], "bundleName": "com.example.PlayShortVideosBasedOnVideo", "moduleName": "entry" });
        }, Image);
        // Start and stop button.
        Button.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithChild({ type: ButtonType.Circle });
            Button.width({ "id": 16777237, "type": 10002, params: [], "bundleName": "com.example.PlayShortVideosBasedOnVideo", "moduleName": "entry" });
            Button.height({ "id": 16777237, "type": 10002, params: [], "bundleName": "com.example.PlayShortVideosBasedOnVideo", "moduleName": "entry" });
            Button.backgroundColor('rgba(255,255,255,0.1)');
            Button.position({
                x: { "id": 16777251, "type": 10002, params: [], "bundleName": "com.example.PlayShortVideosBasedOnVideo", "moduleName": "entry" },
                y: { "id": 16777251, "type": 10002, params: [], "bundleName": "com.example.PlayShortVideosBasedOnVideo", "moduleName": "entry" }
            });
            Button.zIndex(1);
            Button.onClick(() => {
                this.windowUtil.handleFullScreenExit(false); // Exit full screen
            });
            Button.visibility(this.isFullLandscapeScreen ? Visibility.Visible : Visibility.Hidden);
        }, Button);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Image.create({ "id": 125830087, "type": 20000, params: [], "bundleName": "com.example.PlayShortVideosBasedOnVideo", "moduleName": "entry" });
            Image.fillColor(Color.White);
            Image.width({ "id": 16777250, "type": 10002, params: [], "bundleName": "com.example.PlayShortVideosBasedOnVideo", "moduleName": "entry" });
            Image.height({ "id": 16777250, "type": 10002, params: [], "bundleName": "com.example.PlayShortVideosBasedOnVideo", "moduleName": "entry" });
        }, Image);
        Button.pop();
        this.PlaybackProgressBar.bind(this)() // The playback progress bar component
        ;
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            RelativeContainer.create();
        }, RelativeContainer);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({ space: 20 });
            Column.alignRules({
                right: { anchor: '__container__', align: HorizontalAlign.End },
                bottom: { anchor: '__container__', align: VerticalAlign.Bottom }
            });
            Column.margin({ right: 8, bottom: 90 });
            Column.visibility(this.isFullLandscapeScreen ? Visibility.None : Visibility.Visible);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Image.create({ "id": 16777267, "type": 20000, params: [], "bundleName": "com.example.PlayShortVideosBasedOnVideo", "moduleName": "entry" });
            Image.width(44);
        }, Image);
        this.showFeatureIconInColumn.bind(this)({ "id": 16777264, "type": 20000, params: [], "bundleName": "com.example.PlayShortVideosBasedOnVideo", "moduleName": "entry" }, '1557');
        this.showFeatureIconInColumn.bind(this)({ "id": 16777263, "type": 20000, params: [], "bundleName": "com.example.PlayShortVideosBasedOnVideo", "moduleName": "entry" }, '566');
        this.showFeatureIconInColumn.bind(this)({ "id": 16777266, "type": 20000, params: [], "bundleName": "com.example.PlayShortVideosBasedOnVideo", "moduleName": "entry" }, '147');
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Image.create({ "id": 16777265, "type": 20000, params: [], "bundleName": "com.example.PlayShortVideosBasedOnVideo", "moduleName": "entry" });
            Image.width(32);
        }, Image);
        Column.pop();
        RelativeContainer.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create({ space: 18 });
            Row.justifyContent(FlexAlign.Start);
            Row.width('100%');
            Row.position({
                x: { "id": 16777251, "type": 10002, params: [], "bundleName": "com.example.PlayShortVideosBasedOnVideo", "moduleName": "entry" },
                y: 348
            });
            Row.visibility(this.isFullLandscapeScreen ? Visibility.Visible : Visibility.None);
        }, Row);
        this.showFeatureIconInRow.bind(this)({ "id": 16777264, "type": 20000, params: [], "bundleName": "com.example.PlayShortVideosBasedOnVideo", "moduleName": "entry" }, '1557');
        this.showFeatureIconInRow.bind(this)({ "id": 16777263, "type": 20000, params: [], "bundleName": "com.example.PlayShortVideosBasedOnVideo", "moduleName": "entry" }, '566');
        this.showFeatureIconInRow.bind(this)({ "id": 16777266, "type": 20000, params: [], "bundleName": "com.example.PlayShortVideosBasedOnVideo", "moduleName": "entry" }, '147');
        Row.pop();
        {
            this.observeComponentCreation2((elmtId, isInitialRender) => {
                if (isInitialRender) {
                    let componentCall = new SetVolume(this, {
                        volume: this.volume,
                        volumeVisible: this.volumeVisible,
                        isFullLandscapeScreen: this.isFullLandscapeScreen
                    }, undefined, elmtId, () => { }, { page: "entry/src/main/ets/view/VideoPlayer.ets", line: 359, col: 7 });
                    ViewPU.create(componentCall);
                    let paramsLambda = () => {
                        return {
                            volume: this.volume,
                            volumeVisible: this.volumeVisible,
                            isFullLandscapeScreen: this.isFullLandscapeScreen
                        };
                    };
                    componentCall.paramsGenerator_ = paramsLambda;
                }
                else {
                    this.updateStateVarsOfChildByElmtId(elmtId, {
                        volume: this.volume,
                        volumeVisible: this.volumeVisible,
                        isFullLandscapeScreen: this.isFullLandscapeScreen
                    });
                }
            }, { name: "SetVolume" });
        }
        this.SpeedGesture.bind(this)();
        this.SpeedDialog.bind(this)();
        Stack.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
}
