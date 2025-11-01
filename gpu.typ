#import "@preview/circuiteria:0.2.0"
#import "@preview/cetz:0.3.2" : *

#import circuiteria: *
#import circuiteria.element : *

#let GPU = {
  let Fetch = green.lighten(60%);
  let Decode = red.lighten(60%);
  let Issue = maroon.lighten(60%);
  let RegRead = yellow.lighten(50%);
  let Exec = blue.lighten(60%);
  let WriteBack = purple.lighten(60%);
  let Commit = black.lighten(60%);

  circuit({

    element.block(
      x:-2, y:2, w: 8, h: 3,
      id: "Schedule",
      name: [
        #v(10pt)
        Program counter:
        #v(-15pt)
        #grid(
          columns: 5,
          stroke: 1pt,
          fill: white,
          inset: 6pt,
          [*Warp 0:*], [0x4], [0x4], [0x4], [0x8],
          [*Warp 1:*], [0x8], [0x8], [0x8], [0x8],
          [*Warp 2:*], [0xC], [0x0], [0x4], [0xC],
        )
      ],
      fill: Fetch,
      ports: (
        south: (
          (id: "Out"),
        )
      )
    )

    element.block(
      x:0, y:0, w: 4, h: 1.5,
      id: "Fetch",
      name: "Fetch/Decode",
      fill: Fetch,
      ports: (
        east: (
          (id: "Req"),
          (id: "Resp")
        ),
        south: (
          (id: "Out"),
        ),
        north: ((id: "In"),)
      )
    )

    element.block(
      x:(rel: 1, to: "Fetch.east"), y:(from: "Fetch-port-Req", to: "In"),
      w: 2, h: 1.5,
      id: "L1i",
      name: "L1i",
      fill: blue,
      ports: (
        west: (
          (id: "In"),
          (id: "Out")
        ),
      )
    )

    wire.wire(
      "ScheduleReq",
      ("Schedule-port-Out", "Fetch-port-In"),
      directed: true
    )

    wire.wire(
      "FetchReq",
      ("Fetch-port-Req", "L1i-port-In"),
      directed: true,
    )

    wire.wire(
      "FetchResp",
      ("L1i-port-Out", "Fetch-port-Resp"),
      directed: true,
      reverse: true
    )

    element.block(
      x:-2, y: -4,
      w: 8, h: 3,
      id: "RegFile",
      name: [
        Two banks register file:
        #v(-10pt)
        #grid(
          columns: 2,
          gutter: 15pt,
          inset: 5pt,
          fill: white,
          [
            Warp 0,2,4...14 \
            SRAM: 4KB
          ], [
            Warp 1,3,5...15 \
            SRAM: 4KB
          ]
        )
      ],
      fill: Decode,
      ports: (
        north: ((id: "In"),),
        east: (
          (id: "Out0"),
          (id: "Out1"),
          (id: "Out2"),
          (id: "Out3"),
        ),
      )
    )

    wire.wire(
      "FetchToRF",
      ("Fetch-port-Out", "RegFile-port-In"),
      directed: true,
    )

    element.block(
      x: (rel: 3, to: "RegFile.east"), y: (from: "RegFile-port-Out0", to: "In0"),
      w: 5, h: 3,
      id: "Exec",
      fill: Exec,
      name: align(left,[
        ALU \
        Mul/Div \
        Memory
        coalescing
      ]),
      ports: (
        west: (
          (id: "In0"),
          (id: "In1"),
          (id: "In2"),
          (id: "In3"),
        ),
        east: (
          (id: "Req"),
          (id: "Resp"),
        ),
      )
    )

    for i in (0,1,2,3) {
      wire.wire(
        "FetchToRF",
        ("RegFile-port-Out" + str(i), "Exec-port-In" + str(i)),
        directed: true,
      )
    }

    element.block(
      x:(rel: 1, to: "Exec.east"), y:(from: "Exec-port-Req", to: "In"),
      w: 2, h: 3,
      id: "L1d",
      name: "L1d",
      fill: blue,
      ports: (
        west: (
          (id: "In"),
          (id: "Out")
        ),
      )
    )

    wire.wire(
      "ExecReq",
      ("Exec-port-Req", "L1d-port-In"),
      directed: true,
    )

    wire.wire(
      "ExecResp",
      ("L1d-port-Out", "Exec-port-Resp"),
      directed: true,
      reverse: true
    )

  })
}

