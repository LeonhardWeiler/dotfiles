## 2 · Maintainability & structure

`install` is ~700 lines in one file — the point where splitting starts to pay off.

- [ ] `[L]` Split `install` into sourced modules and keep `install` as a thin
      (~120-line) entry point. Suggested layout:
      `setup/{parser,links,steps,systemd,output,validate}.sh`, sourced at the top;
      `install` mostly does `parse_args → load_links → case "$CMD" in …`.
- [ ] `[M]` Introduce `prepare_target()` returning source/target/root, to remove
      the duplicated `expand_target` + `needs_root` logic in
      `link_one`/`unlink_one`/`status_one`/`clean_one`.
- [ ] `[M]` Clean up unneccesery code or overengeneered code. Make the code not more than it needs to be
