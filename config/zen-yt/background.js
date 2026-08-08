// SPDX-License-Identifier: ISC
// Copyright (C) 2026 The leonhardweiler/dotfiles Authors
//
// Holds the hover state reported by content.js and turns the two keyboard
// commands into one native message to `yt_save`, which does the writing and
// the on-screen feedback.
//
// Source of the link, in order:
//   1. the YouTube link under the mouse pointer (any page, any frame)
//   2. otherwise the YouTube page the active tab is on
//   3. otherwise nothing at all - no message, no flash, no error
//
// The background page is persistent on purpose: the hover arrives long before
// the keypress, and an event page may be suspended in between.

"use strict";

const HOST = "at.leo.yt_save";

const LISTS = {
  "save-remember": "remember",
  "save-watchlist": "watchlist",
};

// tab id -> { url, title, frameId }
const hovered = new Map();

const forget = (tabId) => hovered.delete(tabId);

browser.runtime.onMessage.addListener((msg, sender) => {
  const tabId = sender.tab?.id;
  if (tabId === undefined) return;

  if (msg.type === "hover") {
    hovered.set(tabId, {
      url: msg.url,
      title: msg.title,
      frameId: sender.frameId,
    });
  } else if (msg.type === "unhover") {
    // Only the frame that claimed the hover may drop it, otherwise a frame
    // the pointer never touched could clear a live hover.
    if (hovered.get(tabId)?.frameId === sender.frameId) forget(tabId);
  }
});

browser.tabs.onRemoved.addListener(forget);
browser.tabs.onActivated.addListener(({ previousTabId }) => {
  if (previousTabId !== undefined) forget(previousTabId);
});
browser.tabs.onUpdated.addListener((tabId, change) => {
  // A navigation invalidates every link that was on the old page.
  if (change.url) forget(tabId);
});

// ── the page the tab is on ──────────────────────────────────────────────────

// Everything on YouTube counts - videos, shorts, playlists, channels - except
// the pages that are pure navigation and have no link worth keeping.
const NOT_A_TARGET = /^\/(|results|feed\/.*)$/;

const pageUrl = (url) => {
  let u;
  try {
    u = new URL(url);
  } catch {
    return null;
  }
  if (!/^(.*\.)?(youtube\.com|youtu\.be|youtube-nocookie\.com)$/.test(u.hostname)) {
    return null;
  }
  if (u.hostname.endsWith("youtube.com") && NOT_A_TARGET.test(u.pathname)) {
    return null;
  }
  return url;
};

// Tab titles read "Video name - YouTube", with an unread-count prefix while a
// video plays in another tab.
const pageTitle = (title) =>
  (title || "")
    .replace(/^\(\d+\)\s*/, "")
    .replace(/\s*[-–]\s*YouTube\s*$/, "")
    .trim();

// ── commands ────────────────────────────────────────────────────────────────

browser.commands.onCommand.addListener(async (command) => {
  const list = LISTS[command];
  if (!list) return;

  const [tab] = await browser.tabs.query({ active: true, currentWindow: true });
  if (!tab) return;

  let target = hovered.get(tab.id);
  if (!target) {
    const url = pageUrl(tab.url);
    if (!url) return; // neither hovering nor on YouTube: stay quiet
    target = { url, title: pageTitle(tab.title) };
  }

  try {
    const reply = await browser.runtime.sendNativeMessage(HOST, {
      list,
      url: target.url,
      title: target.title || "",
    });
    if (reply?.status === "error") {
      console.error("yt-save:", reply.message);
    }
  } catch (e) {
    // The host itself failed to start or died - nothing flashed on screen,
    // so the console is the only place left to say so.
    console.error("yt-save: native host failed:", e);
  }
});
