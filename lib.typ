// For header numbering. Can also be used for list/page numbers.
#import "@preview/numbly:0.1.0": numbly
// Code block formatting
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.8": *
// Selective page header generation
#import "@preview/hydra:0.6.1": hydra, anchor
// TODO: TBD how useful this is for now or if othe rpackage to be used.
#import "@preview/unify:0.7.1": unit, num, qty, numrange, qtyrange

#import "constants.typ": *
#import "boxes.typ": *
#import "funcs.typ": *

// **
// ** Main Template
// **
#let template(
  title: none,
  authors: none,
  date: datetime.today().display("[day] [month repr:long] [year]"),
  abstract: none,
  toc: true,
  //full: true,
  header: true,
  footer: true,
  draft: false,
  doc,
) = {

  // Metadata
  if authors != none {
    set document(title: title, author: authors)
  } else {
    set document(title: title)
  }

  // TODO: No simple/easy way of conditional updates of right-margin
  // Depending on 'full'....for now just not have it.
  let full = false
  
  // Update full width state used by note and notecite functions
  fullwidth.update(full)

// **
// ** Main Formatting
// **
  // Just a subtle lightness to decrease the harsh contrast
  set text(fill: txt-default)

  // Body text
  set text(
    font: serif-fonts,
    style: "normal",
    weight: "regular",
    hyphenate: true,
    size: 11pt
  )
  
  show ref: set text(link-color)
  show link: set text(link-color)

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
    show link: set text(fill:txt-default)
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

  // TODO: Needs to be aware if in note or not, and adjust sizing/etc.
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
      text(code-ruler-txt, size:7pt, [#h(0.7em)#number])
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
      if header {
        set text(size: 8pt)
        wideblock( //border: 1pt,
        hydra( // Bottom is ~0.25in from main text
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
            move(dy: -0.25em, line(length: 100%))
          },
        )
        )
        anchor()
      } else { none } 
    },
    footer: context { 
      if footer {
        set text(size: 8pt)
        wideblock({
          set align(right)
          emph(counter(page).display("1/1", both: true))
        })
      } else { none } 
    },
    background: if draft {rotate(45deg,text(font:sans-fonts,size:200pt, fill: draft-bg)[DRAFT])},
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
  context {
      if here().page() == 3 { // Skip Header on first page
        none
        "tsdffsdfdfext"
      }
  }

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

  pagebreak()
  show bibliography: it =>{
    show heading: set align(center) 
    set par(spacing: 1.2em)// hanging-indent: 2.5in - TODO: Hanging-indent doesnt work.
    it
  }
  wideblock(
  bibliography(
    title: "References"+v(0.2em), 
    "template/main.bib", 
    style: "ieee" //"apa", "chicago-author-date", "chicago-notes", "mla"
  )
  )
  
}
