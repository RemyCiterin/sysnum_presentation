#import "@preview/cetz:0.3.2"
#import "@preview/circuiteria:0.2.0"
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#import "fifo.typ" : *
#import "dooom.typ" : *
#import "gpu.typ" : *
#import "3driscv.typ" : *

#import circuiteria: *

#import "@preview/polylux:0.4.0": *
#import "@preview/friendly-polylux:0.1.0": (
  setup,
  title-slide,
  titled-block,
  //framed-block,
  //post-it,
)

#let color(c, t) = {emph(text(c, t))}

#show raw.where(lang: "bsv"): it => [
  // Typing keywords
  #show regex("\b(Reg|Vector|Fifo|Bit|F16|FloatingPoint|Int|UInt)\b") : (keyword =>
    text(weight:"bold", fill: olive, keyword))

  #show regex("#") : (keyword => text(weight:"bold", fill: olive, keyword))

  /////////////////////////////////////////////////
  // Display an integer
  /////////////////////////////////////////////////
  #show regex("\b([0-9]+)\b") : (number =>
    text(weight: "bold", fill: red, number))

  #show regex("\b[0-9]\'b([0-9]+)\b") : (number =>
    text(weight: "bold", fill: red, number))

  #show regex("\b[0-9]\'h([0-9]+)\b") : (number =>
    text(weight: "bold", fill: red, number))

  #show regex("\b[0-9]\'d([0-9]+)\b") : (number =>
    text(weight: "bold", fill: red, number))



  #show regex("\b(module|function|interface|method|endmodule|endfunction|endinterface|endmethod|rule|endrule|typedef|deriving)\b") : (keyword =>
    text(weight:"bold", fill: blue, keyword))

  #show regex("\b(begin|for|if|end|let|action|endaction|actionvalue|endactionvalue|union|tagged|enum|struct|case|endcase|matches|match|return|while|seq|endseq|par|endpar)\b") : (keyword =>
    text(weight:"bold", fill: blue, keyword))
  #it
]


#show math.equation: set text(
  font: "New Computer Modern Math",
  weight: "light",
)

#set text(
  size: 20pt,
  fill: blue.darken(50%),
)

#show raw: set text(font: "New Computer Modern")

#show: setup.with(
  short-title: [],
  short-speaker: []
)

//#title-slide[FPGA : du registre à DOOM][
//
//  Rémy Citérin
//
//  25/11/2025, Paris
//]
#title-slide(
  title: [FPGA : du registre à DOOM],
  speaker: [Rémy Citérin],
  slides-url: "https://github.com/RemyCiterin/sysnum_presentation",
  qr-caption: text(font: "Excalifont")[Lien vers les slides],
  logo: none
)


#slide[
  = Au menu
  - Ray-tracing
  #v(25pt)
  - DOOM
  #v(25pt)
  - UNIX
  #v(25pt)
  - GPU
]

#slide[
  = Accélérateur de Ray-Tracing

  #v(1cm)
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
  = Accélérateur de Ray-Tracing

  #v(1cm)
  - $320 * 240 = 76800$ pixels
  - $240$ triangles, on a besoin de calculer $18$ millions d'intersections par image
  - $19$ additions, $27$ multiplications et une division par intersections
  #show: later
  #text(
    fill: red, [
      On overflow le nombre de multiplieurs du FPGA même pour avoir $10$ FPS...

      On a besoin de:
      + Meilleurs algorithmes pour économiser des intersections
      + Algorithmes d'intersections plus efficaces ($9$ multiplications dans mon cas)
  ])
]

