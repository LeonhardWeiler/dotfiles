#import "@preview/touying:0.6.0": *

/// Default slide function for the presentation.
///
/// - config (dictionary): is the configuration of the slide. Use `config-xxx` to set individual configurations for the slide. To apply multiple configurations, use `utils.merge-dicts` to combine them.
///
/// - repeat (int, auto): is the number of subslides. The default is `auto`, allowing touying to automatically calculate the number of subslides. The `repeat` argument is required when using `#slide(repeat: 3, self => [ .. ])` style code to create a slide, as touying cannot automatically detect callback-style `uncover` and `only`.
///
/// - setting (dictionary): is the setting of the slide, which can be used to apply set/show rules for the slide.
///
/// - composer (array, function): is the layout composer of the slide, allowing you to define the slide layout.
///
///   For example, `#slide(composer: (1fr, 2fr, 1fr))[A][B][C]` to split the slide into three parts. The first and the last parts will take 1/4 of the slide, and the second part will take 1/2 of the slide.
///
///   If you pass a non-function value like `(1fr, 2fr, 1fr)`, it will be assumed to be the first argument of the `components.side-by-side` function.
///
///   The `components.side-by-side` function is a simple wrapper of the `grid` function. It means you can use the `grid.cell(colspan: 2, ..)` to make the cell take 2 columns.
///
///   For example, `#slide(composer: 2)[A][B][#grid.cell(colspan: 2)[Footer]]` will make the `Footer` cell take 2 columns.
///
///   If you want to customize the composer, you can pass a function to the `composer` argument. The function should receive the contents of the slide and return the content of the slide, like `#slide(composer: grid.with(columns: 2))[A][B]`.
///
/// - bodies (arguments): is the contents of the slide. You can call the `slide` function with syntax like `#slide[A][B][C]` to create a slide.
#let slide(
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  align: auto,
  ..bodies,
) = touying-slide-wrapper(self => {
    if align != auto {
    self.store.align = align
  }
    let header(self) = {
      set std.align(top)
      grid(
        rows: (auto, auto),
        row-gutter: 3mm,
        if self.store.progress-bar {
        components.progress-bar(
          height: 3pt,
          self.colors.primary,
          white,
        )
      },
        block(
          inset: (x: .5em),
          text(
            fill: self.colors.primary,
            weight: "bold",
            size: .7em,
            utils.call-or-display(self, self.store.header),
          ),
        ),
      )
    }
    let footer(self) = {
      set std.align(center + bottom)
      set text(size: .7em)
      {
      let cell(..args, it) = components.cell(
        ..args,
        inset: 1mm,
        std.align(horizon, text(fill: self.colors.secondary, it)),
      )
      show: block.with(width: 100%, height: auto)
      grid(
        columns: self.store.footer-columns,
        rows: 1.5em,
        cell(utils.call-or-display(
          self,
          self.store.footer-a,
        )),
        cell(utils.call-or-display(
          self,
          self.store.footer-b,
        )),
        cell(utils.call-or-display(
          self,
          self.store.footer-c,
        )),
      )
    }
    }
    let self = utils.merge-dicts(
      self,
      config-page(
        header: header,
        footer: footer,
      ),
    )
    let new-setting = body => {
      show: std.align.with(self.store.align)
      show: setting
      body
    }
    touying-slide(
      self: self,
      config: config,
      repeat: repeat,
      setting: new-setting,
      composer: composer,
      ..bodies,
    )
  })


/// Title slide for the presentation. You should update the information in the `config-info` function. You can also pass the information directly to the `title-slide` function.
///
/// Example:
///
/// ```typst
/// #show: school-theme.with(
///   config-info(
///     title: [Title],
///     logo: emoji.school,
///   ),
/// )
///
/// #title-slide(subtitle: [Subtitle])
/// ```
///
/// - config (dictionary): is the configuration of the slide. Use `config-xxx` to set individual configurations for the slide. To apply multiple configurations, use `utils.merge-dicts` to combine them.
///
/// - extra (string, none): is the extra information for the slide. This can be passed to the `title-slide` function to display additional information on the title slide.
#let title-slide(
  config: (:),
  extra: none,
  ..args,
) = touying-slide-wrapper(self => {
    self = utils.merge-dicts(
      self,
      config,
      config-common(freeze-slide-counter: true),
    )
    let info = self.info + args.named()
    info.authors = {
    let authors = if "authors" in info {
      info.authors
    } else {
      info.author
    }
    if type(authors) == array {
    authors
  } else {
    (authors,)
  }
  }
    let body = {
      if info.logo != none {
      place(right, text(fill: self.colors.primary, info.logo))
    }
      std.align(
        center + horizon,
        {
        block(
          inset: 0em,
          breakable: false,
          {
          text(size: 2em, fill: self.colors.primary, strong(info.title))
          if info.subtitle != none {
          parbreak()
          text(size: 1.2em, fill: self.colors.primary, info.subtitle)
        }
        },
        )
        set text(size: .8em)
        grid(
          columns: (1fr,) * calc.min(info.authors.len(), 3),
          column-gutter: 1em,
          row-gutter: 1em,
          ..info.authors.map(author => text(
            fill: self.colors.neutral-darkest,
            author,
          ))
        )
        v(1em)
        if info.institution != none {
        parbreak()
        text(size: .9em, info.institution)
      }
        if info.date != none {
        parbreak()
        text(size: .8em, utils.display-info-date(self))
      }
      },
      )
    }
    touying-slide(self: self, body)
  })


