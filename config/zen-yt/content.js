// SPDX-License-Identifier: ISC
// Copyright (C) 2026 The leonhardweiler/dotfiles Authors
//
// Runs on every page and in every frame. Its only job is to answer the one
// question the background page cannot answer on its own: which YouTube link is
// the mouse pointer sitting on right now?
//
// Only code inside the page sees the pointer, so the hover state is pushed to
// the background as it changes rather than pulled when the shortcut is hit -
// a request/response round trip would have to reach every frame and pick a
// winner among the answers.

"use strict";

(() => {
  const YT_HOST = /^(.*\.)?(youtube\.com|youtu\.be|youtube-nocookie\.com)$/;

  // The link the pointer is on, so mouseout can tell "left the link" from
  // "moved onto the title span inside the same link".
  let hovered = null;

  const isYouTube = (href) => {
    try {
      return YT_HOST.test(new URL(href, location.href).hostname);
    } catch {
      return false;
    }
  };

  // The nearest enclosing anchor that points at YouTube. Thumbnails nest
  // several elements below the <a>, so this walks up rather than looking at
  // the event target alone.
  const ytLink = (node) => {
    const el = node instanceof Element ? node : node?.parentElement;
    const a = el?.closest?.("a[href]");
    return a && isYouTube(a.href) ? a : null;
  };

  const clean = (s) => (s || "").replace(/\s+/g, " ").trim();

  // `title` first: on YouTube's own grids it holds the full video title, while
  // `aria-label` pads it with channel, age and duration ("… by X, 3 years ago,
  // 12 minutes"). The link text is the natural title everywhere else, and the
  // image alt is the last resort for a bare thumbnail link.
  const linkTitle = (a) =>
    clean(a.getAttribute("title")) ||
    clean(a.textContent) ||
    clean(a.getAttribute("aria-label")) ||
    clean(a.querySelector("img[alt]")?.getAttribute("alt")) ||
    "";

  const send = (msg) => {
    // The background page can be gone during shutdown; nothing here is worth
    // an error in the page console.
    browser.runtime.sendMessage(msg).catch(() => {});
  };

  const enter = (a) => {
    hovered = a;
    send({ type: "hover", url: a.href, title: linkTitle(a) });
  };

  const leave = () => {
    hovered = null;
    send({ type: "unhover" });
  };

  // Capture phase: YouTube stops a lot of pointer events on its way up.
  document.addEventListener(
    "mouseover",
    (e) => {
      const a = ytLink(e.target);
      if (a && a !== hovered) enter(a);
    },
    true
  );

  document.addEventListener(
    "mouseout",
    (e) => {
      if (!hovered) return;
      // Still inside the same anchor - the pointer only crossed an inner
      // element boundary.
      if (e.relatedTarget && ytLink(e.relatedTarget) === hovered) return;
      leave();
    },
    true
  );

  // Switching tabs hides the document without ever firing mouseout, so the
  // stale hover would outlive the pointer. Deliberately not `blur`: focus
  // moving to the address bar leaves the pointer exactly where it was, and
  // the shortcut works with the focus up there.
  document.addEventListener(
    "visibilitychange",
    () => document.hidden && hovered && leave(),
    true
  );
})();
