import ConfigurationConstant from "@ohos:app.ability.ConfigurationConstant";
import UIAbility from "@ohos:app.ability.UIAbility";
import hilog from "@ohos:hilog";
import type window from "@ohos:window";
import { WindowUtil } from "@normalized:N&&&entry/src/main/ets/common/WindowUtil&";
const DOMAIN = 0x0000;
export default class EntryAbility extends UIAbility {
    onCreate(): void {
        try {
            this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
        }
        catch (err) {
            hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
        }
        hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
    }
    onDestroy(): void {
        hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
    }
    onWindowStageCreate(windowStage: window.WindowStage): void {
        // Main window is created, set main page for this ability
        hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
        WindowUtil.getInstance().setWindowStage(windowStage);
        windowStage.loadContent('pages/Index', (err) => {
            if (err.code) {
                hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
                return;
            }
            hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
            try {
                let windowClass: window.Window = windowStage.getMainWindowSync();
                windowClass?.setWindowLayoutFullScreen(true).catch(() => {
                    hilog.error(DOMAIN, 'testTag', 'setWindowLayoutFullScreen is failed.');
                });
            }
            catch (err) {
                hilog.error(DOMAIN, 'testTag', 'Failed to getMainWindowSync. Cause: %{public}s', JSON.stringify(err));
            }
        });
    }
    onWindowStageDestroy(): void {
        // Main window is destroyed, release UI related resources
        hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
    }
    // [Start get_isForeGround]
    onForeground(): void {
        // Ability has brought to foreground
        hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
        AppStorage.setOrCreate('isForeGround', true);
    }
    onBackground(): void {
        // Ability has back to background
        hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
        AppStorage.setOrCreate('isForeGround', false);
    }
}