#slide[
  = Bonding Volume Hierarchy

  #v(1cm)
  #grid(
    columns: 2,

    cetz.canvas({
      import cetz.draw: *

      let bounds(x,y,z) = {
        let min_x = calc.min(x.at(0), y.at(0), z.at(0))-0.2
        let min_y = calc.min(x.at(1), y.at(1), z.at(1))-0.2
        let max_x = calc.max(x.at(0), y.at(0), z.at(0))+0.2
        let max_y = calc.max(x.at(1), y.at(1), z.at(1))+0.2
        ((min_x, min_y), (max_x, max_y))
      }

      let merge(b1, b2) = {
        let ((min1_x, min1_y),(max1_x, max1_y)) = b1
        let ((min2_x, min2_y),(max2_x, max2_y)) = b2
        (
          (calc.min(min1_x, min2_x)-0.2, calc.min(min1_y, min2_y)-0.2),
          (calc.max(max1_x, max2_x)+0.2, calc.max(max1_y, max2_y)+0.2)
        )
      }

      let (a, b, c) = ((-1,1), (2,0), (0.4,-1))
      let bounds_abc = bounds(a, b, c)

      let (d, e, f) = ((2,0), (4,0), (0,5))
      let bounds_def = bounds(d, e, f)

      let (g, h, i) = ((5,3), (3,3), (8,6))
      let bounds_ghi = bounds(g, h, i)

      let bounds_abcdef = merge(bounds_abc, bounds_def)
      let bounds_abcdefghi = merge(bounds_abcdef, bounds_ghi)


      line(a,b,c,a, fill: blue, stroke: blue, name: "A")
      line(d,e,f,d, fill: blue, stroke: blue, name: "B")
      line(g,h,i,g, fill: blue, stroke: blue, name: "C")
      rect(
        bounds_ghi.at(0),
        bounds_ghi.at(1),
        stroke: (thickness: 2pt)
      )
      rect(
        bounds_abc.at(0),
        bounds_abc.at(1),
        stroke: (thickness: 2pt),
      )
      rect(
        bounds_abcdefghi.at(0),
        bounds_abcdefghi.at(1),
        stroke: (thickness: 2pt, paint: olive),
      )
      rect(
        bounds_abcdef.at(0),
        bounds_abcdef.at(1),
        stroke: (thickness: 2pt, paint: olive),
      )
      rect(
        bounds_def.at(0),
        bounds_def.at(1),
        stroke: (thickness: 2pt, paint: olive),
      )

      content("A.centroid", text(size: 25pt, fill: black, [A]))
      content("B.centroid", text(size: 25pt, fill: black, [B]))
      content("C.centroid", text(size: 25pt, fill: black, [C]))

      line((-3,2.5), (10, 2), stroke: (paint: red, thickness: 2pt), mark: (end: ">"))
    }),
    [
      En utilisant $3$ intersections rayon/box on peut déterminer que seulement une des
      intersections rayon/triangle est nécessaire au lieu de $3$!
      #align(center,
        cetz.canvas({
          import cetz.tree
          import cetz.draw: *
          tree.tree(
            grow: 1.5,
            spread: 2.5,
            ([h], ([h], ([m], [mA]), ([h], [hB])), ([m], [mC])),
            draw-node: (node, ..) => {
              let hit = node.content.text.at(0) == "h"
              let c = if hit {olive} else {black}
              circle((), radius: .5, fill: c, stroke: none)
              content((), text(white, node.content.text.slice(1)))
            },
            draw-edge: (from, to, ..) => {
              let (a, b) = (from + ".center", to + ".center")
              line((a, .4, b), (b, .4, a))
            },
          )
        })
      )
    ]
  )
]

#slide[
  = Bonding Volume Hierarchy

  #v(1cm)
  #toolbox.side-by-side[
    ```bsv
    while (notDone) seq
      node <= nodes.read;
      tmin <= rayonNodeIntersection(node, ray);

      action
        if (tmin < currentHit.t && node.isLeaf)
          intersectQ.enq(tuple2(node.firstTri, node.length));

        if (tmin < currentHit.t && !node.isLeaf) begin
          nodes.readRequest(node.leftChild+1);
          stack.push(node.leftChild);
        end
    ```
  ][
    ```bsv
        // Backtrack
        if (tmin >= currentHit.t || node.isLeaf) begin
          notDone <= !stack.empty;
          if (!stack.empty) begin
            nodes.readRequest(stack.read);
            stack.pop;
          end
        end
      endaction
    endseq
    ```
  ]
]

#slide[
  = Möller-Trumbore
  #align(center, [
    ```c
    void intersect(triangle_t* tri, ray_t* ray) {
      float3 edge1 = tri->vertex1 - tri->vertex0;
      float3 edge2 = tri->vertex2 - tri->vertex0;
      float3 h = cross3(ray->direction, edge2);
      float a = dot3(edge1, h);
      float f = 1.0 / a;
      float3 s = ray->origin - tri->vertex0;
      float u = f * dot3(s, h);
      float q = cross3(s, edge1);
      float v = f * dot3(ray->direction, q);
      float t = f * dot3(edge2, q);

      // (u,v,1-u-v) : barycentric coordinate of the intersection in the triangle
      // origin + ray->direction * t : coordinate of the intersection
      ...
    }
    ```
  ])
]

