<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>

<html class="dark" lang="en"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<title>Nexus | The Sovereign Workspace</title>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link href="https://fonts.googleapis.com/css2?family=Manrope:wght@400;600;700;800&amp;family=Inter:wght@300;400;500;600&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<script id="tailwind-config">
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    "colors": {
                        "surface-dim": "#0b1326",
                        "on-secondary-fixed-variant": "#005236",
                        "on-surface": "#dae2fd",
                        "secondary-fixed-dim": "#4edea3",
                        "on-background": "#dae2fd",
                        "surface-variant": "#2d3449",
                        "on-secondary-container": "#00311f",
                        "secondary": "#4edea3",
                        "surface-container": "#171f33",
                        "tertiary-fixed": "#ffddb8",
                        "background": "#0b1326",
                        "on-tertiary-fixed": "#2a1700",
                        "error": "#ffb4ab",
                        "tertiary": "#ffb95f",
                        "on-error-container": "#ffdad6",
                        "on-secondary-fixed": "#002113",
                        "on-error": "#690005",
                        "surface-container-low": "#131b2e",
                        "surface": "#0b1326",
                        "inverse-surface": "#dae2fd",
                        "surface-tint": "#7bd0ff",
                        "primary-container": "#001a27",
                        "on-tertiary": "#472a00",
                        "surface-container-high": "#222a3d",
                        "on-secondary": "#003824",
                        "on-primary-fixed": "#001e2c",
                        "secondary-container": "#00a572",
                        "on-primary": "#00354a",
                        "outline": "#909097",
                        "error-container": "#93000a",
                        "inverse-on-surface": "#283044",
                        "surface-container-lowest": "#060e20",
                        "primary-fixed-dim": "#7bd0ff",
                        "outline-variant": "#45464d",
                        "inverse-primary": "#00668a",
                        "on-primary-fixed-variant": "#004c69",
                        "on-tertiary-fixed-variant": "#653e00",
                        "primary": "#7bd0ff",
                        "on-primary-container": "#008abb",
                        "surface-container-highest": "#2d3449",
                        "on-surface-variant": "#c6c6cd",
                        "primary-fixed": "#c4e7ff",
                        "secondary-fixed": "#6ffbbe",
                        "surface-bright": "#31394d",
                        "tertiary-container": "#251400",
                        "tertiary-fixed-dim": "#ffb95f",
                        "on-tertiary-container": "#b47300"
                    },
                    "borderRadius": {
                        "DEFAULT": "0.25rem",
                        "lg": "1rem",
                        "xl": "1.25rem",
                        "full": "9999px"
                    },
                    "fontFamily": {
                        "headline": ["Manrope"],
                        "body": ["Inter"],
                        "label": ["Inter"]
                    }
                }
            }
        }
    </script>
