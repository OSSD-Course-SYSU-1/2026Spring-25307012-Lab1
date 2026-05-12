if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface SetVolume_Params {
    volume?: number;
    volumeVisible?: boolean;
    isFullLandscapeScreen?: boolean;
}
import { AVVolumePanel } from "@ohos:multimedia.avVolumePanel";
import CommonConstants from "@normalized:N&&&entry/src/main/ets/constants/CommonConstants&";
export class SetVolume extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__volume = new SynchedPropertySimpleOneWayPU(params.volume, this, "volume");
        this.__volumeVisible = new SynchedPropertySimpleOneWayPU(params.volumeVisible, this, "volumeVisible");
        this.__isFullLandscapeScreen = new SynchedPropertySimpleOneWayPU(params.isFullLandscapeScreen, this, "isFullLandscapeScreen");
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: SetVolume_Params) {
        if (params.volume === undefined) {
            this.__volume.set(CommonConstants.INITIAL_VOLUME);
        }
        if (params.volumeVisible === undefined) {
            this.__volumeVisible.set(false);
        }
        if (params.isFullLandscapeScreen === undefined) {
            this.__isFullLandscapeScreen.set(false);
        }
    }
    updateStateVars(params: SetVolume_Params) {
        this.__volume.reset(params.volume);
        this.__volumeVisible.reset(params.volumeVisible);
        this.__isFullLandscapeScreen.reset(params.isFullLandscapeScreen);
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__volume.purgeDependencyOnElmtId(rmElmtId);
        this.__volumeVisible.purgeDependencyOnElmtId(rmElmtId);
        this.__isFullLandscapeScreen.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__volume.aboutToBeDeleted();
        this.__volumeVisible.aboutToBeDeleted();
        this.__isFullLandscapeScreen.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    // [Start SetVolume]
    private __volume: SynchedPropertySimpleOneWayPU<number>; // volume level
    get volume() {
        return this.__volume.get();
    }
    set volume(newValue: number) {
        this.__volume.set(newValue);
    }
    private __volumeVisible: SynchedPropertySimpleOneWayPU<boolean>; // Whether to show the volume component.
    get volumeVisible() {
        return this.__volumeVisible.get();
    }
    set volumeVisible(newValue: boolean) {
        this.__volumeVisible.set(newValue);
    }
    private __isFullLandscapeScreen: SynchedPropertySimpleOneWayPU<boolean>; // FullLandscapeScreen or not
    get isFullLandscapeScreen() {
        return this.__isFullLandscapeScreen.get();
    }
    set isFullLandscapeScreen(newValue: boolean) {
        this.__isFullLandscapeScreen.set(newValue);
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.visibility(this.volumeVisible ? Visibility.Visible : Visibility.Hidden);
            Column.height('50%');
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            __Common__.create();
            __Common__.width(10);
        }, __Common__);
        {
            this.observeComponentCreation2((elmtId, isInitialRender) => {
                if (isInitialRender) {
                    let componentCall = new AVVolumePanel(this, {
                        volumeLevel: this.volume,
                        volumeParameter: {
                            position: {
                                x: this.isFullLandscapeScreen ? CommonConstants.AV_VOLUME_PANEL_X_IN_FULL :
                                    CommonConstants.AV_VOLUME_PANEL_X,
                                y: this.isFullLandscapeScreen ? CommonConstants.AV_VOLUME_PANEL_Y_IN_FULL :
                                    CommonConstants.AV_VOLUME_PANEL_Y
                            }
                        }
                    }, undefined, elmtId, () => { }, { page: "entry/src/main/ets/view/SetVolume.ets", line: 28, col: 7 });
                    ViewPU.create(componentCall);
                    let paramsLambda = () => {
                        return {
                            volumeLevel: this.volume,
                            volumeParameter: {
                                position: {
                                    x: this.isFullLandscapeScreen ? CommonConstants.AV_VOLUME_PANEL_X_IN_FULL :
                                        CommonConstants.AV_VOLUME_PANEL_X,
                                    y: this.isFullLandscapeScreen ? CommonConstants.AV_VOLUME_PANEL_Y_IN_FULL :
                                        CommonConstants.AV_VOLUME_PANEL_Y
                                }
                            }
                        };
                    };
                    componentCall.paramsGenerator_ = paramsLambda;
                }
                else {
                    this.updateStateVarsOfChildByElmtId(elmtId, {
                        volumeLevel: this.volume,
                        volumeParameter: {
                            position: {
                                x: this.isFullLandscapeScreen ? CommonConstants.AV_VOLUME_PANEL_X_IN_FULL :
                                    CommonConstants.AV_VOLUME_PANEL_X,
                                y: this.isFullLandscapeScreen ? CommonConstants.AV_VOLUME_PANEL_Y_IN_FULL :
                                    CommonConstants.AV_VOLUME_PANEL_Y
                            }
                        }
                    });
                }
            }, { name: "AVVolumePanel" });
        }
        __Common__.pop();
        Column.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
}
