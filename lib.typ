// Requirement to set up sidenotes
#import "@preview/drafting:0.2.2": *
// For header numbering. Can also be used for list/page numbers.
#import "@preview/numbly:0.1.0": numbly
// Code block formatting
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.8": *
// Selective page header generation
#import "@preview/hydra:0.6.1": hydra, anchor

// TODO: TBD how useful this is for now or if othe rpackage to be used.
#import "@preview/unify:0.7.1": unit, num, qty, numrange, qtyrange

// Boxes!
#import "boxes.typ": *

#let sans-fonts = (
  "Gillius ADF",
  "IBM Plex Sans",
  "Atkinson Hyperlegible",

  "TeX Gyre Heros",
  "Noto Sans",
  "Helvetica",
)

#let serif-fonts = (
  "fbb",
  "TeX Gyre Pagella",
  "New Computer Modern",

  "ETBembo",
  "Libertinus Serif",
  
  "Lucida Bright",
)

#let code-font = (
  "Luxi Mono",
  "Lilex",
  "DejaVu Sans Mono"
)

/*
  Fonts, TBD:
    Digit/incrementing font for Notes
    Code/Raw inline and block font(s)
    Math font of choice
    Blocky numericals for 'large' numbers and some such?
*/

#let fullwidth = state("fullwidth", false)

#let notecounter = counter("notecounter")

/* 
  Sidenotes

  Display content in the right margin with the `note()` function.
  If `full` template option is set to `true`, becomes a footnote instead.
    - `dy: auto | length = auto` Vertical offset.
    - `numbered: bool = true` Display a footnote-style number in text and in the note
    - `body: content` Required. The content of the sidenote.
*/
#let note(dy: auto, numbered: true, body) = context {
  in-note.update(true)
  if fullwidth.get() and not numbered {
    footnote(body, numbering: _ => [])
    counter(footnote).update(n => n - 1)
  } else if fullwidth.get() {
    footnote(body)
  } else {
    if numbered {
      h(0.1em)
      notecounter.step()  
      context super(notecounter.display())
    }
    text(size: 8pt, font: sans-fonts, margin-note(
      if numbered {
        text(size: 11pt, {
          context super(notecounter.display())
          h(0.15em)
        })
        body
      } else {
        body
      },
      dy: dy,
    ))
  }
  in-note.update(false)
}

/* 
  Sidenote Citation

  Display a short citation in the right margin with the `sidecite()` function.
  If `full` template option is set to `true`, becomes a footnote instead.
  Only displayed when `bibliography` is defined.
    - `dy: auto | length = auto` Vertical offset.
    - `form: none | str = "normal"` Form of in-text citation.
    - `style: [csl] | auto | bytes | str = auto` Citation style.
    - `supplement: content | none = none` Citation supplement.
    - `key: cite-label` Required. The citation key.
*/
#let sidecite(dy: auto, form: "normal", style: auto, supplement: none, key) = context {
  show cite: it => {
    show regex("\[\d\]"): set text(blue)
    it
  }
  let elems = query(bibliography)
  if elems.len() > 0 {
    cite(key, form: form, style: style, supplement: supplement)
    note(
      cite(key, form: "full"),
      dy: dy,
      numbered: false,
    )
  }
}

/*
  Wideblock

  Wrapped content will span the full width of the page.
    - `content: content | none` Required. The content to span the full width.
*/
#let wideblock(content) = context {
  if fullwidth.get() {
    block(width: 100%, content)
  } else {
    block(width: 100% + 2in, content)
  }
}

/*  From https://typst.app/universe/package/accelerated-jacow
    Capitalize major words, e.g. "This is a Word-Caps Heading"
    Heuristic until we have https://github.com/typst/typst/issues/1707
*/
#let wordcaps(body) = {
  if body.has("text") {
    let txt = body.text //lower(body.text)
    let words = txt.matches(regex("^()(\\w+)")) // first word
    words += txt.matches(regex("([.:;?!]\s+)(\\w+)")) // words after punctuation
    words += txt.matches(regex("()(\\w{4,})")) // words with 4+ letters
    for m in words {
      let (pre, word) = m.captures
      word = upper(word.at(0)) + word.slice(1)
      txt = txt.slice(0, m.start) + pre + word + txt.slice(m.end)
    }
    txt
  } else if body.has("children") {
    body.children.map(it => wordcaps(it)).join()
  } else {
    body
  }
}
// To preserve numbering when applying wordcaps to headers
#let wordcaps-header(header) = {
  if header.has("numbering") and header.numbering != none {
    //counter(heading).display(header.numbering)
    numbering(header.numbering, ..counter(heading).at(header.location()))
    h(0.3em)
  }
  wordcaps(header.body)
}
#let wordcaps-outline(entry) = {
  if entry.has("numbering") and entry.numbering != none {
    numbering(entry.numbering, ..counter(heading).at(entry.location()))
    h(0.3em)
  }
  wordcaps(entry.inner())
}

