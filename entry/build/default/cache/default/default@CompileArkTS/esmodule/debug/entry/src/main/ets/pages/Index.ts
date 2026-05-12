if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface Index_Params {
    swiperController?: SwiperController;
    windowUtil?: WindowUtil;
    videoInfoList?: Array<VideoDataModel>;
    isFullLandscapeScreen?: boolean;
    isStart?: boolean;
    currentIndex?: number;
    screenWidth?: number;
}
import hilog from "@ohos:hilog";
import display from "@ohos:display";
import { WindowUtil } from "@normalized:N&&&entry/src/main/ets/common/WindowUtil&";
import { VideoPlayer } from "@normalized:N&&&entry/src/main/ets/view/VideoPlayer&";
import { VideoData } from "@normalized:N&&&entry/src/main/ets/common/VideoData&";
import CommonConstants from "@normalized:N&&&entry/src/main/ets/constants/CommonConstants&";
import { MyDataSource } from "@normalized:N&&&entry/src/main/ets/common/VideoDataModel&";
import type { VideoDataModel } from "@normalized:N&&&entry/src/main/ets/common/VideoDataModel&";
const DOMAIN = 0x0000; // Tag domain.
class Index extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.swiperController = new SwiperController();
        this.windowUtil = WindowUtil.getInstance();
        this.__videoInfoList = new ObservedPropertyObjectPU([], this, "videoInfoList");
        this.__isFullLandscapeScreen = new ObservedPropertySimplePU(false, this, "isFullLandscapeScreen");
        this.__isStart = new ObservedPropertySimplePU(true, this, "isStart");
        this.__currentIndex = new ObservedPropertySimplePU(0, this, "currentIndex");
        this.__screenWidth = new ObservedPropertySimplePU(0, this, "screenWidth");
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: Index_Params) {
        if (params.swiperController !== undefined) {
            this.swiperController = params.swiperController;
        }
        if (params.windowUtil !== undefined) {
            this.windowUtil = params.windowUtil;
        }
        if (params.videoInfoList !== undefined) {
            this.videoInfoList = params.videoInfoList;
        }
        if (params.isFullLandscapeScreen !== undefined) {
            this.isFullLandscapeScreen = params.isFullLandscapeScreen;
        }
        if (params.isStart !== undefined) {
            this.isStart = params.isStart;
        }
        if (params.currentIndex !== undefined) {
            this.currentIndex = params.currentIndex;
        }
        if (params.screenWidth !== undefined) {
            this.screenWidth = params.screenWidth;
        }
    }
    updateStateVars(params: Index_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__videoInfoList.purgeDependencyOnElmtId(rmElmtId);
        this.__isFullLandscapeScreen.purgeDependencyOnElmtId(rmElmtId);
        this.__isStart.purgeDependencyOnElmtId(rmElmtId);
        this.__currentIndex.purgeDependencyOnElmtId(rmElmtId);
        this.__screenWidth.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__videoInfoList.aboutToBeDeleted();
        this.__isFullLandscapeScreen.aboutToBeDeleted();
        this.__isStart.aboutToBeDeleted();
        this.__currentIndex.aboutToBeDeleted();
        this.__screenWidth.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private swiperController: SwiperController;
    private windowUtil: WindowUtil; // Window-related utility class
    private __videoInfoList: ObservedPropertyObjectPU<Array<VideoDataModel>>; // Video resource list
    get videoInfoList() {
        return this.__videoInfoList.get();
    }
    set videoInfoList(newValue: Array<VideoDataModel>) {
        this.__videoInfoList.set(newValue);
    }
    private __isFullLandscapeScreen: ObservedPropertySimplePU<boolean>;
    get isFullLandscapeScreen() {
        return this.__isFullLandscapeScreen.get();
    }
    set isFullLandscapeScreen(newValue: boolean) {
        this.__isFullLandscapeScreen.set(newValue);
    }
    private __isStart: ObservedPropertySimplePU<boolean>; // Playing or pause
    get isStart() {
        return this.__isStart.get();
    }
    set isStart(newValue: boolean) {
        this.__isStart.set(newValue);
    }
    private __currentIndex: ObservedPropertySimplePU<number>; // Index of the currently playing video
    get currentIndex() {
        return this.__currentIndex.get();
    }
    set currentIndex(newValue: number) {
        this.__currentIndex.set(newValue);
    }
    private __screenWidth: ObservedPropertySimplePU<number>; // Screen width
    get screenWidth() {
        return this.__screenWidth.get();
    }
    set screenWidth(newValue: number) {
        this.__screenWidth.set(newValue);
    }
    aboutToAppear() {
        this.videoInfoList = [...VideoData];
        AppStorage.setOrCreate('swiperController', this.swiperController);
        // Get screenWidth
        this.getScreenWidth();
        // Monitor window size changes
        this.windowUtil.registerOnWindowSizeChange((size) => {
            hilog.info(DOMAIN, 'testTag', '%{public}s', 'registerOnWindowSizeChange:' + ' width:' + size.width + ',height:' + size.height);
            if (size.width > size.height) {
                this.isFullLandscapeScreen = true;
            }
            else {
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
                hilog.error(DOMAIN, 'testTag', '%{public}s', `Failed to obtain all the display objects. Code: ${err.code}, message: ${err.message}`);
                return;
            }
            this.screenWidth = this.getUIContext().px2vp(data[0].width);
            hilog.info(DOMAIN, 'testTag', '%{public}s', 'this.screenWidth:' + this.screenWidth);
        });
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width('100%');
            Column.height('100%');
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Stack.create();
        }, Stack);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.backgroundColor(Color.Black);
            Column.height('100%');
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // [Start onAnimationStart]
            // [Start cachedCount]
            Swiper.create(this.swiperController);
            // [Start onAnimationStart]
            // [Start cachedCount]
            Swiper.cachedCount(CommonConstants.CACHED_COUNT);
            // [Start onAnimationStart]
            // [Start cachedCount]
            Swiper.vertical(true);
            // [Start onAnimationStart]
            // [Start cachedCount]
            Swiper.loop(true);
            // [Start onAnimationStart]
            // [Start cachedCount]
            Swiper.curve(Curve.Linear);
            // [Start onAnimationStart]
            // [Start cachedCount]
            Swiper.duration(CommonConstants.SWIPER_DURATION);
            // [Start onAnimationStart]
            // [Start cachedCount]
            Swiper.indicator(false);
            // [Start onAnimationStart]
            // [Start cachedCount]
            Swiper.onAnimationStart((index: number, targetIndex: number) => {
                hilog.info(DOMAIN, 'testTag', '%{public}s', `onAnimationStart index:${index} , targetIndex: ${targetIndex}`);
                this.currentIndex = targetIndex; // Update current video index.
            });
        }, Swiper);
        {
            const __lazyForEachItemGenFunction = (_item, index: number) => {
                const item = _item;
                {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        if (isInitialRender) {
                            let componentCall = new VideoPlayer(this, {
                                isFullLandscapeScreen: this.isFullLandscapeScreen,
                                videoIndex: index,
                                activeIndex: this.currentIndex,
                                screenWidth: this.screenWidth // Screen width
                            }, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/Index.ets", line: 77, col: 15 });
                            ViewPU.create(componentCall);
                            let paramsLambda = () => {
                                return {
                                    isFullLandscapeScreen: this.isFullLandscapeScreen,
                                    videoIndex: index,
                                    activeIndex: this.currentIndex,
                                    screenWidth: this.screenWidth // Screen width
                                };
                            };
                            componentCall.paramsGenerator_ = paramsLambda;
                        }
                        else {
                            this.updateStateVarsOfChildByElmtId(elmtId, {
                                isFullLandscapeScreen: this.isFullLandscapeScreen,
                                videoIndex: index,
                                activeIndex: this.currentIndex,
                                screenWidth: this.screenWidth // Screen width
                            });
                        }
                    }, { name: "VideoPlayer" });
                }
            };
            const __lazyForEachItemIdFunc = (item: string) => item;
            LazyForEach.create("1", this, new MyDataSource(this.videoInfoList), __lazyForEachItemGenFunction, __lazyForEachItemIdFunc);
            LazyForEach.pop();
        }
        // [Start onAnimationStart]
        // [Start cachedCount]
        Swiper.pop();
        Column.pop();
        Stack.pop();
        Column.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
    static getEntryName(): string {
        return "Index";
    }
}
registerNamedRoute(() => new Index(undefined, {}), "", { bundleName: "com.example.PlayShortVideosBasedOnVideo", moduleName: "entry", pagePath: "pages/Index", pageFullPath: "entry/src/main/ets/pages/Index", integratedHsp: "false", moduleType: "followWithHap" });
