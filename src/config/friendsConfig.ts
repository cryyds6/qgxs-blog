import type { FriendLink, FriendsPageConfig } from "../types/config";

// 友链页面配置
export const friendsPageConfig: FriendsPageConfig = {
	// 页面标题，如果留空则使用 i18n 中的翻译
	title: "",

	// 页面描述文本，如果留空则使用 i18n 中的翻译
	description: "",

	// 是否显示评论区，需要先在commentConfig.ts启用评论系统
	showComment: true,

	// 是否开启随机排序配置，如果开启，就会忽略权重，构建时进行一次随机排序
	randomizeSort: false,

	// 友链申请链接，填写后会在友链页面显示申请按钮
	// 使用模板参数直接跳转到友链申请模板
	applyLink:
		"https://github.com/cryyds6/qgxs-blog/issues/new?template=friend-link.yml",

	// 本站信息，用于友链申请指南弹窗中的站点信息展示
	siteInfo: {
		name: "Odd.G | 奇怪先生",
		desc: "Odd Gentleman的个人博客，记录思考、技术与生活碎片。",
		url: "https://www.3181314.xyz",
		avatar: "https://www.3181314.xyz/icon.jpeg",
		email: "oddg@foxmail.com",
	},

	// 注意事项，用于友链申请指南弹窗中的注意事项展示
	notes: [
		{
			title: "申请方式",
			content:
				"可将信息发送至邮箱 1044192982@qq.com，oddg@foxmail.com，或者点击下方自助申请友链按钮。",
		},
		{
			title: "互换原则",
			content: "请先将本站添加到您的友链页面，确认后会添加您的友链",
		},
		{
			title: "链接维护",
			content: "友链网站长期无法访问或内容违规，将会被移除",
		},
		{
			title: "内容要求",
			content: "内容积极向上，不含有任何含色情/反动/暴力等违法违规内容",
		},
		{
			title: "站点要求",
			content: "支持 HTTPS，以原创内容为主，能够正常访问且有持续更新",
		},
	],
};

