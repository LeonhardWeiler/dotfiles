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

  // A thumbnail link's own text is the duration badge, usually with the
  // screen-reader spelling of the same number behind it ("13:07 13 minutes,
  // 7 seconds"). Nothing that starts with a duration is a title, in any
  // language - which is why this matches the digits and not the words.
  const DURATION = /^\d{1,2}(?::\d{2}){1,2}\b/;
  const plausible = (s) => s !== "" && !DURATION.test(s);

  // The video a link points at, however it is spelled. Two links with the same
  // id are two links to the same video, so a title found on one is the title
  // for the other - that is what makes it safe to read the title off the card
  // instead of off the link the pointer happens to sit on.
  const videoId = (href) => {
    try {
      const u = new URL(href, location.href);
      if (u.hostname.endsWith("youtu.be")) {
        return u.pathname.slice(1).split("/")[0] || "";
      }
      const v = u.searchParams.get("v");
      if (v) return v;
      const m = u.pathname.match(/^\/(?:shorts|embed|live|v)\/([^/?#]+)/);
      return m ? m[1] : "";
    } catch {
      return "";
    }
  };

  // Everything a thumbnail link carries besides the title: the duration badge
  // and its screen-reader text, "Watch later", the resume bar, icons, and the
  // whole chrome of the inline preview player that starts inside the link on
  // hover ("Tap to unmute", "Shopping", "If playback doesn't begin shortly…").
  // All of it is inside the <a>, so plain textContent picks it up - this is
  // why the title used to come out as "13:07" or as that wall of button text.
  const isNoise = (el) => {
    const tag = el.tagName.toLowerCase();
    if (
      tag.startsWith("ytd-thumbnail-overlay") ||
      tag === "svg" ||
      tag === "yt-icon" ||
      tag === "style" ||
      tag === "script"
    ) {
      return true;
    }
    // `ytp-` is the player's own namespace: its title link keeps the title in
    // a text node of its own, so dropping every ytp- element below the node
    // being read loses the buttons and keeps the title.
    return /badge|overlay|time-status|progress|ytp-/.test(
      el.getAttribute("class") || ""
    );
  };

  const visibleText = (el) => {
    const copy = el.cloneNode(true);
    for (const node of copy.querySelectorAll("*")) if (isNoise(node)) node.remove();
    return clean(copy.textContent);
  };

  // One video and everything shown about it - its thumbnail link and its title
  // link are siblings inside one of these.
  const CARDS = [
    "ytd-rich-item-renderer",
    "ytd-rich-grid-media",
    "ytd-video-renderer",
    "ytd-grid-video-renderer",
    "ytd-compact-video-renderer",
    "ytd-playlist-video-renderer",
    "ytd-playlist-panel-video-renderer",
    "ytd-reel-item-renderer",
    "ytd-movie-renderer",
    "yt-lockup-view-model",
    "ytm-shorts-lockup-view-model",
  ].join(", ");

  const TITLES = [
    "a#video-title-link",
    "#video-title",
    ".yt-lockup-metadata-view-model__title",
    "h3 a[title]",
    "h3 a",
    "h3",
  ];

  // Walks up from the hovered link looking for the title of the same video:
  // first another link to that video id (grids pair a thumbnail link with a
  // title link), then the title element of the enclosing card. Bounded to six
  // levels so this stays inside the card and never scans a whole grid.
  const titleNear = (a) => {
    const id = videoId(a.href);
    let el = a.parentElement;

    for (let depth = 0; el && depth < 6 && el !== document.body; depth++) {
      if (id) {
        for (const link of el.querySelectorAll("a[href]")) {
          if (link === a || videoId(link.href) !== id) continue;
          const t = clean(link.getAttribute("title")) || visibleText(link);
          if (plausible(t)) return t;
        }
      }

      if (el.matches(CARDS)) {
        for (const sel of TITLES) {
          const node = el.querySelector(sel);
          if (!node) continue;
          const t = clean(node.getAttribute("title")) || visibleText(node);
          if (plausible(t)) return t;
        }
      }

      el = el.parentElement;
    }

    return "";
  };

  // `title` first: YouTube's title links carry the exact title in it. Then the
  // card, which is what a bare thumbnail link needs. The link's own text comes
  // after that (it is the natural title off YouTube), then the thumbnail alt,
  // and only last `aria-label` - it pads the title with channel, views, age
  // and duration, so it is better than nothing and worse than everything else.
  const linkTitle = (a) => {
    const own = clean(a.getAttribute("title"));
    if (plausible(own)) return own;

    const near = titleNear(a);
    if (near) return near;

    const text = visibleText(a);
    if (plausible(text)) return text;

    const alt = clean(a.querySelector("img[alt]")?.getAttribute("alt"));
    if (plausible(alt)) return alt;

    const label = clean(a.getAttribute("aria-label"));
    return plausible(label) ? label : "";
  };

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
