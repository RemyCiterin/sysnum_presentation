#import "@preview/cetz:0.3.2"
#import "@preview/circuiteria:0.2.0"

#import "fifo.typ" : *
#import "dooom.typ" : *

#import circuiteria: *

#import "@preview/polylux:0.4.0": *
#import "@preview/jotter-polylux:0.1.0": (
  setup,
  title-slide,
  framed-block,
  post-it,
)

#set text(
  size: 20pt,
  font: "Kalam",
  fill: blue.darken(50%),
)

#let color(c, t) = {emph(text(c, t))}

#show raw.where(lang: "bsv"): it => [
    #show regex("\b(module|function|interface|method|endmodule|endfunction|endinterface|endmethod|rule|endrule|typedef|deriving)\b") : (keyword =>
      text(weight:"bold", fill: blue, keyword))
    #show regex("\b(begin|for|if|end|let|action|endaction|actionvalue|endactionvalue|union|tagged|enum|struct|case|endcase|matches|match|return)\b") : (keyword =>
      text(weight:"bold", fill: blue, keyword))
    #it
]


#show math.equation: set text(
  font: ("Pennstander Math", /* as a fallback: */ "New Computer Modern Math"),
  weight: "light",
)

#show raw: set text(font: "Fantasque Sans Mono")

#show: setup.with(
  header: [Quelques projets sur FPGA],
  highlight-color: red,
  binding: true,
  dots: true,
)

#title-slide[FPGA : du registre à DOOM][

  Rémy Citérin

  25/11/2025, Paris
]


#slide[
  = Au menu
  - Ray-tracing
  #v(25pt)
  - UNIX
  #v(25pt)
  - DOOM
  #v(25pt)
  - GPU
]

#slide[
  = Accélérateur de Ray-Tracing

  #grid(
    columns: (400pt, 300pt),
    gutter: 1em,
    [
    - Pipeline + FSM + réseaux systoliques
    - Une dizaine de FPS
    - Parcours d'arbre avec Bounding Volume Hierarchy
    ], [
    #align(left, image("teapot.jpg", width:90%))
    ]
  )
]

#slide[
  = Réseau systolic : produit scalaire en hardware
  #v(-1cm)
  #set text(size: 20pt)
  #set align(center)

  #circuit({
    element.block(
      x:2, y:2, w: 5, h: 3,
      id: "FMA",
      name: "FMA",
      fill: orange,
      ports: (
        west: (
          (id: "A", name: "A"),
        ),
        east: (
          (id: "C", name: "C"),
          (id: "R", name: "A*B+C"),
        ),
        north: (
          (id: "B", name: "B"),
        ),
        south: (
          (id: "O"),
        )
      )
    )

    wire.stub("FMA-port-A", "west")
    wire.stub("FMA-port-B", "north")
    wire.stub("FMA-port-O", "south")

    let b0 = (rel: (0, 0.5), to: "FMA-port-B")
    let b1 = (rel: (0, 0.6), to: b0)
    let b2 = (rel: (0, 0.6), to: b1)

    let o0 = (rel: (0, -1.3), to: "FMA-port-O")
    let o1 = (rel: (0, -0.6), to: o0)
    let o2 = (rel: (0, -0.6), to: o1)

    let a0 = (rel: (-1.5,0), to: "FMA-port-A")
    let a1 = (rel: (-0.6,0), to: a0)
    let a2 = (rel: (-0.6,0), to: a1)
    draw.content(
      a0, [$A_0$], anchor: "west", padding: 3pt
    )
    draw.content(
      a1, [$A_1$], anchor: "west", padding: 3pt
    )
    draw.content(
      a2, [$A_2$], anchor: "west", padding: 3pt
    )

    draw.content(
      b0, [$B_0$], anchor: "south", padding: 3pt
    )
    draw.content(
      b1, [$B_1$], anchor: "south", padding: 3pt
    )
    draw.content(
      b2, [$B_2$], anchor: "south", padding: 3pt
    )

    draw.content(
      o2, [$A_0*B_0$], anchor: "south", padding: 3pt
    )
    draw.content(
      o1, [$A_0*B_0+A_1*B_1$], anchor: "south", padding: 3pt
    )
    draw.content(
      o0, [$A_0*B_0+A_1*B_1+A_2*B_2$], anchor: "south", padding: 3pt
    )

    element.block(
      x:(rel: 1, to: "FMA.east"), y:(from: "FMA-port-C", to: "Out"),
      w: 4, h: 3,
      id: "Reg",
      name: "Register",
      fill: blue,
      ports: (
        north: ((id: "reset", name: "reset"),),
        west: (
          (id: "Out", name: "Out"),
          (id: "In", name: "In")
        ),
      )
    )

    let r0 = (rel: (0, 0.5), to: "Reg-port-reset")
    let r1 = (rel: (0, 0.6), to: r0)
    let r2 = (rel: (0, 0.6), to: r1)

    draw.content(
      r0, [false], anchor: "south", padding: 3pt
    )
    draw.content(
      r1, [false], anchor: "south", padding: 3pt
    )
    draw.content(
      r2, [true], anchor: "south", padding: 3pt
    )

    wire.stub("Reg-port-reset", "north")

    wire.wire(
      "state-output", (
        "FMA-port-C",
        "Reg-port-Out"
      ),
    )

    wire.wire(
      "state-input", (
        "FMA-port-R",
        "Reg-port-In"
      ),
    )
  })
]

