<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>

<html class="dark" lang="en"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<title>Nexus Login | Sovereign Workspace</title>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&amp;family=Manrope:wght@700;800&amp;display=swap" rel="stylesheet"/>
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
        body { font-family: 'Inter', sans-serif; background-color: #0b1326; }
        .font-manrope { font-family: 'Manrope', sans-serif; }
        .glass-panel {
            background: rgba(23, 31, 51, 0.6);
            backdrop-filter: blur(24px);
        }
        .material-symbols-outlined {
            font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
        }
        .bg-nexus-gradient {
            background: linear-gradient(135deg, #7bd0ff 0%, #008abb 100%);
        }
        .no-scrollbar::-webkit-scrollbar { display: none; }
    </style>
</head>
<body class="bg-surface text-on-surface min-h-screen selection:bg-primary/30 selection:text-primary">
<nav class="sticky top-0 w-full z-50 bg-slate-950/90 backdrop-blur-xl shadow-2xl shadow-black/40">
  <div class="max-w-7xl mx-auto flex flex-wrap justify-between items-center px-6 py-4">
    <div class="text-xl font-extrabold tracking-tighter text-white">Nexus</div>
    <div class="hidden md:flex items-center gap-8 font-manrope tracking-tight font-bold text-sm">
      <a class="text-slate-400 hover:text-white transition-colors" href="${pageContext.request.contextPath}/">Home</a>
      <a class="text-slate-400 hover:text-white transition-colors" href="${pageContext.request.contextPath}/login">Login</a>
      <a class="text-slate-400 hover:text-white transition-colors" href="${pageContext.request.contextPath}/register">Register</a>
    </div>
    <div class="flex items-center gap-4">
      
    </div>
  </div>
</nav>

<!-- Subtle Background Texture -->
<div class="fixed inset-0 pointer-events-none opacity-20 overflow-hidden">
<div class="absolute -top-1/4 -left-1/4 w-[1000px] h-[1000px] rounded-full bg-primary/10 blur-[120px]"></div>
<div class="absolute -bottom-1/4 -right-1/4 w-[1000px] h-[1000px] rounded-full bg-secondary/5 blur-[120px]"></div>
</div>
<!-- Login Container -->
<main class="relative w-full max-w-md mx-auto mt-24 px-4">
<!-- Brand Header -->
<div class="mb-12 text-center">
<div class="inline-flex items-center justify-center mb-6">
<div class="w-12 h-12 rounded-xl bg-nexus-gradient flex items-center justify-center shadow-lg shadow-primary/20">
<span class="material-symbols-outlined text-surface text-3xl font-bold" style="font-variation-settings: 'FILL' 1;">terminal</span>
</div>
</div>
<h1 class="text-4xl font-manrope font-extrabold tracking-tighter text-on-surface mb-2">Nexus Workspace</h1>
<p class="text-on-surface-variant font-body text-sm tracking-wide">Enter the sovereign command center</p>
</div>
<!-- Card Section -->
<div class="glass-panel rounded-xl p-10 shadow-2xl shadow-black/40 border border-white/5 relative z-10">
<form class="space-y-6">
<!-- Email Field -->
<div class="space-y-2">
<label class="block text-xs font-semibold uppercase tracking-widest text-on-surface-variant ml-1" for="email">Email Address</label>
<div class="relative group">
<input class="w-full bg-surface-container-low border-0 outline-none rounded-lg px-4 py-4 text-on-surface placeholder:text-outline/40 focus:ring-2 focus:ring-primary/20 transition-all duration-300" id="email" placeholder="name@company.com" type="email"/>
<div class="absolute inset-0 border border-outline-variant/15 rounded-lg pointer-events-none group-focus-within:border-primary/50 transition-colors"></div>
</div>
</div>
<!-- Password Field -->
<div class="space-y-2">
<div class="flex justify-between items-center px-1">
<label class="block text-xs font-semibold uppercase tracking-widest text-on-surface-variant" for="password">Password</label>
<a class="text-xs font-semibold text-primary hover:text-primary-fixed-dim transition-colors" href="#">Forgot password?</a>
</div>
<div class="relative group">
<input class="w-full bg-surface-container-low border-0 outline-none rounded-lg px-4 py-4 text-on-surface placeholder:text-outline/40 focus:ring-2 focus:ring-primary/20 transition-all duration-300" id="password" placeholder="â¢â¢â¢â¢â¢â¢â¢â¢" type="password"/>
<div class="absolute inset-0 border border-outline-variant/15 rounded-lg pointer-events-none group-focus-within:border-primary/50 transition-colors"></div>
</div>
</div>
<!-- Remember Me -->
<div class="flex items-center space-x-3 px-1">
<div class="relative flex items-center">
<input class="w-5 h-5 rounded bg-surface-container border-outline-variant/20 text-primary focus:ring-offset-surface focus:ring-primary/20 cursor-pointer" id="remember" type="checkbox"/>
</div>
<label class="text-sm text-on-surface-variant cursor-pointer select-none" for="remember">Remember session for 30 days</label>
</div>
<!-- Login Button -->
<button class="w-full bg-nexus-gradient py-4 rounded-lg font-manrope font-bold text-on-primary-container shadow-lg shadow-primary/20 hover:scale-[1.01] active:scale-95 transition-all duration-200" type="submit">
                    Authenticate Session
                </button>
</form>
<!-- Divider -->
<div class="relative my-10">
<div class="absolute inset-0 flex items-center">
<div class="w-full border-t border-outline-variant/10"></div>
</div>
<div class="relative flex justify-center text-xs uppercase tracking-widest">
<span class="px-4 bg-surface-container text-on-surface-variant font-semibold">Or continue with</span>
</div>
</div>
<!-- Social Logins -->
<div class="grid grid-cols-2 gap-4">
<button class="flex items-center justify-center space-x-2 py-3 px-4 rounded-lg bg-surface-container-high hover:bg-surface-container-highest transition-colors group">
<span class="material-symbols-outlined text-xl text-on-surface-variant group-hover:text-primary transition-colors">google</span>
<span class="text-sm font-semibold text-on-surface">Google</span>
</button>
<button class="flex items-center justify-center space-x-2 py-3 px-4 rounded-lg bg-surface-container-high hover:bg-surface-container-highest transition-colors group">
<span class="material-symbols-outlined text-xl text-on-surface-variant group-hover:text-primary transition-colors">work</span>
<span class="text-sm font-semibold text-on-surface">LinkedIn</span>
</button>
</div>
</div>
<!-- Footer -->
<p class="mt-8 text-center text-on-surface-variant text-sm">
            Don't have an account? 
            <a class="text-primary font-semibold hover:underline decoration-primary/30 underline-offset-4" href="register">Request Access</a>
</p>
</main>
<!-- Decorative Image Component (Right-side abstract visual for desktop feel) -->
<div class="hidden lg:block fixed right-0 top-0 bottom-0 w-1/3 opacity-40">
<div class="h-full w-full bg-cover bg-center" data-alt="abstract architectural rendering of glass buildings at dusk with cyan and deep blue reflections and sharp geometric lines" style="background-image: url('https://lh3.googleusercontent.com/aida-public/AB6AXuB_6_i9O0hyCzy_XQ06sTGSwo7kJImyz_m2oT_yE-TB9DcVYv3Pmm_EmiYNIgzPO6Ew9D5XKqivjoagGzMI-K4Hq-_5Jb9sgNncvoKdpBeUb2rnpuZTWAJoEJPIYDdqd-pdFxhm-KfHe7Dzt5yK8I6KS7PRD1wHp-FVDn3o8Fi7oUjiDIqhLO1_h7IAXXGcDb7BlGwhppEJaz1mYp4KQtw87hE9hEnTZTII5CliOw57jmmki59dl2hJFEyyYLDa2l937PZyUWTFjOQc');">
<div class="absolute inset-0 bg-gradient-to-r from-surface via-transparent to-transparent"></div>
</div>
</div>
</body></html>