#slide[
  = Réseau systolic : produit scalaire en hardware
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

  #v(1cm)
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

  #v(1cm)
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
    #titled-block(title: [En bref])[
      - $approx 9000$ lignes de Bluespec
      - $approx 30$MHz sur un EPC5
      - $approx 30$K 4-LUT sur un EPC5
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
      Fetch, Decode,
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
    columns: 14,
    fill: (x, y) => if x == 0 or y == 0 { gray.lighten(20%) } else { gray.lighten(50%) },
    stroke: none,
    gutter: 0.2cm,
    align: horizon,
    //gutter: 1cm,
    inset: 0.4cm,
    [Pipelined], [$t_0$], [$t_1$], [$t_2$], [$t_3$],
    [$t_4$], [$t_5$], [$t_6$], [$t_7$], [$t_8$],
    [$t_9$], [$t_10$], [$t_11$], [$t_12$],
    [```asm add t0, a1, a2```],
      Fetch, Decode, RegRead, Exec, WriteBack,
      [], [], [], [], [], [], [], [],
    [```asm lw t1, 0(t0)```],
      [],
      Fetch, Decode, [], RegRead, Exec, Exec, WriteBack,
      [], [], [], [], [],
    [```asm mul t2, a1, a2```],
      [], [], Fetch,
      Decode, [], RegRead,
      Exec, Exec, Exec, WriteBack, [], [], [],
    [```asm add t3, t0, a2```],
      [], [], [], Fetch, Decode, [], RegRead,
      Exec, [], [], WriteBack, [], [],
    [```asm addi t3, t3, 42```],
      [], [], [], [], Fetch, Decode,
      [], [], [], [], RegRead, Exec, WriteBack
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

  // #show table.cell: it => strong(it)

  #align(center, table(
    columns: 13,
    fill: (x, y) => if x == 0 or y == 0 { gray.lighten(20%) } else { gray.lighten(50%) },
    stroke: none,
    gutter: 0.2cm,
    align: horizon,
    //gutter: 1cm,
    inset: 0.4cm,
    [Out-of-order], [$t_0$], [$t_1$], [$t_2$], [$t_3$],
    [$t_4$], [$t_5$], [$t_6$], [$t_7$], [$t_8$],
    [$t_9$], [$t_10$], [$t_11$],
    [```asm add t0, a1, a2```],
      Fetch, Decode, Issue, Exec, WriteBack, Commit,
      [], [], [], [], [], [],
    [```asm lw t1, 0(t0)```],
      [],
      Fetch, Decode, Issue, Issue, Exec, Exec, WriteBack, Commit,
      [], [], [],
    [```asm mul t2, a1, a2```],
      [], [],
      Fetch, Decode, Issue, Exec, Exec, Exec, WriteBack, Commit,
      [], [],
    [```asm add t3, t0, a2```],
      [], [], [],
      Fetch, Decode, Issue, Exec, WriteBack, [], [], Commit, [],
    [```asm addi t3, t3, 42```],
      [], [], [], [], Fetch, Decode, Issue, Issue, Exec, WriteBack,
      [], Commit
  ));
]

#slide[
  #let Fetch = green.lighten(60%);
  #let Decode = red.lighten(60%);
  #let Issue = maroon.lighten(60%);
  #let RegRead = yellow.lighten(50%);
  #let Exec = blue.lighten(60%);
  #let WriteBack = purple.lighten(60%);
  #let Commit = black.lighten(60%);

  #v(1cm)
  #set text(size: 15pt)
  #set align(center)
  #DOoOM
]

#slide[
  = 3DRiscV : Un Soc avec CPU + GPU

  #v(1cm)
  #toolbox.side-by-side[
    Un RISC-V in-order avec :
    - Multiplication/Division
    - Prédiction de branche
    - Caches L1i et L1d cohérents avec le GPU
    - MMU (Testé avec UNIX-v6)
    - VGA, SD-CARD, UART
    - 32MB de SDRAM

    Un GPU basé sur RISC-V avec :
    - 16 warp de 4 threads\ (max 4 instructions par cycle)
    - Multiplication/Division
    - Fusion des opérations mémoire
    - Caches L1i et L1d
  ][
    #titled-block(title: [En bref])[
      - $approx 8500$ lignes de Haskell + \
        $approx 6700$ lignes de Rust pout le \
        compilateur (optimisant) du GPU
      - $approx 30$MHz sur un EPC5
      - $approx 50$K 4-LUT sur un EPC5
    ]
  ]
]

#slide[
  = 3DRiscV : Un Soc avec CPU + GPU
  #RiscV3D
]

#slide[
  = GPU : streaming machine

  On exécute 16 *warp* de 4 threads en même parallèle avec #color(red, [*le même pointeur d'instruction*])
  - Jusqu'à 4 instructions peuvent retourner en même temps
  - Pas de dépendance entre les registres

  #let Schedule = table.cell(fill: orange.lighten(60%))[S];
  #let Fetch = table.cell(fill: green.lighten(60%))[F];
  #let Decode = table.cell(fill: red.lighten(60%))[D];
  #let RegRead = table.cell(fill: yellow.lighten(50%))[Rr];
  #let Exec = table.cell(fill: blue.lighten(60%))[Ex];
  #let WriteBack = table.cell(fill: purple.lighten(60%))[Wb];

  #align(center, table(
    columns: 12,
    fill: (x, y) => if x == 0 or y == 0 { gray.lighten(20%) } else { gray.lighten(50%) },
    stroke: none,
    gutter: 0.2cm,
    align: horizon,
    //gutter: 1cm,
    inset: 0.4cm,
    [Instruction], [warp/mask], [$t_0$], [$t_1$], [$t_2$], [$t_3$],
    [$t_4$], [$t_5$], [$t_6$], [$t_7$], [$t_8$], [$t_9$],
    [```asm add t0, a1, a2```], [0/0101],
      Schedule, Fetch, Decode, RegRead, Exec, WriteBack,
      [], [], [], [],
    [```asm lw t1, 0(t0)```], [1/1111],
      [],
      Schedule, Fetch, Decode, RegRead, Exec, Exec, Exec, WriteBack,
      [],
    [```asm add t0, a1, a2```], [0/1010],
      [], [],
      Schedule, Fetch, Decode, RegRead, Exec, WriteBack,
      [], [],
    [```asm div t0, a1, a2```], [13/0001],
      [], [], [],
      Schedule, Fetch, Decode, RegRead, Exec, Exec, WriteBack,
    ));
]