#slide[
  = Réseau systolic : produit scalaire en hardware

  #toolbox.side-by-side[
    ```bsv
    Reg#(Vector#(3,F16)) x1 <- mkReg(replicate(?));
    Reg#(Vector#(3,F16)) x2 <- mkReg(replicate(?));
    Fifo#(2, F16) outputs <- mkFifo;
    Reg#(Bit#(3)) reset <- mkReg(0);
    Reg#(F16) acc <- mkReg(0);

    rule step if (reset != 0);
      let fma = acc + x1[0] * x2[0];
      acc <= reset[0] == 1 ? 0 : fma;
      reset <= reset >> 1;
      x1 <= rotate(x1);
      x2 <= rotate(x2);

      if (reset[0] == 1) outputs.enq(fma);
    endrule
    ```
  ][
    ```bsv
    method request(Vec3 lhs, Vec3 rhs) if (reset == 0);
      x1 <= vec(lhs.x, lhs.y, lhs.z);
      x2 <= vec(rhs.x, rhs.y, rhs.z);
      reset <= 3'b100;
    endmethod

    interface response = toGet(outputs).get;
    ```
  ]
]

#slide[
  = DOoOM Out of Order Machine

  #toolbox.side-by-side[
    Un RISC-V out-of-order avec :
    - Multiplication/Division
    - Flotants
    - Prédiction de branche
    - Store buffer/Load queue (spéculation des dépendances)
    - Caches L1i et L1d
    - VGA, SD-CARD, UART
    - 32MB de SDRAM
  ][
    #post-it[
      #set text(size: .5em)
      - Fréquence : 30MHz sur un EPC5
      - Surface : 30K 4-LUT
      - Coremark : 2.7
    ]
  ]
]


#slide[
  = Finite state machine (FSM)

  #let Fetch = table.cell(fill: green.lighten(60%))[F];
  #let Decode = table.cell(fill: red.lighten(60%))[D];
  #let RegRead = table.cell(fill: yellow.lighten(50%))[Rr];
  #let Exec = table.cell(fill: blue.lighten(60%))[Ex];
  #let WriteBack = table.cell(fill: purple.lighten(60%))[Wb];

  #align(center, table(
    columns: (auto, auto, auto, auto, auto, auto, auto, auto, auto, auto, auto, auto, auto, auto),
    fill: (x, y) => if x == 0 or y == 0 { gray.lighten(20%) } else { gray.lighten(50%) },
    stroke: none,
    gutter: 0.2cm,
    align: horizon,
    //gutter: 1cm,
    inset: 0.4cm,
    [FSM], [$t_0$], [$t_1$], [$t_2$], [$t_3$],
    [$t_4$], [$t_5$], [$t_6$], [$t_7$], [$t_8$],
    [$t_9$], [$t_10$], [$t_11$], [$t_12$],
    [```asm add t0, a1, a2```],
      Fetch, Decode, RegRead, Exec, WriteBack,
      [], [], [], [], [], [],
      [], [],
    [```asm lw t1, 0(t0)```],
      [], [], [], [], [],
      Fetch, Decode, RegRead, Exec, Exec, WriteBack,
      [], [],
    [```asm mul t2, a1, a2```],
      [], [], [], [], [],
      [], [], [], [], [], [],
      Fetch, Decode
    ));
]

