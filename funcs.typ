// Requirement to set up sidenotes
#import "@preview/drafting:0.2.2": *

#import "constants.typ": *

// -----------------------------
// State/Counter
// 
#let in-note = state("in-note", false)
#let fullwidth = state("fullwidth", false)
#let notecounter = counter("notecounter")

// -----------------------------
// Functions
// 

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