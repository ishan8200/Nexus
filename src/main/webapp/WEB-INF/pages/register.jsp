<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>

<html class="dark" lang="en"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<title>Nexus - Create Your Sovereign Account</title>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link href="https://fonts.googleapis.com/css2?family=Manrope:wght@200;400;600;700;800&amp;family=Inter:wght@300;400;500;600&amp;display=swap" rel="stylesheet"/>
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
    .glass-effect {
      background: rgba(45, 52, 73, 0.6);
      backdrop-filter: blur(24px);
    }
    .material-symbols-outlined {
      font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
    }
  </style>
</head>
<body class="bg-background text-on-background font-body antialiased min-h-screen">
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
<!-- Navigation Shell Suppression: Transactional Screen Rule Applied -->
<main class="min-h-screen flex flex-col md:flex-row">
<!-- Left Panel: Branding & Imagery -->
<section class="hidden md:flex md:w-1/2 lg:w-3/5 bg-surface-container-lowest relative overflow-hidden items-center justify-center p-12">
<!-- Background Ambient Glow -->
<div class="absolute top-[-10%] right-[-10%] w-96 h-96 bg-primary/20 blur-[120px] rounded-full"></div>
<div class="absolute bottom-[-10%] left-[-10%] w-96 h-96 bg-secondary/10 blur-[120px] rounded-full"></div>
<div class="relative z-10 max-w-xl">
<div class="mb-12 flex items-center gap-3">
<div class="w-10 h-10 rounded-lg bg-gradient-to-br from-primary to-on-primary-container flex items-center justify-center shadow-lg">
<span class="material-symbols-outlined text-white" style="font-variation-settings: 'FILL' 1;">terminal</span>
</div>
<span class="font-headline text-3xl font-black tracking-tighter text-on-surface">Nexus</span>
</div>
<h1 class="font-headline text-5xl lg:text-6xl font-extrabold tracking-tight text-on-surface leading-[1.1] mb-8">
          The Sovereign <br/>
<span class="bg-gradient-to-r from-primary via-secondary to-primary bg-[length:200%_auto] bg-clip-text text-transparent">Workspace</span>
</h1>
<p class="text-on-surface-variant text-lg lg:text-xl leading-relaxed mb-12 max-w-md">
          Command your workflow with high-performance tools designed for the modern elite contractor and enterprise manager.
        </p>
