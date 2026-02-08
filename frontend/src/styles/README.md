# AdminPlus 配色方案 - 智谱AI风格

## 概述

本文档说明了 AdminPlus 项目的全局配色方案，采用智谱AI风格设计。

## 配色特点

### 主色调
- **科技蓝**: `#0066FF` - 主色，用于按钮、链接、标签等

### 辅助色
- **紫色渐变**: `#7B5FD6` → `#9F7AEA` - 辅助色，用于装饰和强调

### 背景色
- **简洁白**: `#FFFFFF` - 卡片、侧边栏等背景
- **浅灰**: `#F7F8FA` - 页面主背景
- **浅色背景**: `#FAFBFC` - 次级背景

### 文字色
- **深灰**: `#1A1A1A` - 主要文字
- **常规**: `#333333` - 常规文字
- **中灰**: `#666666` - 次要文字
- **占位**: `#999999` - 占位符文字

### 功能色
- **成功**: `#10B981` - 绿色
- **警告**: `#F59E0B` - 橙色
- **危险**: `#EF4444` - 红色
- **信息**: `#3B82F6` - 蓝色

### 边框色
- **浅灰**: `#E5E7EB` - 默认边框

## 渐变色

### 主要渐变
- **主渐变**: `linear-gradient(135deg, #0066FF 0%, #7B5FD6 100%)` - 蓝紫渐变
- **紫色渐变**: `linear-gradient(135deg, #7B5FD6 0%, #9F7AEA 100%)`
- **蓝色渐变**: `linear-gradient(135deg, #0066FF 0%, #3385FF 100%)`

### 功能渐变
- **成功渐变**: `linear-gradient(135deg, #10B981 0%, #34D399 100%)`
- **警告渐变**: `linear-gradient(135deg, #F59E0B 0%, #FBBF24 100%)`
- **危险渐变**: `linear-gradient(135deg, #EF4444 0%, #F87171 100%)`
- **信息渐变**: `linear-gradient(135deg, #3B82F6 0%, #60A5FA 100%)`

## 统计卡片配色

1. **用户卡片**: 蓝紫渐变 `#0066FF → #7B5FD6`
2. **角色卡片**: 紫色渐变 `#7B5FD6 → #9F7AEA`
3. **菜单卡片**: 蓝色渐变 `#0066FF → #3385FF`
4. **日志卡片**: 绿色渐变 `#10B981 → #34D399`

## 布局配色

### 导航栏
- 背景: `#FFFFFF`
- 边框: `#E5E7EB`
- 阴影: `0 1px 4px rgba(0, 0, 0, 0.05)`

### 侧边栏
- 背景: `#FFFFFF`
- 边框: `#E5E7EB`
- 激活项背景: `#E8F0FE`
- 激活项文字: `#0066FF`

### 内容区
- 背景: `#F7F8FA`
- 内边距: `20px`

## 图表配色

图表使用智谱AI风格配色方案：

```javascript
const colors = [
  '#0066FF',  // 主色 - 科技蓝
  '#7B5FD6',  // 紫色
  '#10B981',  // 绿色
  '#F59E0B',  // 橙色
  '#EF4444',  // 红色
  '#3B82F6',  // 蓝色
  '#9F7AEA',  // 浅紫
  '#34D399',  // 浅绿
  '#FBBF24',  // 浅橙
  '#F87171'   // 浅红
]
```

## Element Plus 主题覆盖

所有 Element Plus 组件的主题色已覆盖为智谱AI风格：

- 主色: `#0066FF`
- 成功色: `#10B981`
- 警告色: `#F59E0B`
- 危险色: `#EF4444`
- 信息色: `#3B82F6`

## 文件结构

```
frontend/src/styles/
├── README.md                 # 本文档
├── variables.scss            # 全局样式变量
├── element-variables.scss    # Element Plus 主题变量
└── index.scss                # 全局样式入口
```

## 使用方法

### 在组件中使用变量

```scss
<style scoped lang="scss">
@import '@/styles/variables.scss';

.my-component {
  color: $text-primary;
  background-color: $bg-white;
  border: 1px solid $border-color;
}
</style>
```

### 使用渐变类

```html
<div class="text-gradient">渐变文字</div>
<div class="card-hover">悬停卡片</div>
```

### 使用工具类

```html
<div class="flex flex-between">
  <span>左侧</span>
  <span>右侧</span>
</div>

<div class="mt-lg mb-md">
  间距示例
</div>

<span class="text-primary">��要文字</span>
<span class="text-success">成功文字</span>
<span class="text-danger">危险文字</span>
```

## 设计原则

1. **一致性**: 所有组件使用统一的配色方案
2. **可读性**: 确保文字与背景有足够的对比度
3. **层次感**: 通过颜色深浅区分信息层次
4. **现代感**: 使用渐变色和圆角设计
5. **品牌性**: 突出科技蓝主色调

## 注意事项

- 所有颜色变量都定义在 `variables.scss` 中
- Element Plus 组件样式在 `index.scss` 中统一覆盖
- 新增组件时优先使用已定义的变量
- 保持代码风格一致，使用 SCSS 变量而非硬编码颜色

## 更新日志

### 2026-02-08
- 创建智谱AI风格配色方案
- 定义全局样式变量
- 优化 Element Plus 主题色
- 更新 Dashboard 统计卡片配色
- 更新图表配色方案
- 优化布局配色（导航栏、侧边栏、内容区）
- 更新登录页面配色