#slide[
  = GPU : streaming machine
  #align(center, grid(columns: 3,
    gutter: 2cm,
    [
      *Entrée :*
      ```c
      foo(x, y, z) {
        if (x == 0) {
          y = y + 1;
        } else {
          z = z + 1;
        }
        y = y / z;
        return y;
      }
      ```
    ], [
      *Programme compilé :*
      ```asm
      global foo
      foo:
        bnez a0, .else
        addi a1, a1, 1
        j .end_if
      .else:
        addi a2, a2, 1
      .end_if:
        div a0, a1, a2
        ret
      ```
    ], [
      #align(center, table(
        columns: 3,
        fill: (x, y) => if x == 0 or y == 0 { gray.lighten(20%) } else { gray.lighten(50%) },
        stroke: none,
        gutter: 0.2cm,
        align: horizon,
        //gutter: 1cm,
        inset: 0.4cm,
        [cycle], [mask], [Instruction],
        [0], [1111], [```asm bnez a0, .else```],
        [1], [0101], [```asm addi a2, a2, 1```],
        [2], [1010], [```asm addi a1, a1, 1```],
        [3], [0101], [```asm j .end_if```],
        [33], [1010], [```asm div a0, a1, a2```],
        [63], [0101], [```asm div a0, a1, a2```],
      ));
    ]
  ))
]


#slide[
  = GPU : reconvergence de threads

  *Problème :* Après une boucle / un if, les threads n'ont plus les mêmes pointeurs d'instruction!

  #show: later

  On ajoute des instructions pour resynchroniser les threads après un if/for/while :

  #align(center, grid(
    columns: 3,
    gutter: 30pt,
    [
      ```c
      foo(x,y,z) {
        if (x == 0) {
          y = y + 1;
        } else {
          z = z + 1;
        }
        y = y / z;
        return y;
      }
      ```
    ],
    [\ \ \ $=>$],
    [
      ```asm
      global foo
      foo:
        push_level      ; Divergence point
        bnez a0, .else
        addi a1, a1, 1
        j .end_if
      .else:
        addi a2, a2, 1
      .end_if:
        pop_level       ; Convergence point
        div a0, a1, a2
      ```
    ]
  ))

  puis il suffit d'executer seulement les threads dont le `level` est maximale :

  #align(center, [*Les threads qui finissent en premier le `if` attendent les autres*])
]

#slide[
  = GPU : streaming machine
  #align(center, grid(columns: 3,
    gutter: 2cm,
    [
      *Entrée :*
      ```c
      foo(x, y, z) {
        if (x == 0) {
          y = z + 1;
        } else {
          z = z + 1;
        }
        y = y / z;
        return y;
      }
      ```
    ], [
      *Programme compilé :*
      ```asm
      global foo
      foo:
        push_level
        bnez a0, .else
        addi a1, a1, 1
        j .end_if
      .else:
        addi a2, a2, 1
      .end_if:
        pop_level
        div a0, a1, a2
        ret
      ```
    ], [
      #align(center, table(
        columns: 4,
        fill: (x, y) => if x == 0 or y == 0 { gray.lighten(20%) } else { gray.lighten(50%) },
        stroke: none,
        gutter: 0.2cm,
        align: horizon,
        //gutter: 1cm,
        inset: 0.4cm,
        [cycle], [mask], [Instruction], [Level],
        [0], [1111], [```asm push_level```], [1],
        [1], [1111], [```asm bnez a0, .else```], [1],
        [2], [0101], [```asm addi a2, a2, 1```], [1],
        [3], [1010], [```asm addi a1, a1, 1```], [1],
        [4], [0101], [```asm j .end_if```], [1],
        [5], [1010], [```asm pop_level```], [0],
        [6], [0101], [```asm pop_level```], [0],
        [36], [1111], [```asm div a0, a1, a2```], [0],
      ));
    ]
  ))
]