#slide[
  = Pipeline (In order)

  #let Fetch = table.cell(fill: green.lighten(60%))[F];
  #let Decode = table.cell(fill: red.lighten(60%))[D];
  #let RegRead = table.cell(fill: yellow.lighten(50%))[Rr];
  #let Exec = table.cell(fill: blue.lighten(60%))[Ex];
  #let WriteBack = table.cell(fill: purple.lighten(60%))[Wb];

  #align(center, table(
    columns: (auto, auto, auto, auto, auto, auto, auto, auto, auto, auto, auto, auto),
    fill: (x, y) => if x == 0 or y == 0 { gray.lighten(20%) } else { gray.lighten(50%) },
    stroke: none,
    gutter: 0.2cm,
    align: horizon,
    //gutter: 1cm,
    inset: 0.4cm,
    [Pipelined], [$t_0$], [$t_1$], [$t_2$], [$t_3$],
    [$t_4$], [$t_5$], [$t_6$], [$t_7$], [$t_8$],
    [$t_9$], [$t_10$],
    [```asm add t0, a1, a2```],
      Fetch, Decode, RegRead, Exec, WriteBack,
      [], [], [], [], [], [],
    [```asm lw t1, 0(t0)```],
      [],
      Fetch, Decode, [], RegRead, Exec, Exec, WriteBack,
      [], [], [],
    [```asm mul t2, a1, a2```],
      [], [], Fetch,
      Decode, [], RegRead,
      Exec, Exec, Exec, WriteBack, [],
    [```asm add t3, t0, a2```],
      [], [], [], Fetch, Decode, [], RegRead,
      Exec, [], [], WriteBack
    ));
]

#slide[
  = Out of order (OOO)
  #let Fetch = table.cell(fill: green.lighten(60%))[F];
  #let Decode = table.cell(fill: red.lighten(60%))[D];
  #let Issue = table.cell(fill: maroon.lighten(60%))[I];
  #let Exec = table.cell(fill: blue.lighten(60%))[Ex];
  #let WriteBack = table.cell(fill: purple.lighten(60%))[Wb];
  #let Commit = table.cell(fill: yellow.lighten(50%))[C];

  #show table.cell: it => strong(it)

  #align(center, table(
    columns: (auto, auto, auto, auto, auto, auto, auto, auto, auto, auto, auto, auto),
    fill: (x, y) => if x == 0 or y == 0 { gray.lighten(20%) } else { gray.lighten(50%) },
    stroke: none,
    gutter: 0.2cm,
    align: horizon,
    //gutter: 1cm,
    inset: 0.4cm,
    [Out-of-order], [$t_0$], [$t_1$], [$t_2$], [$t_3$],
    [$t_4$], [$t_5$], [$t_6$], [$t_7$], [$t_8$],
    [$t_9$], [$t_10$],
    [```asm add t0, a1, a2```],
      Fetch, Decode, Issue, Exec, WriteBack, Commit,
      [], [], [], [], [],
    [```asm lw t1, 0(t0)```],
      [],
      Fetch, Decode, Issue, Issue, Exec, Exec, WriteBack, Commit,
      [], [],
    [```asm mul t2, a1, a2```],
      [], [],
      Fetch, Decode, Issue, Exec, Exec, Exec, WriteBack, Commit,
      [],
    [```asm add t3, t0, a2```],
      [], [], [],
      Fetch, Decode, Issue, Exec, WriteBack, [], [], Commit,
    ));

  Cette exemple est simplifier car en pratique on fait Issue/Register Read en deux stages...
]

#slide[
  #let Fetch = green.lighten(60%);
  #let Decode = red.lighten(60%);
  #let Issue = maroon.lighten(60%);
  #let RegRead = yellow.lighten(50%);
  #let Exec = blue.lighten(60%);
  #let WriteBack = purple.lighten(60%);
  #let Commit = black.lighten(60%);

  #v(-1cm)
  #set text(size: 15pt)
  #set align(center)
  #DOoOM
]
