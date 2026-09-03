点击右上角review进入Weekly Review页面
模块一：概览卡片
展示内容：
- Avg mood：最近 7 天平均心情分
- Low days：最近 7 天 Low 或 Bad 的天数
- Top trigger：最近 7 天出现次数最多的触发因素
  计算逻辑：
- Avg mood = 最近 7 天所有记录的 Mood 数值平均值。
- 如果某天没有记录，不参与平均值计算。
- Low days = Mood 为 Low 或 Bad 的记录天数。
- Top trigger = 最近 7 天内出现次数最多的 trigger。
- 如果没有 trigger，则显示 No trigger yet。
  模块二：Mood pattern
  展示最近 7 天柱状图。
  逻辑：
- 每个柱子代表一天。
- 柱子高度根据 Mood 数值显示。
- 没有记录的日期显示为空或极浅占位。
- X 轴显示 M、T、W、T、F、S、S。
  模块三：Today compared
  展示今天与昨天的对比。
  示例：
- Mood is above yesterday
- Energy stayed normal
- +1 level
  计算逻辑：
- 今天 Mood 分值 - 昨天 Mood 分值 = 差值。
- 差值大于 0：above yesterday。
- 差值等于 0：same as yesterday。
- 差值小于 0：below yesterday。
- 如果昨天没有记录，显示 No comparison yet。
  模块四：Recent context
  展示最近一条 Context。
  逻辑：
- 如果最近记录有 Context，则显示一句。
- 点击 View 进入 History 页面对应记录。
- 如果没有 Context，则隐藏该模块或显示 No context yet。