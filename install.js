#!/usr/bin/env node
"use strict";

/* ========================================================================
 * coding-wisdom installer — 零依赖，跨平台，双 agent 适配
 *
 * 自动检测 Claude Code 和 Codex CLI，部署到对应 skill 目录。
 *   默认：检测到谁装谁（两个都检测到就两个都装）
 *   --target claude  只装 Claude Code
 *   --target codex   只装 Codex CLI
 *   --target both    强制两个都装
 *
 * 首次安装从 skeleton/ 创建 inbox + references 空骨架
 * 更新时保护用户数据，只覆盖 guides/templates/scripts/SKILL.md
 * ========================================================================*/

const fs   = require("fs");
const path = require("path");
const os   = require("os");

const SKILL_NAME = "coding-wisdom";
const PKG_ROOT   = __dirname;
const HOME       = os.homedir();

/* ---- platform definitions ---- */

const PLATFORMS = {
  claude: {
    label:   "Claude Code",
    dir:     path.join(HOME, ".claude"),
    target:  path.join(HOME, ".claude", "skills", SKILL_NAME),
  },
  codex: {
    label:   "Codex CLI",
    dir:     path.join(HOME, ".codex"),
    target:  path.join(HOME, ".codex", "skills", SKILL_NAME),
  },
};

/* 每次安装都覆盖的目录和文件 */
const DIST_DIRS  = ["guides", "templates", "scripts"];
const DIST_FILES = ["SKILL.md"];

/* ---- helpers ---- */

function ensureDir(dir) {
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
}

function copyDir(src, dest) {
  if (!fs.existsSync(src)) return;
  ensureDir(dest);
  for (const entry of fs.readdirSync(src, { withFileTypes: true })) {
    const s = path.join(src, entry.name);
    const d = path.join(dest, entry.name);
    if (entry.isDirectory()) {
      copyDir(s, d);
    } else {
      fs.copyFileSync(s, d);
    }
  }
}

function installSkeleton(targetDir) {
  const skel = path.join(PKG_ROOT, "skeleton");
  if (!fs.existsSync(skel)) return;
  copyDir(skel, targetDir);
}

/* ---- per-platform install ---- */

function installTo(platform) {
  const { label, target } = PLATFORMS[platform];
  const existed = fs.existsSync(target);

  console.log(existed
    ? `[coding-wisdom] ${label}: 已检测到 ${target}，更新中 (保留 inbox/ references/)...`
    : `[coding-wisdom] ${label}: 安装到 ${target} ...`);

  ensureDir(target);

  for (const f of DIST_FILES) {
    const src = path.join(PKG_ROOT, f);
    if (fs.existsSync(src)) fs.copyFileSync(src, path.join(target, f));
  }

  for (const d of DIST_DIRS) {
    copyDir(path.join(PKG_ROOT, d), path.join(target, d));
  }

  if (!existed) {
    installSkeleton(target);
  }

  console.log(`[coding-wisdom] ${label}: 完成。`);
}

/* ---- detection ---- */

function detectPlatforms() {
  const detected = [];
  for (const [key, cfg] of Object.entries(PLATFORMS)) {
    if (fs.existsSync(cfg.dir)) detected.push(key);
  }
  return detected;
}

/* ---- main ---- */

function install(targets) {
  for (const t of targets) {
    if (!PLATFORMS[t]) {
      console.error(`[coding-wisdom] 未知目标: ${t} (可选: claude, codex, both)`);
      process.exit(1);
    }
    installTo(t);
  }

  const labels = targets.map(t => PLATFORMS[t].label).join(" + ");
  console.log(`[coding-wisdom] 全部完成。重启 ${labels} 生效。`);
}

function uninstall() {
  for (const [key, cfg] of Object.entries(PLATFORMS)) {
    if (!fs.existsSync(cfg.target)) continue;
    console.log(`[coding-wisdom] ${cfg.label}: 卸载 ${cfg.target}`);
    console.log(`[coding-wisdom] ${cfg.label}: 注意 — inbox/ references/ 中的个人数据将被删除。`);
    fs.rmSync(cfg.target, { recursive: true, force: true });
  }
  console.log("[coding-wisdom] 已从所有平台卸载。");
}

/* ---- entry ---- */

const args = process.argv.slice(2);
const cmd  = args[0];

if (cmd === "--uninstall" || cmd === "-u") {
  uninstall();
  process.exit(0);
}

// 解析 --target flag
let targets;
const targetIdx = args.indexOf("--target");
if (targetIdx !== -1 && args[targetIdx + 1]) {
  const val = args[targetIdx + 1];
  targets = val === "both" ? ["claude", "codex"] : [val];
} else {
  targets = detectPlatforms();
  if (targets.length === 0) {
    console.error("[coding-wisdom] 未检测到 Claude Code (~/.claude/) 或 Codex CLI (~/.codex/)。");
    console.error("[coding-wisdom] 使用 --target claude|codex|both 手动指定。");
    process.exit(1);
  }
}

install(targets);