/// New section slide for the presentation. You can update it by updating the `new-section-slide-fn` argument for `config-common` function.
///
/// Example: `config-common(new-section-slide-fn: new-section-slide.with(numbered: false))`
///
/// - config (dictionary): is the configuration of the slide. Use `config-xxx` to set individual configurations for the slide. To apply multiple configurations, use `utils.merge-dicts` to combine them.
///
/// - level (int, none): is the level of the heading.
///
/// - numbered (boolean): is whether the heading is numbered.
///
/// - body (auto): is the body of the section. This will be passed automatically by Touying.
#let new-section-slide(
  config: (:),
  level: 1,
  numbered: true,
  body,
) = touying-slide-wrapper(self => {
    let slide-body = {
      set std.align(horizon)
      show: pad.with(20%)
      set text(size: 1.5em, fill: self.colors.primary, weight: "bold")
      stack(
        dir: ttb,
        spacing: .65em,
        utils.display-current-heading(level: level, numbered: numbered),
        block(
          height: 2pt,
          width: 100%,
          spacing: 0pt,
          components.progress-bar(
            height: 3pt,
            self.colors.primary,
            self.colors.tertiary,
          ),
        ),
      )
      body
    }
    touying-slide(self: self, config: config, slide-body)
  })

/// Touying school theme.
///
/// Example:
///
/// ```typst
/// #show: school-theme.with(aspect-ratio: "16-9", config-colors(primary: blue))`
/// ```
///
/// The default colors:
///
/// ```typ
/// config-colors(
///   primary: rgb("#04364A"),
///   secondary: rgb("#176B87"),
///   tertiary: rgb("#448C95"),
///   neutral-lightest: rgb("#ffffff"),
///   neutral-darkest: rgb("#000000"),
/// )
/// ```
///
/// - aspect-ratio (string): is the aspect ratio of the slides. Default is `16-9`.
///
/// - align (alignment): is the alignment of the slides. Default is `top`.
///
/// - progress-bar (boolean): is whether to show the progress bar. Default is `true`.
///
/// - header (content, function): is the header of the slides. Default is `utils.display-current-heading(level: 2)`.
///
/// - header-right (content, function): is the right part of the header. Default is `self.info.logo`.
///
/// - footer-columns (tuple): is the columns of the footer. Default is `(25%, 1fr, 25%)`.
///
/// - footer-a (content, function): is the left part of the footer. Default is `self.info.author`.
///
/// - footer-b (content, function): is the middle part of the footer. Default is `self.info.short-title` or `self.info.title`.
///
/// - footer-c (content, function): is the right part of the footer. Default is `self => h(1fr) + utils.display-info-date(self) + h(1fr) + context utils.slide-counter.display() + " / " + utils.last-slide-number + h(1fr)`.
#let school-theme(
  aspect-ratio: "16-9",
  align: top,
  progress-bar: true,
  header: utils.display-current-heading(level: 2, style: auto),
  header-right: self => (
  box(utils.display-current-heading(level: 1)) + h(.3em) + self.info.logo
),
  footer-columns: (25%, 1fr, 25%),
  footer-a: self => self.info.author,
  footer-b: self => if self.info.short-title == auto {
  self.info.title
} else {
  self.info.short-title
},
  footer-c: self => {
  h(1fr)
  context utils.slide-counter.display() + " / " + utils.last-slide-number
  h(1fr)
},
  ..args,
  body,
) = {
  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      header-ascent: 0em,
      footer-descent: 0em,
      margin: (top: 2em, bottom: 1.25em, x: 2em),
    ),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: new-section-slide,
    ),
    config-methods(
      init: (self: none, body) => {
      set text(size: 18pt)
      show heading.where(level: 3): set text(fill: self.colors.primary)
      show heading.where(level: 4): set text(fill: self.colors.primary)

      body
    },
      alert: utils.alert-with-primary-color,
    ),
    config-colors(
      primary: rgb("#9c2a49"),
      secondary: rgb("#2b2237"),
      tertiary: rgb("#e9eef0"),
      neutral-lightest: rgb("#ffffff"),
      neutral-darkest: rgb("#000000"),
    ),
    // save the variables for later use
    config-store(
      align: align,
      progress-bar: progress-bar,
      header: header,
      header-right: header-right,
      footer-columns: footer-columns,
      footer-a: footer-a,
      footer-b: footer-b,
      footer-c: footer-c,
    ),
    ..args,
  )

  body
}
