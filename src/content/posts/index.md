---
title: Fuwari 博客模板简易使用指南
published: 2025-01-30
description: 本博客模板的使用方法
image: ./cover.jpeg
tags: ["博客搭建"]
category: qgxs
draft: false
---

> 封面图片来源：[来源](https://image.civitai.com/xG1nkqKTMzGDvpLrqFT7WA/208fc754-890d-4adb-9753-2c963332675d/width=2048/01651-1456859105-(colour_1.5),girl,_Blue,yellow,green,cyan,purple,red,pink,_best,8k,UHD,masterpiece,male%20focus,%201boy,gloves,%20ponytail,%20long%20hair,.jpeg)

本博客模板基于 [Astro](https://astro.build/) 构建。本指南中未提及的内容，你可前往 [Astro 官方文档](https://docs.astro.build/) 查阅答案。

## 文章前置元数据说明

```yaml
---
title: 我的第一篇博客文章
published: 2025-01-31
description: 这是我新搭建的 Astro 博客的第一篇文章
image: ./cover.jpg
tags: [分享, 示例标签2]
category: qgxs
draft: false
---
```

```yaml
---
title: 111
published: 2025-01-31
description: 111
tags: ["分享"]
category: qgxs
draft: false
---
```

| 配置项        | 说明                                                                                                                                                                                                 |
|---------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `title`       | 文章标题                                                                                                                                                                                                 |
| `published`   | 文章发布日期                                                                                                                                                                                                 |
| `description` | 文章简短描述，将在博客首页展示                                                                                                                                                                                 |
| `image`       | 文章封面图片路径<br/>1. 以 `http://` 或 `https://` 开头：使用网络图片<br/>2. 以 `/` 开头：引用 `public` 目录下的本地图片<br/>3. 无上述前缀：引用与当前 Markdown 文件同级目录的图片                         |
| `tags`        | 文章标签                                                                                                                                                                                                 |
| `category`    | 文章分类                                                                                                                                                                                                 |
| `draft`       | 文章草稿标识，设为 true 时该文章将不会在博客中展示                                                                                                                                                             |

## 文章文件的存放位置

文章文件需存放至 `src/content/posts/` 目录下。你也可创建子目录，更规范地管理文章及相关资源文件。

```
src/content/posts/
├── post-1.md
└── post-2/
    ├── cover.png
    └── index.md
```

## 常用分类与标签推荐

### 推荐文章分类
分类用于对文章做**大维度归类**常用分类如下：
- 技术
- 分享
- 日常
- 学习

### 推荐文章标签
标签用于对文章做**精细化标注**常用标签如下：

#技术 #代码 #网络服务 #生活 #学习 #思考 #分享
#教程 #工具 #效率 #成长 #读书 #日常

### 配置示例
配置参考：
```yaml
---
title: Astro博客搭建全流程教程
published: 2024-01-15
description: 从零开始搭建基于Astro框架的Fuwari博客，包含配置、部署与优化技巧
image: ./astro-cover.png
tags: [技术, 代码, 教程, 工具, 效率]
category: 技术
draft: false
---
```