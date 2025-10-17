// Requirement to set up sidenotes
#import "@preview/drafting:0.2.2": *
// For header numbering. Can also be used for list/page numbers.
#import "@preview/numbly:0.1.0": numbly

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

#let fullwidth = state("fullwidth", false)

#let template(
  title: none,
  authors: none,
  date: datetime.today().display("[day] [month repr:long] [year]"),
  abstract: none,
  toc: false,
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

  set par(justify: true, spacing: 1.5em)

  set enum(indent: 1em)
  set list(indent: 1em)
  show enum: set par(spacing: 1.25em)
  show list: set par(spacing: 1.25em)

  // Section headings
  // Using a trick from: https://github.com/flaribbit/numbly/issues/5
  set heading(numbering: numbly(
  (..)=>h(-0.3em),  // use {level:format} to specify the format
  "{1}.{2}",        // if format is not specified, arabic numbers will be used
  "{1}.{2}.{3}",    // here, we only want the 3rd level
  ))

  show heading.where(level: 1): set text(size: 13pt, weight: "bold")
  show heading.where(level: 2): set text(size: 12pt, weight: "regular",style: "italic")
  show heading.where(level: 3): set text(size: 10pt, weight: "regular",style: "italic")

  show heading: set block(above: 1.2em, below: 1em)

// **
// ** Specialty
// **
  // Inline ` sss `
  show raw.where(block: false): box.with(
    fill: luma(95%),
    inset: (x: 3pt, y: 0pt),
    outset: (y: 3pt),
    radius: 2pt,
  )

  // Block code ``` sss ``` 
  show raw.where(block: true): block.with(
    fill: luma(95%),
    inset: 5pt,
    radius: 4pt,
    width: 100%,
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
      if header and header-content != none {
        header-content
      } else if header {
        set text(size: 8pt)
        wideblock({
          if counter(page).get().first() > 1 [
            #emph[#title]
            #h(1fr)
            #emph[#date]
            \
            #emph[#authors]
          ]
        })
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
      #if toc { [\ #outline(indent: 1em, title: none, depth: 2) ] }
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
    margin-left: left-margin*1.2,
  )
  set-margin-note-defaults(
    stroke: none,
    side: right,
  )

  doc

  set cite(style: "american-physics-society")
  show bibliography: set par(spacing: 1em)
  if bib != none { wideblock(bib) }
}

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
