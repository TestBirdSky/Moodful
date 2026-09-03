字段说明：
- Mood：心情等级，必填。
- Energy：能量状态，可选。
- Triggers：触发因素，可多选。
- Context：简短场景备注，可选。
  Mood 选项：
- Great：很好
- Good：不错
- Okay：一般
- Low：低落
- Bad：很差
  内部数值映射：
- Great = 5
- Good = 4
- Okay = 3
- Low = 2
- Bad = 1
  Energy 选项：
- High：高能量
- Normal：正常
- Low：低能量
  Triggers 默认选项：
- Sleep：睡眠
- Work：工作
- Family：家庭
- Weather：天气
- Health：身体状态
- Money：金钱压力
  Context 说明：
- Context 不是日记。
- 只允许一句简短说明，建议限制 80-120 字符。
- 示例：Slept late, work meeting in morning。
- 作用是帮助用户以后回看当时的场景，不做长文本沉淀。
  保存逻辑：
- 点击 Save check-in 后，生成一条当天记录。
- 如果当天已经有记录，再次保存则刷新当天记录。
- 保存成功后跳转到 Mood Board 页面。
- 保存内容写入本地数据库。
  校验逻辑：
- Mood 必须选择。
- Energy、Triggers、Context 可以为空。
- 未选择 Mood 时，Save check-in 按钮置灰或点击后提示选择 Mood。
  当天有无记录的逻辑：
- 每天首次打开：展示当天 Check-in 表单。
- 当天已有记录：Check 页面进入“Update mode”，显示已记录状态，允许用户修改当天记录。
  当天重复保存提示
  当天只允许生成一条记录。
  保存逻辑：
- 当天没有记录时，点击 Save check-in 创建新记录。
- 当天已有记录时，页面按钮变为 Update check-in。
- 点击 Update check-in 后覆盖当天原记录，不新增第二条。
- 保存成功后展示轻提示：Today's check-in updated。
- 提示 2 秒后自动消失，用户仍停留在 Check 页面。