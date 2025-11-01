#import "@preview/circuiteria:0.2.0"
#import "@preview/cetz:0.3.2" : *

#import circuiteria: *
#import circuiteria.element : *


#let draw-fifo-shape(id, tl, tr, br, bl, fill, stroke) = {
  let p0 = tl
  let p1 = (tl, 50%, tr)
  let p2 = (tl, 75%, tr)
  let p3 = tr
  let p4 = br
  let p5 = (bl, 75%, br)
  let p6 = (bl, 50%, br)
  let p7 = bl

  let f1 = draw.group(name: id, {

    draw.merge-path(
      inset: 0.5em,
      fill: fill,
      stroke: stroke,
      close: true,
      draw.line(p0, p3, p4, p7, p6, p1, p2, p5, p2)
    )
    draw.anchor("north", (tl, 50%, tr))
    draw.anchor("south", (bl, 50%, br))
    draw.anchor("west", (tl, 50%, bl))
    draw.anchor("east", (tr, 50%, br))
    draw.anchor("north-west", tl)
    draw.anchor("north-east", tr)
    draw.anchor("south-east", br)
    draw.anchor("south-west", bl)
    draw.anchor("name", (tl, 50%, br))
  })

  let f2 = add-port(id, "west", (id: "enq"), (p0, 50%, p3))
  let f3 = add-port(id, "east", (id: "deq"), (p1, 50%, p2))

  let f = {
    f1; f2; f3
  }

  return (f, tl, tr, br, bl)
}

/// Draws an ALU with two inputs
///
/// #examples.alu
/// For parameters description, see #doc-ref("element.elmt")
#let fifo(
  x: none,
  y: none,
  w: none,
  h: none,
  name: none,
  name-anchor: "center",
  fill: none,
  stroke: black + 1pt,
  id: "",
  debug: (
    ports: false
  )
) = {
  let ports = (
    west: (
      (id: "enq"),
    ),
    east: (
      (id: "deq"),
    )
  )

  element.elmt(
    draw-shape: draw-fifo-shape,
    x: x,
    y: y,
    w: w,
    h: h,
    name: name,
    name-anchor: name-anchor,
    ports: ports,
    fill: fill,
    stroke: stroke,
    id: id,
    auto-ports: false,
    ports-y: (
      enq: (h) => {h * 0.5},
      deq: (h) => {h * 0.5}
    ),
    debug: debug
  )
}
