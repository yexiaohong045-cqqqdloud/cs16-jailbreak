# CS 1.6 監獄玩法

目標：使用者自己 Windows 電腦上的 CS 1.6 伺服器。

目前交付為囚犯老大 V1.1 補丁：150 HP、每回合一個名額、死亡或斷線不補選、老大語音只向 T 傳送。兩份插件已通過 AMXX 1.10 編譯（0 錯誤、0 警告）。**遊戲實測尚未完成，完整監獄玩法尚未完成。**

## 下載與安裝

1. 按 Code → Download ZIP，解壓縮。
2. 備份原伺服器上的插件及 plugins.ini。
3. 將本倉庫 `cstrike/addons/amxmodx/plugins/` 中的 `jbextreme.amxx` 和 `prisoner_menu.amxx` 複製到伺服器同名目錄。
4. 在伺服器 `cstrike/addons/amxmodx/configs/plugins.ini` 中保留以下兩行各一次：

```ini
jbextreme.amxx
prisoner_menu.amxx
```

不要同時載入舊版同功能插件；檔名與清單必須一致。

5. 保留原有 JBE 模型、聲音與翻譯資源。需要真正的深藍囚服模型：`cstrike/models/player/jail_boss/jail_boss.mdl`。提供的同名模型實際是殭屍模型，不應直接使用。缺少模型時會拒絕老大報名。
6. 換圖後確認 `amxx plugins` 顯示 running；存活囚犯輸入 `/boss`，或 `/prisoner` 打開選單。

倉庫內已含 `.amxx`，不必自行編譯。重新編譯可使用既有 AMXX 1.10 scripting 編譯工具；下載包中的 Windows 編譯工具未放入本倉庫。

## 測試與後續工作

- 編譯紀錄：`compile_jbextreme.txt`、`compile_prisoner_menu.txt`。
- 編譯器建置說明：`BUILD_PROVENANCE.txt`。
- 完整功能與資源缺口：`docs/STATUS.md`。
- 伺服器載入、模型外觀、多人語音、ReVoice 兼容仍待測試。
- 当前商店及原 JBE 其他玩法尚未完成整份需求重構。

本倉庫不包含存取權杖、帳密或使用者登入資料。基礎源码保留原作者標示。