<!-- Feature Bento Sneak-Peak -->
<div class="grid grid-cols-2 gap-4">
<div class="p-6 rounded-xl bg-surface-container-low border border-outline-variant/10 shadow-xl">
<span class="material-symbols-outlined text-primary mb-3">speed</span>
<div class="font-headline font-bold text-on-surface mb-1">Instant Settlement</div>
<p class="text-xs text-on-surface-variant leading-normal">Automated earnings distribution with zero latency.</p>
</div>
<div class="p-6 rounded-xl bg-surface-container-low border border-outline-variant/10 shadow-xl mt-8">
<span class="material-symbols-outlined text-secondary mb-3">verified_user</span>
<div class="font-headline font-bold text-on-surface mb-1">Elite Verification</div>
<p class="text-xs text-on-surface-variant leading-normal">Top-tier marketplace access for verified professionals.</p>
</div>
</div>
</div>
<!-- Hero Image Overlay -->
<div class="absolute inset-0 z-0 opacity-20 pointer-events-none">
<img alt="" class="w-full h-full object-cover" data-alt="Abstract futuristic digital network with flowing blue and emerald lines on a dark background, cinematic lighting, ultra-high resolution" src="https://lh3.googleusercontent.com/aida-public/AB6AXuDPZKrjF7tveb4HWu3KrTfBuLIVxu1xkw_e9RLCbqIXmfdD_FtYaVH_M4FfibPk9_W9tF5EWmre7v1HuDlAMcxwLjOZtYmTAwF4Z_9QV8Qmeuc6MIer1OOgWmojR_WuKD-81AEoVehx9QVSUjdzVah0tLty3WQe88trwxZJ6IsCR1Za90ypGfkVm5q5WCR1wV3vixYqPklggDa3LUfW1SAwRaTuDRh0200sk9oQIfqfxjMeU5_ZQKFCNQ8YRp9Q-nEq9e6aiGMpDWia"/>
</div>
</section>
<!-- Right Panel: Registration Form -->
<section class="flex-1 flex flex-col items-center justify-center p-6 md:p-12 lg:p-24 bg-surface-dim">
<div class="w-full max-w-md">
<!-- Mobile Logo -->
<div class="md:hidden mb-8 flex justify-center">
<div class="flex items-center gap-2">
<div class="w-8 h-8 rounded-lg bg-gradient-to-br from-primary to-on-primary-container flex items-center justify-center">
<span class="material-symbols-outlined text-white text-sm" style="font-variation-settings: 'FILL' 1;">terminal</span>
</div>
<span class="font-headline text-xl font-black tracking-tighter text-on-surface">Nexus</span>
</div>
</div>
<div class="mb-10 text-center md:text-left">
<h2 class="font-headline text-3xl font-bold text-on-surface tracking-tight mb-2">Create Account</h2>
<p class="text-on-surface-variant">Join the next generation of professional talent.</p>
</div>
<form class="space-y-6">
<!-- Role Selection: Custom Premium Toggle -->
<div class="space-y-3">
<label class="text-sm font-semibold text-on-surface-variant tracking-wide px-1">SELECT YOUR ROLE</label>
<div class="grid grid-cols-2 gap-3">
<button class="group relative flex flex-col items-start p-4 rounded-xl bg-primary/10 border-2 border-primary transition-all text-left" type="button">
<span class="material-symbols-outlined text-primary mb-2" style="font-variation-settings: 'FILL' 1;">business_center</span>
<span class="font-headline font-bold text-on-surface text-sm">Employer</span>
<span class="text-[10px] text-primary/80 uppercase tracking-tighter">Hire &amp; Manage</span>
<div class="absolute top-3 right-3 w-4 h-4 rounded-full bg-primary flex items-center justify-center">
<span class="material-symbols-outlined text-primary-container text-[10px] font-bold">check</span>
</div>
</button>
<button class="group relative flex flex-col items-start p-4 rounded-xl bg-surface-container border-2 border-transparent hover:border-outline-variant/30 transition-all text-left" type="button">
<span class="material-symbols-outlined text-on-surface-variant mb-2">engineering</span>
<span class="font-headline font-bold text-on-surface-variant group-hover:text-on-surface text-sm">Contractor</span>
<span class="text-[10px] text-on-surface-variant/60 uppercase tracking-tighter">Execute Tasks</span>
</button>
</div>
</div>
<!-- Name Field -->
<div class="space-y-2">
<label class="text-xs font-bold text-on-surface-variant uppercase tracking-widest px-1" for="full_name">Full Name</label>
<div class="relative group">
<span class="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-on-surface-variant group-focus-within:text-primary transition-colors">person</span>
<input class="w-full bg-surface-container-low border border-outline-variant/20 rounded-lg py-3.5 pl-12 pr-4 text-on-surface placeholder:text-on-surface-variant/40 focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all" id="full_name" placeholder="Johnathan Sterling" type="text"/>
</div>
</div>
<!-- Email Field -->
<div class="space-y-2">
<label class="text-xs font-bold text-on-surface-variant uppercase tracking-widest px-1" for="email_address">Corporate Email</label>
<div class="relative group">
<span class="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-on-surface-variant group-focus-within:text-primary transition-colors">alternate_email</span>
<input class="w-full bg-surface-container-low border border-outline-variant/20 rounded-lg py-3.5 pl-12 pr-4 text-on-surface placeholder:text-on-surface-variant/40 focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all" id="email_address" placeholder="name@nexus.sovereign" type="email"/>
</div>
</div>
<!-- Password Field -->
<div class="space-y-2">
<label class="text-xs font-bold text-on-surface-variant uppercase tracking-widest px-1" for="password">Security Key</label>
<div class="relative group">
<span class="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-on-surface-variant group-focus-within:text-primary transition-colors">lock</span>
<input class="w-full bg-surface-container-low border border-outline-variant/20 rounded-lg py-3.5 pl-12 pr-12 text-on-surface placeholder:text-on-surface-variant/40 focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all" id="password" placeholder="••••••••••••" type="password"/>
<button class="absolute right-4 top-1/2 -translate-y-1/2 text-on-surface-variant hover:text-on-surface" type="button">
<span class="material-symbols-outlined">visibility</span>
</button>
</div>
</div>
<!-- Terms -->
<div class="flex items-start gap-3 py-2">
<input class="mt-1 w-4 h-4 rounded bg-surface-container border-outline-variant/50 text-primary focus:ring-primary/20" id="terms" type="checkbox"/>
<label class="text-xs text-on-surface-variant leading-relaxed" for="terms">
              I acknowledge the <a class="text-primary hover:underline" href="#">Nexus Master Services Agreement</a> and the <a class="text-primary hover:underline" href="#">Sovereign Privacy Policy</a>.
            </label>
</div>
<!-- CTA -->
<button class="w-full py-4 rounded-lg bg-gradient-to-r from-primary to-on-primary-container text-on-primary-fixed font-headline font-extrabold text-sm uppercase tracking-[0.2em] shadow-lg shadow-primary/20 hover:shadow-primary/40 hover:scale-[1.01] active:scale-[0.98] transition-all" type="submit">
            Initialize Account
          </button>
</form>
<div class="mt-12 text-center">
<p class="text-sm text-on-surface-variant">
            Already have a workspace? 
            <a class="text-secondary font-bold hover:underline ml-1" href="login">Login here</a>
</p>
</div>
<!-- Footnote Architecture -->
<div class="mt-16 pt-8 border-t border-outline-variant/10 flex justify-between items-center text-[10px] font-bold text-on-surface-variant/40 uppercase tracking-widest">
<span>SECURE ENCRYPTION v4.2</span>
<span>© 2024 NEXUS SYSTEMS INC.</span>
</div>
</div>
</section>
</main>
<!-- Bottom Navigation Bar: Suppressed for Registration Context -->
</body>
</html>