/* Table in jacow style from same template
    - spec (str): Column alignment specification string such as "ccr"
    - header (alignment, none): header location (top and/or bottom) or none
    - contents: table contents
*/
#let jacow-table(spec, header: top, ..contents) = {
  spec = spec.codepoints()
  if header == none { header = alignment.center }
  let args = (
    columns: spec.len(),
    align: spec.map(i => (a: auto, c: center, l: left, r: right).at(i)),
    stroke: (x, y) => {
      if y == 0 {(top: 0.08em, bottom: if header.y == top {0.05em})}
      else if y > 1 {(top: 0em, bottom: 0.08em)}
    },
  )
  for (key, value) in contents.named() {
    args.insert(key, value)
  }

  show table.cell.where(y: 0): it => if header.y == top {strong(it)} else {it}
  show table.cell.where(x: 0): it => if header.x == left {strong(it)} else {it}

  table(
    ..args,
    ..contents.pos(),
  )
}

// **
// ** Main Template
// **
#let template(
  title: none,
  authors: none,
  date: datetime.today().display("[day] [month repr:long] [year]"),
  abstract: none,
  toc: true,
  full: false,
  header: true,
  footer: true,
  header-content: none,
  footer-content: none,
  draft: false,
  bib: none,
  doc,
) = {

  // Metadata
  if authors != none {
    set document(title: title, author: authors)
  } else {
    set document(title: title)
  }

  // Update full width state used by note and notecite functions
  fullwidth.update(full)

  // Full width or with right margin
  let right-margin = {
    if full { 0.7in } else { 3in }
  }
  let left-margin = 0.7in
  let margin-diff = right-margin - left-margin
  let wideblock(content) = block(width: 100% + margin-diff, content)

// **
// ** Main Formatting
// **
  // Just a subtle lightness to decrease the harsh contrast
  set text(fill:luma(30))

  // Body text
  set text(
    font: serif-fonts,
    style: "normal",
    weight: "regular",
    hyphenate: true,
    size: 11pt
  )
  
  show ref: set text(blue)
  show link: set text(blue)

  set par(justify: true, spacing: 1.5em) // TODO: Double check spacing and leading

  set enum(indent: 1em)
  set list(indent: 1em)
  show enum: set par(spacing: 1.25em)
  show list: set par(spacing: 1.25em)

  // Section headings
  // Using a trick from: https://github.com/flaribbit/numbly/issues/5
  set heading(numbering: numbly(
  (..)=>h(-0.3em),  // use {level:format} to specify the format
  "{1}.{2}",        // if format is not specified, arabic numbers will be used
  (..)=>h(-0.3em)   // No numbering on level 3's
  ))
  show heading.where(level: 1): it => { 
    set text(size: 15pt, weight: "bold", hyphenate: false)
    block(above: 1.2em, below: 0.85em,
      wordcaps-header(it)
    )
  }
  show heading.where(level: 2): it => { 
    set text(size: 14pt, weight: "regular", style: "italic", hyphenate: false)
    block(above: 1.4em, below: 0.7em,
      wordcaps-header(it)
    )
  }
  show heading.where(level: 3): it => {
      set text(size: 10pt, weight: "bold", style:"italic")
      block(above: 1.9em, below: 0.8em, sticky: true,
        underline(h(0.3em)+wordcaps-header(it), offset: 0.16em, extent: 0.3em)
      )
  }
  
  // TODO: Improve outline formatting. :)
  show outline.entry.where(level: 1): set outline.entry(fill: none)
  show outline.entry.where(level: 1): set text(weight: "bold")

  // Make sure outline usees title case as well.
  show outline.entry: it => {
    show link: set text(fill:luma(30)) // TODO: Cleanup refs. 
    link(
      it.element.location(),
      it.indented(it.prefix(), wordcaps-outline(it)),
    )
  }
  
  //show heading.where(level: 1): set block(above: 1.2em, below: 0.85em)
  //show heading.where(level: 2): set block(above: 1.4em, below: 0.7em)
  //show heading.where(level: 3): set block(above: 1.8em, below: 0.7em)

// **
// ** Specialty
// **
  show raw: set text(font: code-font)
  show raw: set block(above: 0.85em, below: 1.35em)

  // Raw: Odd inline size to minimize disruptions.
  show raw.where(block: false): set text(size: 8.7pt)
  show raw.where(block: false): box.with(
    fill: code-bg,
    inset: (x: 3pt, y: 0pt),
    outset: (y: 3pt),
    radius: 2pt,
  )
  show raw.where(block: true): set text(size: 7.6pt)
  /*show raw.where(block: false): it => {
    highlight(
      fill:code-bg,
      top-edge: "ascender",
      bottom-edge: "bounds",
      extent:1pt, it)
  }*/
  /*show raw.where(block: true): it => {
    block(
      fill: code-bg,
      width:100%,
      inset: 10pt,
      radius: 4pt,
      stroke: 0.1pt + code-border,
      it,
    )
  }*/ 
  // Codly
  show: codly-init.with()
  codly(
    languages: codly-languages,
    stroke: 0.2pt + code-border,
    radius: 4pt,
    number-format: (number) => {
      text(luma(65%), size:7pt, [#h(0.7em)#number])
    },
    inset: (left:0em, rest:0.29em),
    zebra-fill: z-bg,
    fill: code-bg,
    lang-format: none, // Don't need language atm.
    header-transform: (x)=>{
      set text(font: sans-fonts, size: 9.7pt, weight: "bold")
      h(0.5em)
      x
    },
    //header-cell-args: (align: center, ),
    footer-transform: (x)=>{
      set text(font: sans-fonts, size: 8.7pt, style:"italic")
      v(0.5em)
      x
    },
    footer-cell-args: (align: center, )
  )

  // Equation and figure references
  set math.equation(numbering: "(1)", supplement: none, number-align: bottom)
  show ref: it => {
    if it.element != none and it.element.func() == math.equation {
      link(it.target)[(#it)]
    } else if it.element != none and it.element.func() == figure {
      link(it.target)[#it.element.numbering]
    } else {
      it
    }
  }

  show figure.caption: set text(font: sans-fonts)

  // Tables
  show figure.where(kind: table): set figure.caption(position: top)
  
// **
// ** Page, header, footer
// **
  set page(
    paper: "a4",
    margin: (
      left: left-margin,
      right: right-margin,
      top: 1in,
      bottom: 0.75in,
    ),
    header: context { 
      if here().page() == 1 { // Skip Header on first page
        none
      } else if header and header-content != none {
        header-content
      } else if header {
        set text(size: 8pt)
        wideblock(
        hydra(
          2,
          // Filters out TOC's/outlines
          prev-filter: (ctx, candidates) => candidates.primary.prev.outlined == true,
          // Displays header
          display: (ctx, candidate) => {
            grid(
              columns: (auto, 1fr),
              column-gutter: 3em,
              align: (left+top, right+top),
              {
                set par(justify: false)
                set text(size: 12pt, style: "italic")
                wordcaps-header(candidate)
              },
              {
                set text(size: 12pt)
                wordcaps-header(query(heading.where(level: 1).before(here())).last())
              }
            )
            v(-0.25em)
            line(length: 100%)
          },
        )
        )
        anchor()
      } else { none } 
    },
    footer: context { 
      if footer and footer-content != none {
        footer-content
      } else if footer {
        set text(size: 8pt)
        wideblock({
          set align(right)
          emph(counter(page).display("1/1", both: true))
        })
      } else { none } 
    },
    background: if draft {rotate(45deg,text(font:sans-fonts,size:200pt, fill: rgb("#fff4f4"))[DRAFT])},
    footer-descent: 55%,
  )

  let titleblock(title, authors, date, abstract) = {
    set text(
      hyphenate: false,
      font: sans-fonts
    )
    wideblock([
      #set align(center)
      #if title != none { [#text(14pt, [*#title*]) \ \ ] }
      #if authors != none {
        if type(authors) == array and authors.len() == 2 {
          [#authors.join(", ", last: " and ") \ ]
        } else if type(authors) == array {
          [#authors.join(", ", last: ", and ") \ ]
        } else if type(authors) == str {
          [#authors \ ]
        }
      }
      #if date != none { [#date \ ] }
      #if abstract != none { [\ #abstract \ ] }
    ])
  }

// **
// ** Layout
// **
  // Title block
  titleblock(title, authors, date, abstract)
  v(1.5em)

  // Set up SideNotes using the drafting package
  // The *1.2 is to add some clearance between text body and notes
  // Use #place-margin-rects[] to verify, or #margin-lines(stroke: rgb("#d42424"))
  set-page-properties(
    margin-right: right-margin - left-margin*1.2,
    margin-left: left-margin*1.2
  )
  set-margin-note-defaults(
    stroke: none,
    side: right,
  )

  // TODO: Figure out how to align notes relative to another line on the left side
  // For some reason if this were to match header 1.2em offset, would be too low....
  if toc and not full { note(dy: 0.75em, numbered: false)[#outline(depth: 2)] }

  doc

  // TODO: Improve bibliography layout and font choice for it.
  set cite(style: "american-physics-society")
  show bibliography: set par(spacing: 1em)
  if bib != none { wideblock(bib) }
}
