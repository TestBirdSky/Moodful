模块一：Top triggers
展示最近 7 天出现频率最高的触发因素。
逻辑：
- 统计最近 7 天所有记录中的 trigger 出现次数。
- 按次数从高到低排序。
- 最多展示 5 个。
- 每项显示名称、次数、进度条。
  模块二：Trigger map
  展示触发因素与心情状态的关系。
  分组逻辑：
- Low mood：Mood 为 Low 或 Bad 的记录中出现过的 trigger。
- Good mood：Mood 为 Good 或 Great 的记录中出现过的 trigger。
- Okay 可不参与分组，或归入 neutral 数据，v1 不展示。
  模块三：Mannager trigger
  点击 Manage 进入 All Triggers 页面。
  All Triggers 页面分为：
- Default triggers：系统默认因素，不支持编辑和删除。
- Custom triggers：用户自定义因素，支持编辑和删除。
  默认 Trigger：
- Sleep
- Work
- Family
- Weather
- Health
- Money
  自定义 Trigger：
- 点击 Add 或 Add custom trigger 打开添加弹窗。
- 输入 Trigger name。
- 点击 Save trigger 保存。
- 保存后该 Trigger 出现在 Check 页的 Triggers 选项中。
  编辑逻辑：
- 点击自定义 Trigger 的 Edit 打开编辑弹窗。
- 修改名称后点击 Save changes。
- 历史记录中已保存的旧名称保持不变，新记录使用新名称。
  删除逻辑：
- 只允许删除自定义 Trigger。
- 删除后，该 Trigger 不再出现在 Check 页可选项。
- 历史记录中已经使用过的 Trigger 文本保留。
- 默认 Trigger 不允许删除，只显示 Locked。