#!/usr/bin/env node
// session-state.mjs — per-repo session state for pair-with-codex.
// Keyed by sha1 of the git root absolute path. No external dependencies.

import { createHash } from "node:crypto";
import { readFileSync, writeFileSync, renameSync, mkdirSync, existsSync, readdirSync, unlinkSync } from "node:fs";
import { homedir } from "node:os";
import { join, resolve } from "node:path";

const BASE_DIR = join(homedir(), ".claude", "pair-with-codex");
const SESSIONS_DIR = join(BASE_DIR, "sessions");
const ARCHIVE_DIR = join(SESSIONS_DIR, "archive");

function ensureDirs() {
  mkdirSync(SESSIONS_DIR, { recursive: true });
  mkdirSync(ARCHIVE_DIR, { recursive: true });
}

function hashPath(repoPath) {
  const normalized = resolve(repoPath);
  return createHash("sha1").update(normalized).digest("hex");
}

function sessionFile(repoPath) {
  return join(SESSIONS_DIR, `${hashPath(repoPath)}.json`);
}

function readState(repoPath) {
  const file = sessionFile(repoPath);
  if (!existsSync(file)) return null;
  try {
    return JSON.parse(readFileSync(file, "utf8"));
  } catch (err) {
    process.stderr.write(`warning: malformed state file ${file}: ${err.message}\n`);
    return null;
  }
}

function writeStateAtomic(repoPath, state) {
  ensureDirs();
  const file = sessionFile(repoPath);
  const tmp = `${file}.tmp`;
  writeFileSync(tmp, JSON.stringify(state, null, 2));
  renameSync(tmp, file);
}

function mergeState(current, patch) {
  if (current === null) return patch;
  return { ...current, ...patch, updated_at: new Date().toISOString() };
}

function archiveState(repoPath) {
  ensureDirs();
  const file = sessionFile(repoPath);
  if (!existsSync(file)) return null;
  const timestamp = new Date().toISOString().replace(/[:.]/g, "-");
  const dest = join(ARCHIVE_DIR, `${timestamp}-${hashPath(repoPath)}.json`);
  renameSync(file, dest);
  return dest;
}

function clearState(repoPath) {
  const file = sessionFile(repoPath);
  if (existsSync(file)) unlinkSync(file);
}

function listSessions() {
  if (!existsSync(SESSIONS_DIR)) return [];
  return readdirSync(SESSIONS_DIR)
    .filter((name) => name.endsWith(".json"))
    .map((name) => {
      try {
        const content = JSON.parse(readFileSync(join(SESSIONS_DIR, name), "utf8"));
        return {
          file: name,
          repo_path: content.repo_path,
          phase: content.phase,
          task_description: content.task_description,
          updated_at: content.updated_at,
        };
      } catch {
        return { file: name, error: "unreadable" };
      }
    });
}

function usage() {
  process.stderr.write(
    "usage:\n" +
    "  session-state.mjs get <repo-path>\n" +
    "  session-state.mjs set <repo-path> <json>\n" +
    "  session-state.mjs update <repo-path> <json-patch>\n" +
    "  session-state.mjs clear <repo-path>\n" +
    "  session-state.mjs archive <repo-path>\n" +
    "  session-state.mjs list\n" +
    "  session-state.mjs hash <repo-path>\n"
  );
}

function main(argv) {
  const [subcmd, ...rest] = argv;
  switch (subcmd) {
    case "get": {
      const state = readState(rest[0]);
      process.stdout.write(state ? JSON.stringify(state, null, 2) : "{}");
      process.stdout.write("\n");
      return 0;
    }
    case "set": {
      if (rest.length < 2) {
        process.stderr.write("error: set requires <repo-path> and <json>\n");
        return 1;
      }
      let state;
      try {
        state = JSON.parse(rest[1]);
      } catch (err) {
        process.stderr.write(`error: invalid JSON: ${err.message}\n`);
        return 1;
      }
      writeStateAtomic(rest[0], state);
      return 0;
    }
    case "update": {
      if (rest.length < 2) {
        process.stderr.write("error: update requires <repo-path> and <json-patch>\n");
        return 1;
      }
      let patch;
      try {
        patch = JSON.parse(rest[1]);
      } catch (err) {
        process.stderr.write(`error: invalid JSON: ${err.message}\n`);
        return 1;
      }
      const current = readState(rest[0]);
      writeStateAtomic(rest[0], mergeState(current, patch));
      return 0;
    }
    case "clear":
      clearState(rest[0]);
      return 0;
    case "archive": {
      const dest = archiveState(rest[0]);
      if (dest) process.stdout.write(`${dest}\n`);
      return 0;
    }
    case "list": {
      process.stdout.write(JSON.stringify(listSessions(), null, 2));
      process.stdout.write("\n");
      return 0;
    }
    case "hash":
      process.stdout.write(`${hashPath(rest[0])}\n`);
      return 0;
    default:
      usage();
      return 1;
  }
}

process.exit(main(process.argv.slice(2)));
