// From: https://typst.app/universe/package/hei-synd-report
//-------------------------------------
// 
  // TODO: Pass over all colors/theming/etc. (e.g. the lumen on page earlier and stuff)
  //let z-bg            = rgb("#dadadace")
  //let code-bg         = rgb("#f5f5f596")
#let code-bg         = rgb("#f5f5f5").darken(1%)
#let code-border     = rgb("#F5F5F5").darken(16%)
#let z-bg            = rgb("#dadadace")

#let color-info      = rgb("#5b75a0ff")
#let color-idea      = rgb("#ffe082ff")
#let color-warning   = rgb("#ffce31ff")
#let color-important = rgb("#f44336ff")
#let color-fire      = rgb("#fc9502ff")
#let color-rocket    = rgb("#bc5fd3ff")
#let color-todo      = rgb("#F5F5F5").darken(10%)

// Resources
#let img-folder        = "img/"
#let icon-folder       = "img/icons/"
#let icon-fire         = icon-folder + "fire.svg"
#let icon-idea         = icon-folder + "idea.svg"
#let icon-important    = icon-folder + "important.svg"
#let icon-info         = icon-folder + "info.svg"
#let icon-rocket       = icon-folder + "rocket.svg"
#let icon-todo         = icon-folder + "todo.svg"
#let icon-warning      = icon-folder + "warning.svg"

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
// Icon Boxes
//
#let iconbox(
  width: 100%,
  radius: 4pt,
  border: 4pt,
  inset: 10pt,
  outset: -10pt,
  linecolor: code-border,
  icon: none,
  iconheight: 1cm,
  body
) = {
  if body != none {
    align(left,
      rect(
        stroke: (left:linecolor+border, rest:code-border+0.1pt),
        radius: (left:0pt, right:radius),
        fill: code-bg,
        outset: (left:outset, right:outset),
        inset: (left:inset*2, top:inset, right:inset*2, bottom:inset),
        width: width)[
          #if icon != none {
            align(left,
              table(
                stroke:none,
                align:left+horizon,
                columns: (auto,auto),
                image(icon, height:iconheight), [#body]
              )
            )
          } else {
            body
          }
        ]
    )
  }
}

#let infobox(
  body
) = {
  iconbox(
    linecolor: color-info,
    icon: icon-info,
  )[#body]
}

#let warningbox(
  body
) = {
  iconbox(
    linecolor: color-warning,
    icon: icon-warning,
  )[#body]
}

#let ideabox(
  body
) = {
  iconbox(
    linecolor: color-idea,
    icon: icon-idea
  )[#body]
}

#let firebox(
  body
) = {
  iconbox(
    linecolor: color-fire,
    icon: icon-fire,
  )[#body]
}

#let importantbox(
  body
) = {
  iconbox(
    linecolor: color-important,
    icon: icon-important,
  )[#body]
}

#let rocketbox(
  body
) = {
  iconbox(
    linecolor: color-rocket,
    icon: icon-rocket,
  )[#body]
}

#let todobox(
  body
) = {
  iconbox(
    linecolor: color-todo,
    icon: icon-todo,
  )[#body]
}

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
