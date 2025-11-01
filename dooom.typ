#import "@preview/circuiteria:0.2.0"
#import "@preview/cetz:0.3.2" : *

#import circuiteria: *
#import circuiteria.element : *



#let DOoOM = {

  let Fetch = green.lighten(60%);
  let Decode = red.lighten(60%);
  let Issue = maroon.lighten(60%);
  let RegRead = yellow.lighten(50%);
  let Exec = blue.lighten(60%);
  let WriteBack = purple.lighten(60%);
  let Commit = black.lighten(60%);

  circuit({
    element.block(
      x:0, y:0, w: 4, h: 1.5,
      id: "Fetch",
      name: "Fetch",
      fill: Fetch,
      ports: (
        west: (
          (id: "PredReq"),
          (id: "PredResp"),
        ),
        east: (
          (id: "Req"),
          (id: "Resp")
        ),
        south: (
          (id: "Out"),
        )
      )
    )

    element.block(
      x:(rel: 2, to: "Fetch.east"), y:(from: "Fetch-port-Req", to: "In"),
      w: 3, h: 1.5,
      id: "L1i",
      name: text(fill: white, "L1i"),
      fill: blue,
      ports: (
        west: (
          (id: "In"),
          (id: "Out")
        ),
      )
    )

    element.block(
      x:(rel: -6.5, to: "Fetch.west"), y:(from: "Fetch-port-PredReq", to: "In"),
      w: 4, h: 1.5,
      id: "BranchPred",
      name: "Branch-Pred",
      fill: Fetch,
      ports: (
        east: (
          (id: "In"),
          (id: "Out")
        ),
      )
    )

    wire.wire(
      "FetchReq",
      ("Fetch-port-Req", "L1i-port-In"),
      directed: true,
      name: "Address"
    )

    wire.wire(
      "FetchResp",
      ("L1i-port-Out", "Fetch-port-Resp"),
      directed: true,
      name: "Data",
      reverse: true
    )

    wire.wire(
      "FetchPredReq",
      ("Fetch-port-PredReq", "BranchPred-port-In"),
      directed: true,
      reverse: true,
      name: "PC"
    )

    wire.wire(
      "FetchPredResp",
      ("BranchPred-port-Out", "Fetch-port-PredResp"),
      directed: true,
      name: "PredPC",
    )


    element.block(
      x:0, y: -2,
      w: 4, h: 1.5,
      id: "Decode",
      name: "Decode",
      fill: Decode,
      ports: (
        north: ((id: "In"),),
        south: ((id: "Out"),),
      )
    )

    wire.wire(
      "FetchToDecode",
      ("Fetch-port-Out", "Decode-port-In"),
      directed: true,
    )

    element.block(
      x:-3, y: -4,
      w: 10, h: 1.5,
      id: "ROB",
      name: "Reorder-Buffer / Renaming",
      fill: WriteBack,
      ports: (
        north: ((id: "In"),),
        west: ((id: "WB"),),
        south: (
          (id: "ALU"),
          (id: "Control"),
          (id: "LSU")
        ),
      )
    )

    wire.wire(
      "DecodeToRob",
      ("Decode-port-Out", "ROB-port-In"),
      directed: true,
    )

    element.block(
      x: -3.25, y: -6.25, w: 10.5, h: 2,
      id: "IQ",
      fill: maroon.lighten(70%),
      ports: (west: ((id: "WB"),))
    )

    element.block(
      x:-3, y: -6,
      w: 3, h: 1.5,
      id: "IQ1",
      name: [Issue Queue],
      fill: Issue,
      ports: (
        north: ((id: "In"),),
        south: ((id: "Out"),),
        west: ((id: "WB"),)
      )
    )

    element.block(
      x:-3, y: -10,
      w: 3, h: 1.5,
      id: "ALU",
      name: "ALU",
      fill: Exec,
      ports: (
        north: ((id: "In"),),
        south: ((id: "Out"),),
      )
    )

    element.block(
      x:0.5, y: -6,
      w: 3, h: 1.5,
      id: "IQ2",
      name: [Issue Queue],
      fill: Issue,
      ports: (
        north: ((id: "In"),),
        south: ((id: "Out"),),
      )
    )

    element.block(
      x:0.5, y: -10,
      w: 3, h: 1.5,
      id: "Control",
      name: "Control",
      fill: Exec,
      ports: (
        north: ((id: "In"),),
        south: ((id: "Out"),),
      )
    )

    element.block(
      x:4, y: -6,
      w: 3, h: 1.5,
      id: "IQ3",
      name: [Issue Queue],
      fill: Issue,
      ports: (
        north: ((id: "In"),),
        south: ((id: "Out"),),
      )
    )

    element.block(
      x:4, y: -10,
      w: 3, h: 1.5,
      id: "LSU",
      name: [Load/Store \ Unit],
      fill: Exec,
      ports: (
        north: ((id: "In"),),
        south: ((id: "Out"),),
        east: (
          (id: "Req"),
          (id: "Resp"),
        )
      )
    )

    wire.wire(
      "RobToIQ",
      ("ROB-port-ALU", "IQ1-port-In"),
      directed: true,
    )

    wire.wire(
      "IQ1ToALU",
      ("IQ1-port-Out", "ALU-port-In"),
      directed: true,
    )

    wire.wire(
      "RobToIQ2",
      ("ROB-port-Control", "IQ2-port-In"),
      directed: true,
    )

    wire.wire(
      "IQ2ToControl",
      ("IQ2-port-Out", "Control-port-In"),
      directed: true,
    )

    wire.wire(
      "RobToIQ3",
      ("ROB-port-LSU", "IQ3-port-In"),
      directed: true,
    )

    wire.wire(
      "IQ3ToLSU",
      ("IQ3-port-Out", "LSU-port-In"),
      directed: true,
    )

    element.block(
      x:-3, y: -8,
      w: 10, h: 1.5,
      id: "RegFile",
      name: "Physical Register File",
      fill: RegRead,
      ports: (
        west: ((id: "WB"),)
      ),
    )


    element.block(
      x:(rel: 2, to: "LSU.east"), y:(from: "LSU-port-Req", to: "In"),
      w: 3, h: 1.5,
      id: "L1d",
      name: text(fill: white, "L1d"),
      fill: blue,
      ports: (
        west: (
          (id: "In"),
          (id: "Out")
        ),
      )
    )

    wire.wire(
      "LSUReq",
      ("LSU-port-Req", "L1d-port-In"),
      directed: true,
      name: "Address"
    )

    wire.wire(
      "LSUResp",
      ("L1d-port-Out", "LSU-port-Resp"),
      directed: true,
      name: "Data",
      reverse: true
    )

    wire.wire(
      "LSUOut",
      ("LSU-port-Out", "ROB-port-WB"),
      directed: true,
      style: "dodge",
      dodge-sides: ("north", "west"),
      dodge-y: -11,
      dodge-margins: (0, 2),
    )

    wire.wire(
      "ALUOut",
      ("ALU-port-Out", "ROB-port-WB"),
      directed: true,
      style: "dodge",
      dodge-sides: ("north", "west"),
      dodge-y: -11,
      dodge-margins: (0, 2),
    )

    wire.wire(
      "ControlOut",
      ("Control-port-Out", "ROB-port-WB"),
      directed: true,
      style: "dodge",
      dodge-sides: ("north", "west"),
      dodge-y: -11,
      dodge-margins: (0, 2),
      name: "WB",
      name-pos: "end"
    )

    wire.wire(
      "LSURegOut",
      ("LSU-port-Out", "RegFile-port-WB"),
      directed: true,
      style: "dodge",
      dodge-sides: ("north", "west"),
      dodge-y: -11,
      dodge-margins: (0, 2),
      name: "WB",
      name-pos: "end"
    )

    wire.wire(
      "ALURegOut",
      ("ALU-port-Out", "RegFile-port-WB"),
      directed: true,
      style: "dodge",
      dodge-sides: ("north", "west"),
      dodge-y: -11,
      dodge-margins: (0, 2),
    )

    wire.wire(
      "ControlRegOut",
      ("Control-port-Out", "RegFile-port-WB"),
      directed: true,
      style: "dodge",
      dodge-sides: ("north", "west"),
      dodge-y: -11,
      dodge-margins: (0, 2),
    )

    wire.wire(
      "LSUWakeup",
      ("LSU-port-Out", "IQ-port-WB"),
      directed: true,
      style: "dodge",
      dodge-sides: ("north", "west"),
      dodge-y: -11,
      dodge-margins: (0, 1.75),
      name: "Wakeup",
      name-pos: "end"
    )

    wire.wire(
      "ALUWakeup",
      ("ALU-port-Out", "IQ-port-WB"),
      directed: true,
      style: "dodge",
      dodge-sides: ("north", "west"),
      dodge-y: -11,
      dodge-margins: (0, 1.75),
    )

    wire.wire(
      "ControlWakeup",
      ("Control-port-Out", "IQ-port-WB"),
      directed: true,
      style: "dodge",
      dodge-sides: ("north", "west"),
      dodge-y: -11,
      dodge-margins: (0, 1.75),
    )
  })};
