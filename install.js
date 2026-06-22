#!/usr/bin/env node
"use strict";

/* ========================================================================
 * coding-wisdom installer — 零依赖，跨平台
 *
 * 把 skill 文件部署到 ~/.claude/skills/coding-wisdom/
 * 首次安装从 skeleton/ 创建 inbox + references 空骨架
 * 更新时保护用户数据，只覆盖 guides/templates/scripts/SKILL.md
 * ========================================================================*/

const fs   = require("fs");
const path = require("path");
const os   = require("os");

const SKILL_NAME = "coding-wisdom";
const PKG_ROOT   = __dirname;
const TARGET     = path.join(os.homedir(), ".claude", "skills", SKILL_NAME);

/* 每次安装都覆盖的目录 */
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

function installSkeleton() {
  const skel = path.join(PKG_ROOT, "skeleton");
  if (!fs.existsSync(skel)) return;
  copyDir(skel, TARGET);
}

/* ---- main ---- */

function install() {
  const existed = fs.existsSync(TARGET);
  console.log(existed
    ? `[coding-wisdom] 已检测到 ${TARGET}，更新中 (保留 inbox/ references/)...`
    : `[coding-wisdom] 安装到 ${TARGET} ...`);

  ensureDir(TARGET);

  for (const f of DIST_FILES) {
    const src = path.join(PKG_ROOT, f);
    if (fs.existsSync(src)) fs.copyFileSync(src, path.join(TARGET, f));
  }

  for (const d of DIST_DIRS) {
    copyDir(path.join(PKG_ROOT, d), path.join(TARGET, d));
  }

  if (!existed) {
    installSkeleton();
  }

  console.log("[coding-wisdom] 完成。重启 Claude Code 生效。");
}

function uninstall() {
  if (!fs.existsSync(TARGET)) {
    console.log(`[coding-wisdom] ${TARGET} 不存在，无需卸载。`);
    return;
  }
  console.log(`[coding-wisdom] 卸载：${TARGET}`);
  console.log("[coding-wisdom] 注意：inbox/ references/ 中的个人数据将被删除。");
  fs.rmSync(TARGET, { recursive: true, force: true });
  console.log("[coding-wisdom] 已卸载。");
}

/* ---- entry ---- */

const cmd = process.argv[2];
if (cmd === "--uninstall" || cmd === "-u") {
  uninstall();
} else {
  install();
}