<style>
        body { background-color: #0b1326; color: #dae2fd; font-family: 'Inter', sans-serif; }
        .glass-panel { background: rgba(45, 52, 73, 0.6); backdrop-filter: blur(24px); }
        .nexus-gradient { background: linear-gradient(135deg, #7bd0ff 0%, #008abb 100%); }
        .no-scrollbar::-webkit-scrollbar { display: none; }
    </style>
</head>
<body class="overflow-x-hidden selection:bg-primary selection:text-on-primary">
<!-- Top Navigation -->
<nav class="sticky top-0 w-full z-50 bg-slate-950/60 backdrop-blur-xl shadow-2xl shadow-black/40">
<div class="max-w-7xl mx-auto flex justify-between items-center px-8 py-4">
<div class="text-xl font-extrabold tracking-tighter text-white">Nexus</div>
<div class="hidden md:flex items-center gap-8 font-manrope tracking-tight font-bold text-sm">
<a class="text-slate-400 hover:text-white transition-colors" href="#">Find Work</a>
<a class="text-slate-400 hover:text-white transition-colors" href="#">Hire Talent</a>
<a class="text-slate-400 hover:text-white transition-colors" href="#">How it Works</a>
<a class="text-slate-400 hover:text-white transition-colors" href="#">Pricing</a>
</div>
<div class="flex items-center gap-4">
<a href="${pageContext.request.contextPath}/register">
<button class="text-slate-400 hover:text-white transition-colors font-manrope font-bold text-sm">Sign In</button>
</a>

<a href="${pageContext.request.contextPath}/login">
    <button class="nexus-gradient px-6 py-2 rounded-full font-manrope font-bold text-sm text-white active:scale-95 transition-transform">Get Started</button>
</a>
</div>
</div>
</nav>
<!-- Hero Section -->
<header class="relative pt-24 pb-32 overflow-hidden px-8">
<div class="max-w-7xl mx-auto grid lg:grid-cols-2 gap-16 items-center">
<div class="relative z-10">
<h1 class="text-6xl md:text-7xl font-headline font-extrabold tracking-tighter text-white leading-[1.1] mb-8">
                    The Sovereign Workspace for the <span class="text-primary-fixed-dim">Modern Elite</span>
</h1>
<p class="text-lg md:text-xl text-on-surface-variant font-body leading-relaxed mb-10 max-w-xl">
                    Experience the ultimate task marketplace designed for high-performance teams and independent experts. Manage micro-tasks with atomic precision and absolute financial transparency.
                </p>
<div class="flex flex-wrap gap-4">
<button class="nexus-gradient px-8 py-4 rounded-full font-manrope font-bold text-white shadow-xl shadow-primary/20 hover:brightness-110 transition-all">Get Started</button>
<button class="bg-surface-container-high hover:bg-surface-container-highest px-8 py-4 rounded-full font-manrope font-bold text-white transition-all flex items-center gap-2">
<span class="material-symbols-outlined text-primary-fixed-dim">play_circle</span>
                        Watch Demo
                    </button>
</div>
</div>
<div class="relative lg:h-[600px] flex items-center justify-center">
<div class="absolute inset-0 bg-primary/10 blur-[120px] rounded-full"></div>
<img alt="Workflow Connectivity" class="relative w-full h-full object-contain drop-shadow-2xl" data-alt="Futuristic abstract 3D nodes interconnected by glowing light paths on a dark obsidian background representing global connectivity and data flow" src="https://lh3.googleusercontent.com/aida-public/AB6AXuBsZNCNNNoQfemyCW57kSc9EAk6Il2X6dlW1bXIQZo515VuWLTB9j3QxNQo9DRUPTuJLDIO_FJBPUeLWxSsswshY9Ykgj4zS_qj1dOgbIWawRbCGTDAULN5-j3swrm_n8zJXHKEM4sgLHTZuzrhj8u8GuUIeE3TaPNZVOYYAHXCh5Q0nEnXwvIJGTsO3jlOh-8KfDM63DXbAsZInw26EWsvbZTp081qxdeDQ1c63yh9-DpR0jfUx1-tvmC_Nzg6tR9Awm9H9zq2hSYW"/>
</div>
</div>
</header>
<!-- Employers Section -->
<section class="py-24 bg-surface-container-low">
<div class="max-w-7xl mx-auto px-8">
<div class="flex flex-col md:flex-row justify-between items-end mb-16 gap-8">
<div>
<span class="text-secondary font-manrope font-bold tracking-widest text-xs uppercase mb-4 block">Command Center</span>
<h2 class="text-4xl md:text-5xl font-headline font-bold text-white tracking-tight">Command Your Operations</h2>
</div>
<p class="text-on-surface-variant max-w-md font-body">
                    Complete oversight with institutional-grade analytics. Nexus gives you the tools to scale your workforce without sacrificing quality or security.
                </p>
</div>
<div class="grid md:grid-cols-3 gap-8">
<div class="glass-panel p-8 rounded-xl border border-outline-variant/20 hover:border-primary/30 transition-all group">
<div class="flex justify-between items-start mb-12">
<span class="material-symbols-outlined text-4xl text-primary-fixed-dim group-hover:scale-110 transition-transform">monitoring</span>
<span class="text-secondary text-sm font-bold bg-secondary-container/20 px-3 py-1 rounded-full">+12.5%</span>
</div>
<div class="space-y-1">
<p class="text-sm font-label text-on-surface-variant">Active Tasks</p>
<h3 class="text-4xl font-headline font-bold text-white">1,284</h3>
</div>
</div>
<div class="glass-panel p-8 rounded-xl border border-outline-variant/20 hover:border-primary/30 transition-all group">
<div class="flex justify-between items-start mb-12">
<span class="material-symbols-outlined text-4xl text-secondary-fixed-dim group-hover:scale-110 transition-transform">payments</span>
<span class="text-primary text-sm font-bold bg-primary-container/40 px-3 py-1 rounded-full">Automated</span>
</div>
<div class="space-y-1">
<p class="text-sm font-label text-on-surface-variant">Total Disbursed</p>
<h3 class="text-4xl font-headline font-bold text-white">$42.8k</h3>
</div>
</div>
<div class="md:col-span-1 bg-surface-container rounded-xl overflow-hidden relative">
<img alt="Analytics" class="w-full h-full object-cover opacity-50 grayscale hover:grayscale-0 transition-all duration-700" data-alt="Sleek dark mode analytics dashboard showing neon blue and green charts and data points for workforce performance" src="https://lh3.googleusercontent.com/aida-public/AB6AXuDCrAh_Kt2YGXyRHdyTewlXT68Na8fJOQ_Ujxl4WzXrmnZta9wdlaUOqD5sN57Y74shH731qmAgTsORxrLKrWGUte7Pxd9drxYjpTpbZG5axtlfE-cezSTqoOyFO-U6Ldhc_8JaJvUx_PJqtFsRW87uNhPa1K5V1onkXIdQn-8BbodARdA7oGiktvBLjw8RfUh31-mb5Issvdgw_HHdknXcM5HRpuhkg5HADRLUgX5evYEb_zu_Ym_KRVwq0ouTz6DCZFk3NYCfL3-7"/>
<div class="absolute inset-0 bg-gradient-to-t from-background to-transparent flex flex-col justify-end p-8">
<h4 class="text-xl font-headline font-bold text-white mb-2">Real-time Quality Control</h4>
<p class="text-sm text-on-surface-variant">AI-powered verification for every single micro-task.</p>
</div>
</div>
</div>
</div>
</section>
<!-- Workers Section -->
<section class="py-24 overflow-hidden">
<div class="max-w-7xl mx-auto px-8">
<div class="grid lg:grid-cols-12 gap-16 items-center">
<div class="lg:col-span-5">
<span class="text-tertiary font-manrope font-bold tracking-widest text-xs uppercase mb-4 block">Independent Growth</span>
<h2 class="text-4xl md:text-5xl font-headline font-bold text-white tracking-tight mb-8">Fuel Your Independence</h2>
<p class="text-lg text-on-surface-variant font-body mb-10 leading-relaxed">
                        Access the world's highest-paying micro-tasks. Track your performance with precision metrics and watch your sovereign wealth grow in real-time.
                    </p>
<div class="space-y-6">
<div class="flex items-center gap-4">
<div class="w-12 h-12 rounded-full bg-surface-container flex items-center justify-center">
<span class="material-symbols-outlined text-primary">bolt</span>
</div>
<span class="text-white font-manrope font-semibold">Instant settlement for completed milestones.</span>
</div>
<div class="flex items-center gap-4">
<div class="w-12 h-12 rounded-full bg-surface-container flex items-center justify-center">
<span class="material-symbols-outlined text-secondary">verified_user</span>
</div>
<span class="text-white font-manrope font-semibold">Build a verified reputation score that unlocks premium pools.</span>
</div>
</div>
</div>
<div class="lg:col-span-7 relative">
<div class="glass-panel p-8 rounded-xl border border-outline-variant/10 shadow-2xl">
<div class="flex justify-between items-center mb-8">
<h4 class="font-headline font-bold text-white">Wage Pulse</h4>
<span class="text-secondary-fixed-dim text-xs font-bold px-3 py-1 bg-on-secondary-container/20 rounded-full">LIVE TRACKING</span>
</div>
<!-- Custom Micro-chart simulation -->
<div class="h-48 flex items-end gap-2 mb-8">
<div class="flex-1 bg-surface-container hover:bg-primary/20 transition-colors rounded-t-lg h-[40%]"></div>
<div class="flex-1 bg-surface-container hover:bg-primary/20 transition-colors rounded-t-lg h-[65%]"></div>
<div class="flex-1 bg-surface-container hover:bg-primary/20 transition-colors rounded-t-lg h-[55%]"></div>
<div class="flex-1 bg-surface-container hover:bg-primary/20 transition-colors rounded-t-lg h-[85%]"></div>
<div class="flex-1 bg-surface-container-highest hover:bg-secondary/40 transition-colors rounded-t-lg h-[100%]"></div>
<div class="flex-1 bg-surface-container hover:bg-primary/20 transition-colors rounded-t-lg h-[70%]"></div>
<div class="flex-1 bg-surface-container hover:bg-primary/20 transition-colors rounded-t-lg h-[90%]"></div>
</div>
<div class="grid grid-cols-2 gap-4">
<div class="bg-surface-container-lowest p-4 rounded-lg">
<p class="text-xs text-slate-500 uppercase font-bold tracking-tighter">Earnings Today</p>
<p class="text-2xl font-headline font-extrabold text-white">$412.50</p>
</div>
<div class="bg-surface-container-lowest p-4 rounded-lg">
<p class="text-xs text-slate-500 uppercase font-bold tracking-tighter">Performance Rank</p>
<p class="text-2xl font-headline font-extrabold text-secondary">Top 0.5%</p>
</div>
</div>
</div>
<!-- Decorator task card -->
<div class="absolute -bottom-8 -right-8 w-64 glass-panel p-4 rounded-lg border border-outline-variant/20 hidden md:block">
<div class="flex gap-3 items-center">
<div class="w-10 h-10 rounded-lg bg-tertiary/20 flex items-center justify-center text-tertiary">
<span class="material-symbols-outlined">data_object</span>
</div>
<div>
<p class="text-xs font-bold text-white">Priority Task</p>
<p class="text-[10px] text-slate-400">Schema Validation</p>
</div>
<div class="ml-auto text-primary text-xs font-bold">$12.00</div>
</div>
</div>
</div>
</div>
</div>
</section>
<!-- Features Bento Grid -->
<section class="py-24 bg-surface-container-lowest">
<div class="max-w-7xl mx-auto px-8">
<div class="text-center mb-16">
<h2 class="text-3xl font-headline font-bold text-white mb-4">Engineered for Perfection</h2>
<div class="w-16 h-1 nexus-gradient mx-auto rounded-full"></div>
</div>
<div class="grid grid-cols-1 md:grid-cols-4 gap-6">
<div class="md:col-span-2 bg-surface-container p-10 rounded-xl hover:bg-surface-container-high transition-colors">
<span class="material-symbols-outlined text-primary text-4xl mb-6">speed</span>
<h3 class="text-2xl font-headline font-bold text-white mb-4">Instant Settlements</h3>
<p class="text-on-surface-variant font-body">Payments are processed the millisecond a task is verified. No waiting periods, no friction, just pure liquidity.</p>
</div>
<div class="md:col-span-2 bg-surface-container p-10 rounded-xl hover:bg-surface-container-high transition-colors">
<span class="material-symbols-outlined text-secondary text-4xl mb-6">verified</span>
<h3 class="text-2xl font-headline font-bold text-white mb-4">Elite Verification</h3>
<p class="text-on-surface-variant font-body">Our 7-layer verification protocol ensures every contributor meets the highest standards of professional excellence.</p>
</div>
<div class="md:col-span-2 bg-surface-container p-10 rounded-xl hover:bg-surface-container-high transition-colors">
<span class="material-symbols-outlined text-tertiary text-4xl mb-6">public</span>
<h3 class="text-2xl font-headline font-bold text-white mb-4">Global Task Index</h3>
<p class="text-on-surface-variant font-body">Access a unified stream of elite opportunities from Fortune 500 companies and tech pioneers across the globe.</p>
</div>
<div class="md:col-span-2 bg-surface-container p-10 rounded-xl hover:bg-surface-container-high transition-colors">
<span class="material-symbols-outlined text-primary-fixed-dim text-4xl mb-6">analytics</span>
<h3 class="text-2xl font-headline font-bold text-white mb-4">Real-time Analytics</h3>
<p class="text-on-surface-variant font-body">Granular data insights into your team's velocity, quality trends, and financial efficiency in one dashboard.</p>
</div>
</div>
</div>
</section>
<!-- Testimonial Section -->
<section class="py-32 px-8 bg-surface">
<div class="max-w-5xl mx-auto relative">
<span class="material-symbols-outlined text-7xl text-primary/10 absolute -top-12 -left-8 pointer-events-none">format_quote</span>
<div class="relative z-10 text-center">
<blockquote class="text-3xl md:text-4xl font-headline font-bold text-white italic leading-tight mb-12">
                    "Nexus has fundamentally shifted how we view distributed work. It's not just a platform; it's a sovereign operating system that has increased our architectural team's output by 140%."
                </blockquote>
<div class="flex flex-col items-center">
<img alt="Lead Architect" class="w-16 h-16 rounded-full object-cover mb-4 border-2 border-primary/30" data-alt="Professional headshot of a mature man with a thoughtful expression, wearing a tailored navy blazer in a high-end office environment" src="https://lh3.googleusercontent.com/aida-public/AB6AXuB5Z2NZ5R8Afga77ZAyyfDNVexsiWaD5aixY0y9QVcu0xwyaRBVybG5tg779fFiWTu44_lgfXMvlVfZx4QKldAqdouPqW6852Mx0a_itz5FImQ8ExaARo-8GkVJxQV8W2ubYaINsz_hsex6GRgrYhMBZ15OEISmx8PwH5Zv7uYv5FF4a_s1U616xRgZWO-iZ4z9raQYyNveCe_T3DOrUzVtSBwD1Ws6S5xJNpC03IWERAEb0JrNcPWCLbYMfxM7pvm-v7bb8zE6_GvS"/>
<p class="font-headline font-bold text-white">Julian Sterling</p>
<p class="text-sm text-primary-fixed-dim uppercase tracking-widest font-bold">Lead Architect, Sovereign Systems</p>
</div>
</div>
</div>
</section>
<!-- Footer -->
<footer class="bg-slate-900 w-full py-12 px-8">
<div class="max-w-7xl mx-auto grid grid-cols-2 md:grid-cols-4 gap-8 mb-12">
<div class="col-span-2 md:col-span-1">
<div class="text-lg font-black text-white mb-6">Nexus</div>
<p class="text-slate-500 font-inter text-xs leading-relaxed max-w-[200px]">
                    The architectural foundation for the future of professional independence and organizational command.
                </p>
</div>
<div class="flex flex-col gap-3">
<h5 class="text-white font-manrope font-bold text-sm mb-2">Company</h5>
<a class="text-slate-500 hover:text-emerald-400 transition-colors font-inter text-xs tracking-wide" href="#">Enterprise Solutions</a>
<a class="text-slate-500 hover:text-emerald-400 transition-colors font-inter text-xs tracking-wide" href="#">Affiliate Program</a>
<a class="text-slate-500 hover:text-emerald-400 transition-colors font-inter text-xs tracking-wide" href="#">Global Task Index</a>
</div>
<div class="flex flex-col gap-3">
<h5 class="text-white font-manrope font-bold text-sm mb-2">Legal</h5>
<a class="text-slate-500 hover:text-emerald-400 transition-colors font-inter text-xs tracking-wide" href="#">Terms of Service</a>
<a class="text-slate-500 hover:text-emerald-400 transition-colors font-inter text-xs tracking-wide" href="#">Privacy Policy</a>
</div>
<div class="flex flex-col gap-3">
<h5 class="text-white font-manrope font-bold text-sm mb-2">Support</h5>
<a class="text-slate-500 hover:text-emerald-400 transition-colors font-inter text-xs tracking-wide" href="#">Support Center</a>
<div class="mt-4 flex gap-4">
<span class="material-symbols-outlined text-slate-500 hover:text-primary transition-colors cursor-pointer">share</span>
<span class="material-symbols-outlined text-slate-500 hover:text-primary transition-colors cursor-pointer">alternate_email</span>
</div>
</div>
</div>
<div class="max-w-7xl mx-auto pt-8 border-t border-slate-800 flex flex-col md:flex-row justify-between items-center gap-4">
<p class="text-slate-500 font-inter text-xs tracking-wide">© 2024 Nexus Sovereign Workspace. All rights reserved.</p>
<div class="flex items-center gap-2">
<div class="w-2 h-2 rounded-full bg-secondary"></div>
<span class="text-[10px] text-slate-500 font-bold uppercase tracking-widest">Network Status: Optimal</span>
</div>
</div>
</footer>
</body></html>