// 友链配置
export const friendsConfig: FriendLink[] = [
	{
		title: "Hzの小站",
		imgurl: "https://favicon.im/zh/blog.mikufans520.top?t=1770102380342",
		desc: "记录碎碎念念，分享个人建站经验、教训及相关技术干货",
		siteurl: "https://blog.yumeacg.com/",
		tags: ["Blog"],
		weight: 5,
		enabled: true,
	},
	{
		title: "小兔导航",
		imgurl:
			"https://moe520.com/wp-content/uploads/2025/09/1758255594-backgrounderaser_1758255571.png",
		desc: "二次元小兔导航",
		siteurl: "https://moe520.com/",
		tags: ["导航"],
		weight: 5,
		enabled: true,
	},
	{
		title: "风灵导航站",
		imgurl:
			"https://358520.xyz/uploads/icons/697f760948b78_b_7eb94da1441bd0d6336e7c1cb561b843.jpg",
		desc: "风灵导航站，大佬导航",
		siteurl: "https://358520.xyz/",
		tags: ["导航"],
		weight: 5,
		enabled: true,
	},
	{
		title: "猫小诗の小站",
		imgurl: "https://mcddos.top/logo.jpg",
		desc: "猫小诗的个人网站与IDCAMS（IDC联盟管理系统）官方网站",
		siteurl: "https://mcddos.top",
		tags: ["Blog"],
		weight: 5,
		enabled: true,
	},
	{
		title: "小兔互联",
		imgurl:
			"https://358520.xyz/uploads/icons/697f734a5352d_local6952f7a99cdd5.png",
		desc: "小兔互联已运营3年之久，提供稳定，高性价比的服务器、免费主机及免费域名等",
		siteurl: "https://moebun.com/",
		tags: ["服务商"],
		weight: 5,
		enabled: true,
	},
	{
		title: "灵烁的个人博客",
		imgurl: "http://blog.xn--5nx6f.top/wp-content/uploads/2026/02/吃瓜.jpg",
		desc: "灵烁的个人小窝，记录自己技术增长过程的博客",
		siteurl: "http://blog.xn--5nx6f.top/",
		tags: ["Blog"],
		weight: 5,
		enabled: true,
	},
	{
		title: "凉白导航",
		imgurl:
			"https://img.3181314.xyz/file/图标/1771431908690_769306e305725267e1c50d726311ba61.jpg",
		desc: "凉白导航页(Liangbai Spage)致力于简洁高效无广告的上网导航和搜索入口，沉淀最具价值链接，全站无商业推广，简约而不简单。",
		siteurl: "https://dh.liangbai.xyz/",
		tags: ["导航"],
		weight: 5,
		enabled: true,
	},
	{
		title: "C佳家",
		imgurl: "https://wang-sz.cn/wp-content/uploads/logos/WebLogo.ico",
		desc: "专注打造最好的IT学习社区",
		siteurl: "https://wang-sz.cn/",
		tags: ["Blog", "资源网"],
		weight: 5,
		enabled: true,
	},
	{
		title: "第一剧场",
		imgurl: "https://img.3181314.xyz/file/图标/1771824542032_favicon.png",
		desc: "第一剧场-VIP级沉浸看剧",
		siteurl: "https://www.tvs1.vip/",
		tags: ["视频网"],
		weight: 5,
		enabled: true,
	},
	{
		title: "worable",
		imgurl:
			"https://www.worable.top/wp-content/uploads/2026/02/2026020109015019.jpg",
		desc: "≡ω≡ 嗯对，一名普通的职一牲~",
		siteurl: "https://www.worable.top/",
		tags: ["Blog"],
		weight: 5,
		enabled: true,
	},
	{
		title: "小满的墨水瓶",
		imgurl: "https://static.yhdzz.cn/imgs/xiaoman1221/512x512.png",
		desc: "天上如是，地下亦然",
		siteurl: "https://www.yhdzz.cn/",
		tags: ["Blog"],
		weight: 5,
		enabled: true,
	},
	{
		title: "UpXuu",
		imgurl: "https://upxuu.com/images/20260214145619.jpg",
		desc: "逐光而上！",
		siteurl: "https://upxuu.com/",
		tags: ["Blog"],
		weight: 5,
		enabled: true,
	},
	{
		title: "语初博客",
		imgurl: "https://file.icve.com.cn/file_doc/1775486276275-szrqpk.jpg",
		desc: "致力于互联网优质资源共享",
		siteurl: "https://www.yc520.top/",
		tags: ["Blog", "资源网"],
		weight: 5,
		enabled: true,
	},
	{
		title: "Moca",
		imgurl: "https://blog.gonelove.de/avatar.webp",
		desc: "Gone_Love 的个人博客",
		siteurl: "https://blog.gonelove.de/",
		tags: ["Blog"],
		weight: 5,
		enabled: true,
	},
	{
		title: "XingHuiSamaの宝藏之地",
		imgurl: "https://bu.dusays.com/2026/03/24/69c1e38ac1846.jpg",
		desc: "今天我也要学习吗",
		siteurl: "https://www.xinghuisama.top/",
		tags: ["Blog"],
		weight: 5,
		enabled: true,
	},
	{
		title: "他说",
		imgurl: "https://090909.top/assets/images/avatar.webp",
		desc: "梁栋烨的博客网站。",
		siteurl: "https://090909.top/",
		tags: ["Blog"],
		weight: 5,
		enabled: true,
	},
	{
		title: "MaxLHy",
		imgurl: "https://maxlhy0424.is-a.dev/images/favicon.webp",
		desc: "Where All Miracle Begins.",
		siteurl: "https://maxlhy0424.is-a.dev/",
		tags: ["Blog"],
		weight: 5,
		enabled: true,
	},
	{
		title: "风中的思绪",
		imgurl: "https://blog.windstart.top/assets/home/xiaologo.webp",
		desc: "风中的思绪，梦里的足迹",
		siteurl: "https://blog.windstart.top/",
		tags: ["Blog"],
		weight: 5,
		enabled: true,
	},
	{
		title: "十三",
		imgurl: "https://blog.nw177.cn/assets/avatar.webp",
		desc: "欲买桂花同载酒，终不似，少年游。",
		siteurl: "https://blog.nw177.cn",
		tags: ["Blog"],
		weight: 5,
		enabled: true,
	},
	{
		title: "池泛の小窝",
		imgurl: "https://chortle.asia/uploads/image/avater_1786082652615.jpg",
		desc: "山水有相逢，来日皆可期",
		siteurl: "https://chortle.asia/",
		tags: ["Blog"],
		weight: 5,
		enabled: true,
	},
	{
		title: "LonelyBingの小窝",
		imgurl:
			"https://img.lonelybing.top/file/%E5%A4%B4%E5%83%8F/1789400498937.jpg",
		desc: "一名普普通通の大学生~",
		siteurl: "https://lonelybing.top/",
		tags: ["Blog"],
		weight: 5,
		enabled: true,
	},
];

// 获取启用的友链并进行排序
export const getEnabledFriends = (): FriendLink[] => {
	const friends = friendsConfig.filter((friend) => friend.enabled);

	if (friendsPageConfig.randomizeSort) {
		return friends.sort(() => Math.random() - 0.5);
	}

	// 权重降序；同权重时按配置倒序（后添加的友链靠前）
	return friends
		.map((friend, index) => ({ friend, index }))
		.sort((a, b) => b.friend.weight - a.friend.weight || b.index - a.index)
		.map(({ friend }) => friend);
};
