CS 1.6 囚犯老大 V1 — 源碼修改包

狀態：兩份源码已通過 AMXX 1.10 編譯（0 errors、0 warnings），包含 .amxx。尚未完成遊戲實測，沒有包含人物模型。
編譯器由 AlliedModders/amxmodx master 源碼在本環境手動建置（64 位主機、32 位 Pawn cell）；編譯紀錄附在包內。伺服器載入與 ReVoice 兼容仍需驗證。
此次只優先修正老大功能，不代表整份 0816 需求已完成。

修正：150 HP、每回合一個名額（死亡/斷線不補選）、老大僅向 T 傳送語音。
缺少 jail_boss 模型時拒絕報名；缺少商店模型時不預載且拒絕購買。
禁止老大購買偽裝服。死亡、轉隊、回合結束取消老大身份。
修正連線槽位監獄幣殘留、購買前存活與陣營驗證、1 秒報名/購買冷卻。
原插件的商店、撬棍、火箭等功能尚未全面重構。

操作：
1. 在 Windows 將整包解壓到一般資料夾，不要在 ZIP 裡直接執行。
2. 本包已包含編譯好的 .amxx，可跳過編譯。若修改源码，再用 BUILD_WINDOWS.bat 重新編譯。
3. 成功後，兩個 .amxx 位於 cstrike/addons/amxmodx/plugins/。
4. 備份你伺服器上的同名插件與 plugins.ini。
5. 複製兩個 .amxx 到伺服器的 cstrike/addons/amxmodx/plugins/。
6. plugins.ini 只保留一份主插件與一份囚犯選單，先主插件、後囚犯選單：
   jbextreme.amxx
   prisoner_menu.amxx
   若原本用 Jbextreme.amxx，請同步修改清單與檔名，Linux 大小寫有別。
   不要同時載入舊 prisoner_boss.amxx 或其他重複 /boss 插件。
7. 安裝真正的深藍模型到 models/player/jail_boss/jail_boss.mdl。
   若模型有 jail_bossT.mdl，放同一目錄。不可將不相符的模型隨意改名替代。
   本包尚未確認你模型的 body/skin；目前使用 0/0，需模型檢查後決定。
8. 主插件仍需要原本 jbemodel、拳頭/撬棍模型、jbextreme.txt 字典與聲音資源。
   此包是既有伺服器的補丁，不是完整開服包，也沒有 d2 或監獄地圖。
9. 換圖後查看 amxx plugins，確認兩個插件 running。
10. 存活 T 輸入 /prisoner → 當囚犯老大，或直接 /boss。

驗收：
- 首位 T 變為 150 HP、深藍模型；第二人無法報名。
- 老大死亡或離線後，本回合仍不可報名；下一回合可報名。
- 老大說話：T（含死亡 T）收到，CT/觀戰收不到；管理員老大也不例外。
- 普通 T 仍依 JBE 禁麥規則；Simon 仍依原本規則。
- 老大轉隊、下一回合後不殘留專屬模型。
- 若另有 revoice_boss.amxx 或其他語音插件，先停用重複路由再測試。

語音實作是 JBE 的引擎監聽路由；沒有改寫 ReVoice/ReUnion，也未驗證跨版本語音轉碼。
商店的長距離/電鋸連擊等其他需求仍未完整實作。
監獄幣仍為記憶體資料，重啟不保存。
originals/ 是你上傳的原始源码；changes.diff 是此次差異。
