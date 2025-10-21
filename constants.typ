// -----------------------------
// Fonts
// 
/*
  Used in:
    Title Block
    Margin Notes
    Codly header/footer
    Figure captions
    Draft-GB letters
*/
#let sans-fonts = (
  "Gillius ADF",
  "IBM Plex Sans",
  "Atkinson Hyperlegible",

  "TeX Gyre Heros",
  "Noto Sans",
  "Helvetica",
)
/*
  Used in:
    Default for everything else, main body text/headers/etc.
*/
#let serif-fonts = (
  "fbb",
  "TeX Gyre Pagella",
  "New Computer Modern",

  "ETBembo",
  "Libertinus Serif",
  
  "Lucida Bright",
)
/*
  Used in:
    Code inline and blocks
*/
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

// -----------------------------
// Colors
// 
// TODO: Pass over all colors/theming/etc.
// 
#let txt-default     = luma(30)         // Slightly lighten to reduce contrast text/bg
#let link-color      = blue               // Link/Ref color
#let draft-bg        = rgb("#fff4f4")   // DRAFT letter colors in bg

// **
// ** CODE
// **
//let z-bg            = rgb("#dadadace")
//let code-bg         = rgb("#f5f5f596")
#let code-bg         = rgb("#f5f5f5").darken(1%)    // Code bg for default + inline
#let code-border     = rgb("#F5F5F5").darken(16%)   // Code border
#let z-bg            = rgb("#dadadace")             // Code background when block zebra
#let code-ruler-txt  = luma(65%)                    // For line # in code block side

// **
// ** Clue stroke colors
// **
#let color-info      = rgb("#5b75a0ff")
#let color-todo      = rgb("#F5F5F5").darken(10%)
#let color-idea      = color-todo
#let color-warning   = rgb("#ffce31ff")
#let color-important = rgb("#f44336ff")
//#let color-fire      = rgb("#fc9502ff")
//#let color-rocket    = rgb("#bc5fd3ff")

// -----------------------------
// Resources
// 
#let img-folder        = "img/"
#let icon-folder       = "img/icons/"

// Clue SVG icons
#let icon-idea         = icon-folder + "idea.svg"
#let icon-important    = icon-folder + "important.svg"
#let icon-info         = icon-folder + "info.svg"
#let icon-todo         = icon-folder + "todo.svg"
#let icon-warning      = icon-folder + "warning.svg"
//#let icon-fire         = icon-folder + "fire.svg"
//#let icon-rocket       = icon-folder + "rocket.svg"
