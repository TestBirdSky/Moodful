# iOS Release TODO

这份清单针对 `RecordMood` 当前工程状态，按发布阻塞程度排序。完成外部账号、证书和商店操作后，再回到工程逐项勾选。

## P0：发布前必须完成

- [ ] 安装完整 Xcode，并在 Xcode 中登录 Apple Developer 账号。
- [ ] 将命令行开发目录切换到完整 Xcode：
  `sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer`
- [ ] 首次运行 Xcode 的 license、组件和模拟器初始化。
- [ ] 在 Xcode 的 Runner target 中设置真实的 `PRODUCT_BUNDLE_IDENTIFIER`，替换当前的 `com.example.recordmood`。
- [ ] 在 Xcode 的 Signing & Capabilities 中选择正确的 Team，开启 Automatic Signing，确认真机可安装。
- [ ] 确认 App Store Connect 中创建了同一个 Bundle ID 的 App。
- [ ] 修改 `pubspec.yaml` 的 `version` 和 build number；每次上传都必须递增 build number。
- [ ] 替换 `ios/Runner/Assets.xcassets/AppIcon.appiconset/` 下的所有图标。当前 1024 图标仍是 Flutter 默认蓝色 Logo。
- [ ] 替换 `ios/Runner/Assets.xcassets/LaunchImage.imageset/` 下的启动图。当前启动图是 1x1 空白占位资源。
- [ ] 将 `lib/common/constants/app_links.dart` 中的 App Store、隐私政策和服务条款地址替换为正式地址。
- [ ] 在 App Store Connect 填写真实的隐私政策 URL；当前应用暂未调用相机、麦克风、定位或照片权限，不要为了“过审”添加无关权限。
- [ ] 在真机上完成 Release 测试后执行：
  `flutter build ipa --release`
- [ ] 在 Transporter 或 Xcode Organizer 中上传 IPA，并处理签名、缺少图标或商店校验错误。

## P1：建议在首个版本完成

- [ ] 决定是否只支持 iPhone 竖屏。当前 UI 使用 `360x760` 设计尺寸，但 `Info.plist` 同时声明了 iPhone 横屏；如果不支持横屏，应在 Xcode 中移除 iPhone 横屏方向。
- [ ] 决定是否支持 iPad。当前 `TARGETED_DEVICE_FAMILY = "1,2"`，且 Info.plist 声明了 iPad；如果支持，需要实际检查 iPad 布局、截图和 App Store 展示。
- [ ] 检查启动页在不同 iPhone 尺寸、浅色/深色系统外观和刘海区域的表现。
- [ ] 检查 `Close App` 或类似退出行为在 iOS 上的产品处理。当前 `PlatformService` 在非 Android 平台调用 `SystemNavigator.pop()`，iOS 上应由产品决定是否隐藏该入口。
- [ ] 完成 App Store Connect 的名称、副标题、描述、关键词、分类、年龄分级、支持 URL、营销 URL 和截图。
- [ ] 准备 App Privacy 问卷答案：本地记录包含心情、能量、触发因素和 context，需要确认是否属于“Collected”以及是否与用户身份关联。
- [ ] 确认本地 SQLite 数据的升级策略。当前数据库版本为 `1`，后续修改表结构必须增加 migration。
- [ ] 检查从旧版本 `SharedPreferences`/SQLite 数据升级到正式版本的兼容性。
- [ ] 在无网络、首次启动、存储初始化失败、删除记录、编辑记录和冷启动/热启动场景下测试。
- [ ] 确认所有可点击的隐私政策、服务条款、评分和分享链接在 iOS 真机上可用。

## P2：后续维护

- [ ] 评估升级 `package_info_plus` 和 `share_plus`；当前版本被 `flutter pub outdated` 标记为可解析的新版本，但升级前要在 iOS/Android 双平台回归。
- [ ] 安装 CocoaPods 作为后续插件兼容的备用工具链。当前工程未发现 `ios/Podfile`，并且 Flutter 生成信息显示 iOS Swift Package Manager 未启用；不要手动混用两套依赖管理方式。
- [ ] 为正式环境补充错误上报、崩溃监控和隐私合规方案。
- [ ] 如果需要本地化，补齐 App Store Connect 的本地化名称、描述、截图和隐私政策页面。
- [ ] 清理模板项目名称、默认文档和不再使用的占位资源。

## 当前审计结论

- Flutter 工程和 iOS Runner 骨架存在，iOS 插件注册文件已生成。
- `sqflite`、`shared_preferences`、`share_plus`、`url_launcher` 均有对应的 iOS 插件注册。
- 当前机器只有 Command Line Tools，没有完整 Xcode；`xcodebuild -version` 无法运行。
- 当前机器没有 `pod` 命令。
- `flutter build ipa --release --no-codesign` 当前返回 `Application not configured for iOS`，应在安装完整 Xcode 后重新生成/同步工程并复测。
- 当前没有发现 iOS 权限声明；按照现有代码，不需要新增敏感权限描述。
- iOS Bundle ID、商店链接、隐私政策链接和条款链接仍是占位值。
- iOS AppIcon 和 LaunchImage 仍是 Flutter 模板占位资源。

## 建议的发布验证顺序

1. 安装并选择完整 Xcode，启动一次 Xcode。
2. 执行 `flutter clean`、`flutter pub get`，检查 iOS 依赖生成结果。
3. 在 Xcode 打开 `ios/Runner.xcworkspace`，设置 Bundle ID、Team、Signing 和设备方向。
4. 真机执行 `flutter run --release`，完成核心流程回归。
5. 执行 `flutter build ipa --release`。
6. 上传到 TestFlight，至少让一台真实设备完成安装和升级测试。
7. 完成 App Store Connect 元数据、隐私问卷和审核信息后再提交审核。

