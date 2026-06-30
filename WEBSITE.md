# Lithe Website

宣传页面，基于 Astro 6 + Tailwind CSS v4 构建，部署在 Cloudflare Pages。

## 技术栈

| 层次 | 技术 |
|------|------|
| 框架 | Astro 6 (Static) |
| 样式 | Tailwind CSS v4 |
| 动画 | CSS Transitions + Intersection Observer |
| 部署 | Cloudflare Pages / GitHub Pages |
| 国际化 | Astro i18n (URL 前缀: `/en/`, `/zh/`) |
| 包管理 | pnpm |

## 本地开发

```bash
cd website
pnpm install
pnpm run dev
```

浏览器打开 `http://localhost:4321/en/` 查看英文版。

## 构建

```bash
pnpm run build
```

输出到 `website/dist/`。

## 目录结构

```
website/
├── public/                    # 静态资源
│   ├── favicon.svg            # 网站图标
│   └── placeholder.svg        # 截图占位符
├── src/
│   ├── components/            # UI 组件
│   │   ├── Navbar.astro       # 导航栏
│   │   ├── Hero.astro         # Hero 区 + 粒子动画
│   │   ├── Features.astro     # 功能展示区
│   │   ├── FeatureCard.astro  # 单个功能卡片
│   │   ├── ScreenshotShowcase.astro  # 截图展示
│   │   ├── TechHighlights.astro     # 技术亮点
│   │   ├── DownloadSection.astro    # 下载区
│   │   ├── Footer.astro       # 页脚
│   │   ├── LanguageSwitch.astro  # 语言切换
│   │   └── ScrollReveal.astro    # 滚动动画
│   ├── data/
│   │   └── site.ts            # 站点配置
│   ├── i18n/
│   │   ├── en.json            # 英文文案
│   │   └── zh.json            # 中文文案
│   ├── layouts/
│   │   └── Layout.astro       # HTML 布局
│   ├── pages/
│   │   ├── index.astro        # 重定向到 /en/
│   │   ├── en/index.astro     # 英文首页
│   │   └── zh/index.astro     # 中文首页
│   └── styles/
│       └── global.css         # 全局样式
├── astro.config.mjs           # Astro 配置
├── package.json
└── tsconfig.json
```

## 自定义配置

### 修改站点信息

编辑 `src/data/site.ts`：

```typescript
export const siteConfig = {
  title: 'Lithe',
  version: '0.1.0',
  github: 'https://github.com/loafman1120/LitheNet',
  url: 'https://lithe.loafman.top',
  // ...
};
```

### 修改文案

编辑 `src/i18n/en.json`（英文）和 `src/i18n/zh.json`（中文）。

### 修改品牌色

编辑 `src/styles/global.css` 中的 CSS 变量和 `@theme` 块。

### 替换截图

将应用截图放入 `public/` 目录，然后在 `ScreenshotShowcase.astro` 中更新图片路径。

## SEO 优化

- ✅ Open Graph meta 标签
- ✅ Twitter Cards
- ✅ Schema.org 结构化数据
- ✅ 语义化 HTML
- ✅ Canonical URL
- ✅ 图片 alt 标签
- ✅ 懒加载

## 性能优化

- ✅ 静态生成（零服务端渲染）
- ✅ 按需加载粒子动画（Island）
- ✅ `prefers-reduced-motion` 支持
- ✅ 图片懒加载
- ✅ CSS 变量主题切换

## 部署

### Cloudflare Pages（推荐）

1. 将代码推送到 GitHub
2. 在 Cloudflare Dashboard 创建 Pages 项目
3. 连接 GitHub 仓库
4. 构建配置：
   - 构建命令：`cd website && pnpm install && pnpm run build`
   - 输出目录：`website/dist`

### GitHub Pages

已配置 `deploy-website.yml` 工作流，push 到 main 时自动部署。

### 自定义域名

1. 在 Cloudflare Pages 项目设置中添加自定义域名
2. 配置 DNS 记录（CNAME 指向 Pages 项目域名，例如 `lithenet.pages.dev`）
3. SSL/TLS 设置为 Full mode

## 添加新功能区

1. 在 `src/components/` 创建新组件
2. 在 `src/i18n/en.json` 和 `src/i18n/zh.json` 添加文案
3. 在 `src/pages/en/index.astro` 和 `src/pages/zh/index.astro` 引入组件
4. 添加 `.reveal` class 启用滚动动画
