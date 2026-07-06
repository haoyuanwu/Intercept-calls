# 清净来电

一个基于 Flutter 与 Android `CallScreeningService` 的本地来电筛选应用。

## 当前能力

- 申请成为 Android 系统的来电筛选应用
- 黑名单始终拦截、白名单始终放行
- 用户自定义号段前缀拦截，白名单优先放行
- 内置 P0 拒接、P1 静音、P2 放行三级规则
- 银行短号保护与灰名单重复来电保护
- 银行、运营商和政府官方服务热线目录，支持搜索和复制
- 为号码标记诈骗、营销、银行、运营商分类
- 分别配置各分类的拦截策略
- 可选拦截隐藏号码
- 本机保存最近 200 条筛选记录

号码、规则和记录均保存在 Android 本机的应用私有存储中。

## 运行

```bash
flutter pub get
flutter run
```

请使用 Android 真机测试。首次启动后点击“立即开启系统权限”，在系统弹窗中将本应用设为来电筛选应用。Android 10 及以上可直接申请系统角色；较旧或深度定制系统可能需要在“默认应用”设置中手动选择。

## 号码识别边界

当前版本没有内置或伪造全国骚扰号码数据库。应用只能识别用户手动加入、标记的号码，并据此执行拦截。要覆盖不断变化的诈骗和营销号码，生产版本应接入具备合法授权、持续更新能力的号码信誉服务，并提供本地缓存、数据签名、误报申诉和离线降级策略。

银行与运营商号码默认放行，诈骗与营销号码默认拦截。白名单拥有最高优先级，避免误拦重要号码。

## 项目结构

```text
lib/
├── domain/          # 与 Flutter、Android 无关的模型和仓库接口
├── data/            # MethodChannel 数据源及模型转换
├── application/     # 页面共享的业务状态与用例编排
└── presentation/    # 页面和可复用 UI 组件

android/.../
├── CallDecisionEngine.kt      # 无存储依赖的纯规则决策
├── BuiltInCallRules.kt        # 可独立维护的内置号段和银行号码表
├── ScreeningStore.kt          # SharedPreferences 与记录持久化
├── SpamCallScreeningService.kt# Android 系统来电入口
└── platform/ScreeningMethodHandler.kt # Flutter 平台通道适配
```

依赖方向保持为 `presentation → application → domain`，数据层实现 domain 中的仓库接口。页面不直接使用 MethodChannel 或动态 Map；接入远程号码信誉库时可新增仓库实现或组合数据源，不需要修改页面。
