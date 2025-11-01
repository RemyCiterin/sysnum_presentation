#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#let xCPU = 0
#let yCPU = 0
#let xGPU = 6
#let yGPU = 0

#let RiscV3D = {
  diagram(
  	edge-stroke: 1pt,
  	node-corner-radius: 5pt,
  	edge-corner-radius: 8pt,
  	mark-scale: 80%,
    spacing: 10pt,

    node((xCPU+0, yCPU+1), text(fill: white, [Fetch]), fill: blue, name:<cpu-fetch>),
    node((xCPU+1, yCPU+1), text(fill: white, [Decode]), fill: blue),
    node((xCPU+2, yCPU+1), text(fill: white, [Rr]), fill: blue, shape: fletcher.shapes.pill),
    node((xCPU+3, yCPU+1), text(fill: white, [Ex]), fill: blue),
    node((xCPU+4, yCPU+1), text(fill: white, [Wb]), fill: blue, name: <cpu-wb>),
    node((xCPU+0, yCPU+2), [L1i], fill: orange, name: <cpu-l1i>),
    node((xCPU+3, yCPU+2), [L1d], fill: orange, name: <cpu-l1d>),
    node((xCPU+1, yCPU+2), [MMU], fill: orange, name: <cpu-immu>),
    node((xCPU+4, yCPU+2), [MMU], fill: orange, name: <cpu-dmmu>),
    for i in range(0,4) {
      edge((xCPU+i,yCPU+1), "r", "->")
    },
    edge(<cpu-l1i>, <cpu-immu>, "<->"),
    edge(<cpu-l1d>, <cpu-dmmu>, "<->"),
    edge((xCPU+4,yCPU+1), "u,l,l,l,l,d", "->"),
    edge((xCPU+4,yCPU+1), "u,l,l,d", "->"),
    edge((xCPU+0,yCPU+1), "d", "->"),
    edge((xCPU+3,yCPU+1), "d", "->"),

    node(
      text(fill: black, [#v(40pt) CPU]),
      enclose: ((xCPU,yCPU), <cpu-fetch>, <cpu-wb>, <cpu-dmmu>),
      name:<cpu>, stroke: teal, fill: teal.lighten(30%)),

    node((xGPU+0, yGPU+1), text(fill: white, [Schedule]), fill: blue, name:<gpu-schedule>),
    node((xGPU+1, yGPU+1), text(fill: white, [Fetch]), fill: blue, name:<gpu-fetch>),
    node((xGPU+2, yGPU+1), text(fill: white, [Decode]), fill: blue),
    node((xGPU+3, yGPU+1), text(fill: white, [Rr]), fill: blue, shape: fletcher.shapes.pill),
    node((xGPU+4, yGPU+1), text(fill: white, [Ex]), fill: blue, name: <gpu-exec>),
    node((xGPU+5, yGPU+1), text(fill: white, [Wb]), fill: blue, name: <gpu-wb>),
    node((xGPU+1, yGPU+2), [L1i], fill: orange, name: <gpu-l1i>),
    node((xGPU+4, yGPU+2), [L1d], fill: orange, name: <gpu-l1d>),
    for i in range(0,5) {
      edge((xGPU+i,yGPU+1), "r", "->")
    },
    edge(<gpu-wb>, "u,l,l,l,l,l,d", "->"),
    edge(<gpu-wb>, "u,l,l,d", "->"),
    edge(<gpu-fetch>, "d", "->"),
    edge(<gpu-exec>, "d", "->"),

    node(
      text(fill: black, [#v(40pt) GPU]),
      enclose: ((xGPU,yGPU), <gpu-schedule>, <gpu-wb>, <gpu-l1i>),
      name:<gpu>, stroke: teal, fill: teal.lighten(30%)),


    node((6, 6), [xbar], fill: orange, name: <xbar>),
    edge(<cpu-l1i>, <xbar>, "->", corner: left),
    edge(<cpu-l1d>, <xbar>, "->", corner: left),
    edge(<cpu-immu>, <xbar>, "->", corner: left),
    edge(<cpu-dmmu>, <xbar>, "->", corner: left),
    edge(<gpu-l1i>, <xbar>, "->", corner: right),
    edge(<gpu-l1d>, <xbar>, "->", corner: right),

    node((4, 7), [Mmio], fill: orange, name: <mmio>),
    node((7, 7), [broadcast], fill: orange, name: <broadcast>),

    node((3, 7), [uart], fill: orange, name: <uart>),
    node((3, 9), [sdcard], fill: orange, name: <sdcard>, shape: fletcher.shapes.rect),
    node((4, 9), [Frame\ buffer], fill: orange, name: <fbf>, shape: fletcher.shapes.rect),

    edge(<xbar>, <mmio>, "->"),
    edge(<xbar>, <broadcast>, "->"),

    node((7,9), [SDRAM], fill: orange, name: <sdram>),
    node((6,9), [SRAM], fill: orange, name: <sram>),
    node((8,9), [GPU\ stacks], fill: orange, name: <gpu-stacks>, shape: fletcher.shapes.rect),
    edge(<broadcast>, <gpu-stacks>, "->", bend: 10deg),
    edge(<broadcast>, <sram>, "->", bend: -10deg),
    edge(<broadcast>, <sdram>, "->"),

    edge(<mmio>, <uart>, "->"),
    edge(<mmio>, <sdcard>, "->", bend: -10deg),
    edge(<mmio>, <fbf>, "->"),
  )
}
