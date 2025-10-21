/*
  Inspiration for box styling taken from: 
    https://typst.app/universe/package/hei-synd-report
*/
#import "@preview/showybox:2.0.4": showybox

// todo move  this out
#let in-note = state("in-note", false)

// TODO: Pass over all colors/theming/etc. (e.g. the lumen on page earlier and stuff)
//let z-bg            = rgb("#dadadace")
//let code-bg         = rgb("#f5f5f596")
#let code-bg         = rgb("#f5f5f5").darken(1%)
#let code-border     = rgb("#F5F5F5").darken(16%)
#let z-bg            = rgb("#dadadace")

#let color-info      = rgb("#5b75a0ff")
#let color-todo      = rgb("#F5F5F5").darken(10%)
#let color-idea      = color-todo
#let color-warning   = rgb("#ffce31ff")
#let color-important = rgb("#f44336ff")
//#let color-fire      = rgb("#fc9502ff")
//#let color-rocket    = rgb("#bc5fd3ff")

// Resources
#let img-folder        = "img/"
#let icon-folder       = "img/icons/"

#let icon-idea         = icon-folder + "idea.svg"
#let icon-important    = icon-folder + "important.svg"
#let icon-info         = icon-folder + "info.svg"
#let icon-todo         = icon-folder + "todo.svg"
#let icon-warning      = icon-folder + "warning.svg"
//#let icon-fire         = icon-folder + "fire.svg"
//#let icon-rocket       = icon-folder + "rocket.svg"

// Option Style
#let option-style(
  type: none,
  size: 11pt,
  style: "italic",
  fill: code-bg,
  body) = {[
  #if type == none {
    text(size:size, style:style, fill:fill)[#body]
  } else {
    if type == "draft" {text(size:size, style:style, fill:fill)[#body]}
  } 
]}

//-------------------------------------
// Todo Box
//
#let todo(body) = [
  #let rblock = block.with(stroke: red, radius: 0.5em, fill: red.lighten(80%))
  #let top-left = place.with(top + left, dx: 1em, dy: -0.35em)
  #block(inset: (top: 0.35em), {
    rblock(width: 100%, inset: 1em, body)
    top-left(rblock(fill: white, outset: 0.25em, text(fill: red)[*TODO*]))
  })
  <todo>
]

//-------------------------------------
// Informative boxes
//
// Creating nice looking information boxes with different headings
#let colorbox(
  title: "title",
  color: color-todo,
  stroke: 0.5pt,
  radius: 4pt,
  width: auto,
  body
) = {
  let strokeColor = color
  let backgroundColor = color.lighten(50%)

  return box(
    fill: backgroundColor,
    stroke: stroke + strokeColor,
    radius: radius,
    width: width
  )[
    #block(
      fill: strokeColor,
      inset: 8pt,
      radius: (top-left: radius, bottom-right: radius),
    )[
      #text(fill: white, weight: "bold")[#title]
    ]
    #block(
      width: 100%,
      inset: (x: 8pt, bottom: 8pt)
    )[
      #body
    ]
  ]
}

#let slanted-background(
  color: black, body) = {
  set text(fill: white, weight: "bold")
  context {
    let size = measure(body)
    let inset = 8pt
    [#block()[
      #polygon(
        fill: color,
        (0pt, 0pt),
        (0pt, size.height + (2*inset)),
        (size.width + (2*inset), size.height + (2*inset)),
        (size.width + (2*inset) + 6pt, 0cm)
      )
      #place(center + top, dy: size.height, dx: -3pt)[#body]
    ]]
  }
}

#let slanted-colorbox(
  title: "title",
  color: color-todo,
  stroke: 0.5pt,
  radius: 4pt,
  width: auto,
  body
) = {
  let strokeColor = color
  let backgroundColor = color.lighten(50%)

  return box(
    fill: backgroundColor,
    stroke: stroke + strokeColor,
    radius: radius,
    width: width
  )[
    #slanted-background(color: strokeColor)[#title]
    #block(
      width: 100%,
      inset: (top: -2pt, x: 10pt, bottom: 10pt)
    )[
      #body
    ]
  ]
}



//-------------------------------------
// TEST/DEV
//
//

// Wrapper to allow inset positioning of the box itself 
// To account for thicker-borders extending the 'box' start position.
#let showybox2(border: 0pt, above: 0.9em, below: 0.9em, ..args)= {
  // For now just handle it like such, maybe improve later to grab border size.
  // Need 0.3pt even when border=0, misaligned for some reason.
  block(inset:(left:border/2+0.3pt), above:above, below:below,
    showybox(..args)
  )
}
#let showy(body, icon: none, color: color-info, title: "") = {
  let border = if icon == none { 5pt } else { 5pt }
  let iconheight = 1.9em
  let inset = if icon == none { 1em } else { 1em*(1em/iconheight) }
  showybox2(border:border,
    frame: (
      border-color: color,
      body-color: code-bg,
      thickness: (left: border),
      radius: 1pt,
      inset: (left: inset*1.3, top: inset, right: inset*1.3, bottom: inset),
    ),
    title-style: (
      color: black,
      weight: "regular",
      align: center
    )
  )[
    #context{
      // set text(size: 30pt) if in-note.get() Override some styling if in-notes
      if icon != none {
          grid(
            stroke: 0pt,
            inset: ((left: inset - 0.4em), (left: 0.5em)),
            column-gutter: 0em,
            align:left+horizon,
            columns: (auto,auto),
            image(icon, height:iconheight), [#body]
          )
      } else {
        body
      } 
    }
  ]
}

#let infobox(body, ..args) = {
  showy(icon: icon-info, color: color-info, body, ..args)
}
#let ideabox(body, ..args) = {
  showy(icon: icon-idea, color: color-idea, body, ..args)
}
#let impbox(body, ..args) = {
  showy(icon: icon-important, color: color-important, body, ..args)
}
#let todobox(body, ..args) = {
  showy(icon: icon-todo, color: color-todo, body, ..args)
}
#let warnbox(body, ..args) = {
  showy(icon: icon-warning, color: color-warning, body, ..args)
}
