extensions [palette]
__includes["voter.nls" "main.nls" "group.nls" "global-mean.nls"]

to get-groups

  let create-group? false
  let new-group-numbers []
  ask voters [

    find-neighbours

    ifelse not in-group?
    [
      if count neighbours with [not in-group?] > minimum-group[
        if random 5000 < group-creation%[
          set current current + 1
          set in-group? true
          set v_group-number current
          ;set new-group-numbers insert-item 0 new-group-numbers current
          set new-group-numbers lput current new-group-numbers
          set num-groups count groups
          set create-group? true

          ask neighbours[
            if not in-group? [
              set v_group-number current
              set in-group? true
            ]
          ]
        ]
      ]
    ]

    [
      let my-group-number v_group-number
      ask neighbours [
        if not in-group?[
          if not member? my-group-number v_old-groups [
            let rand random 100
            if rand < 20 [
              set v_group-number my-group-number
              set in-group? true
            ]
          ]
        ]

      ]
    ]



  ]

  if create-group?[
    foreach new-group-numbers [
      [x] ->
      create-groups 1 [
      setup-group
      set group-number x
      ]
    ]
    set new-group-numbers []
  ]

  set num-groups count groups

end

to get-group-means
  ask groups [
    get-group-mean
  ]
end

to move-voters
  ask voters [
    move-voter
  ]
end

to exit-group-voters
  ask voters [
    exit-group?
  ]
end

to get-voters-mean
  set meanx 0
  set meany 0

  ask voters [
    set meanx meanx + xcor
    set meany meany + ycor
  ]

  set meanx meanx / count voters
  set meany meany / count voters

  ask global-means[
      set xcor meanx
      set ycor meany
  ]

 let mean-movementx meanx - initial-meanx
 let mean-movementy meany - initial-meany

 set mean-movement sqrt((mean-movementx * mean-movementx) + (mean-movementy * mean-movementy))

end

to get-groups-modularity
  set total-modularity 0
  if num-groups > 0 [
    let temp-total-modularity 0
    ask groups[
      get-group-modularity
      set temp-total-modularity temp-total-modularity + modularity
    ]
    set total-modularity temp-total-modularity / num-groups
    set mean-cohesion (1 - sqrt(total-modularity / max-modularity))
  ]
end

to get-radicalization

  ; Calculate the distance from the origin of every agent
  let total 0
  ask voters [
    set total total + distancexy 0 0
  ]

  ; Set the current radicalization as the mean of distances
  let current-radicalization total / number

  ; Take only the increment since the initial tick as radicalization measurement
  set social-radicalization current-radicalization - initial-social-radicalization
end

to color-voters
  ask voters [color-voter]
end

to replace-voter
  ask one-of voters [die]
  create-voters 1 [
    setup-voter
  ]

end

to clear-groups
  ask groups [
    let this-group-number group-number
    let num-voters count voters with [v_group-number = this-group-number]
    if num-voters < minimum-group[
      ask voters with [v_group-number = this-group-number] [
        set v_group-number 0
        set v_groupx 0
        set v_groupy 0
        set v_group-cohesion 0
        set v_group-modularity 0
        set in-group? false
      ]
      die
    ]
  ]
end

to-report get-others-dist
  let i 0
  let c 0
  let total-dist 0

  ; iterate for every possible pair of agents i and c
  while [i < number][
    let i-dist 0
    let i-number 0
    while [c < number][
      let group-i 0
      let group-c 0

      ; Check that they dont belong to the same group
      ask voter i [set group-i v_group-number]
      ask voter c [set group-c v_group-number]

      if (group-i != group-c) or (group-i = 0)[

        ; If they are from different groups, sum the distance between
        ; those to the total calculated for agent i
        set i-dist i-dist + [distance voter i] of voter c
        set i-number (i-number + 1)
      ]
      set c ( c + 1 )
    ]

    ; divide the total for i between the number of agents calculated
    ifelse i-number = 0
    [
      set total-dist 0
    ]
    [
      set total-dist total-dist + i-dist / i-number
    ]
    set i (i + 1)
    set c 0
  ]

  report (total-dist / number) - initial-others-distance

end
@#$#@#$#@
GRAPHICS-WINDOW
277
107
870
701
-1
-1
13.0
1
10
1
1
1
0
0
0
1
-22
22
-22
22
1
1
1
ticks
30.0

BUTTON
42
67
125
100
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
132
67
215
100
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

MONITOR
1336
411
1439
456
groups
num-groups
0
1
11

SLIDER
42
103
214
136
number
number
0
1000
223.0
1
1
NIL
HORIZONTAL

SLIDER
39
205
211
238
vision
vision
0
15
4.0
1
1
NIL
HORIZONTAL

SWITCH
923
162
1072
195
color-extremism?
color-extremism?
0
1
-1000

SLIDER
38
473
210
506
b-polarization%
b-polarization%
0
100
25.0
1
1
NIL
HORIZONTAL

SLIDER
38
403
210
436
group-effect%
group-effect%
0
100
20.0
1
1
NIL
HORIZONTAL

SLIDER
38
543
210
576
voters-random%
voters-random%
0
100
0.0
1
1
NIL
HORIZONTAL

SLIDER
39
240
211
273
group-creation%
group-creation%
0
100
37.0
1
1
NIL
HORIZONTAL

PLOT
925
239
1329
389
Mean Displacement
time
mean-movement
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"mean displacement" 1.0 0 -16777216 true "" "plot mean-movement"

MONITOR
1335
292
1439
337
NIL
total-modularity
5
1
11

PLOT
1131
568
1436
718
Mean Group Modularity
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot total-modularity"

MONITOR
1335
240
1439
285
NIL
mean-movement
5
1
11

SLIDER
38
438
210
471
u-polarization%
u-polarization%
0
100
29.0
1
1
NIL
HORIZONTAL

PLOT
1130
411
1330
561
Social Radicalization
NIL
NIL
0.0
10.0
-1.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot social-radicalization"

PLOT
924
568
1124
718
Mean Group Cohesion
NIL
NIL
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean-cohesion"

MONITOR
1335
344
1438
389
mean-cohesion
mean-cohesion
5
1
11

SLIDER
38
508
210
541
social-stability%
social-stability%
0
100
10.0
1
1
NIL
HORIZONTAL

SLIDER
39
615
211
648
extremism-mean
extremism-mean
0
100
51.0
1
1
NIL
HORIZONTAL

SLIDER
39
651
211
684
extremism-sd
extremism-sd
0
100
22.0
1
1
NIL
HORIZONTAL

SWITCH
1080
162
1229
195
color-influentiability?
color-influentiability?
1
1
-1000

SLIDER
39
687
211
720
influentiability-mean
influentiability-mean
0
100
45.0
1
1
NIL
HORIZONTAL

SLIDER
39
723
211
756
influentiability-sd
influentiability-sd
0
100
15.0
1
1
NIL
HORIZONTAL

BUTTON
1239
162
1337
195
color-voters
color-voters
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
39
276
211
309
group-disgregation%
group-disgregation%
0
100
8.0
1
1
NIL
HORIZONTAL

TEXTBOX
39
594
226
626
PERSONALITY PARAMETERS
13
0.0
1

MONITOR
1337
462
1440
507
Interdistance
others-distance
3
1
11

SWITCH
923
125
1072
158
paint-links?
paint-links?
1
1
-1000

SWITCH
1080
125
1229
158
get-others-dist?
get-others-dist?
1
1
-1000

TEXTBOX
40
179
190
197
GROUP PARAMETERS
13
0.0
0

TEXTBOX
39
381
189
399
INFLUENCE FORCES
13
0.0
1

TEXTBOX
41
40
191
60
SIMULATION
16
0.0
1

TEXTBOX
926
211
1228
243
SIMULATION MEASUREMENTS
16
0.0
1

PLOT
924
411
1124
561
Agents Interdistance
NIL
others-distance
0.0
10.0
4.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot others-distance"

TEXTBOX
923
90
1251
130
VISUALIZATION OPTIONS
16
0.0
1

SLIDER
39
312
211
345
minimum-group
minimum-group
0
15
8.0
1
1
NIL
HORIZONTAL

MONITOR
1338
512
1441
557
Radicalization
social-radicalization
3
1
11

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="partidismo-extremism" repetitions="30" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="401"/>
    <metric>mean-movement</metric>
    <metric>others-distance</metric>
    <metric>mean-cohesion</metric>
    <metric>total-modularity</metric>
    <metric>social-radicalization</metric>
    <metric>num-groups</metric>
    <enumeratedValueSet variable="group-disgregation%">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-stability%">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="color-extremism?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="223"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="influentiability-mean">
      <value value="45"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="group-effect%">
      <value value="27"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vision">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-group">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="influentiability-sd">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="b-polarization%">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="group-creation%">
      <value value="23"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="get-others-dist?">
      <value value="false"/>
    </enumeratedValueSet>
    <steppedValueSet variable="extremism-mean" first="0" step="1" last="100"/>
    <enumeratedValueSet variable="u-polarization%">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="extremism-sd">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="color-influentiability?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voters-random%">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="paint-links?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="partidismo-stability" repetitions="30" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="401"/>
    <metric>mean-movement</metric>
    <metric>others-distance</metric>
    <metric>mean-cohesion</metric>
    <metric>total-modularity</metric>
    <metric>social-radicalization</metric>
    <metric>num-groups</metric>
    <enumeratedValueSet variable="group-disgregation%">
      <value value="0"/>
    </enumeratedValueSet>
    <steppedValueSet variable="social-stability%" first="0" step="1" last="100"/>
    <enumeratedValueSet variable="color-extremism?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="223"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="influentiability-mean">
      <value value="45"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="group-effect%">
      <value value="27"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vision">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-group">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="influentiability-sd">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="b-polarization%">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="group-creation%">
      <value value="23"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="get-others-dist?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="extremism-mean">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="u-polarization%">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="extremism-sd">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="color-influentiability?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voters-random%">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="paint-links?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="partidismo-polB" repetitions="30" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="401"/>
    <metric>mean-movement</metric>
    <metric>others-distance</metric>
    <metric>mean-cohesion</metric>
    <metric>total-modularity</metric>
    <metric>social-radicalization</metric>
    <metric>num-groups</metric>
    <enumeratedValueSet variable="group-disgregation%">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-stability%">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="color-extremism?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="223"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="influentiability-mean">
      <value value="45"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="group-effect%">
      <value value="27"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vision">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-group">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="influentiability-sd">
      <value value="15"/>
    </enumeratedValueSet>
    <steppedValueSet variable="b-polarization%" first="0" step="1" last="100"/>
    <enumeratedValueSet variable="group-creation%">
      <value value="23"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="get-others-dist?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="extremism-mean">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="u-polarization%">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="extremism-sd">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="color-influentiability?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voters-random%">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="paint-links?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="granularity-groupc" repetitions="30" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="401"/>
    <metric>mean-movement</metric>
    <metric>others-distance</metric>
    <metric>mean-cohesion</metric>
    <metric>total-modularity</metric>
    <metric>social-radicalization</metric>
    <metric>num-groups</metric>
    <enumeratedValueSet variable="group-disgregation%">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-stability%">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="color-extremism?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="223"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="influentiability-mean">
      <value value="45"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="group-effect%">
      <value value="27"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vision">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-group">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="influentiability-sd">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="b-polarization%">
      <value value="54"/>
    </enumeratedValueSet>
    <steppedValueSet variable="group-creation%" first="0" step="1" last="100"/>
    <enumeratedValueSet variable="u-polarization%">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="get-others-dist?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="extremism-mean">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="extremism-sd">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="color-influentiability?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="paint-links?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voters-random%">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="granularity-polb" repetitions="30" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="401"/>
    <metric>mean-movement</metric>
    <metric>others-distance</metric>
    <metric>mean-cohesion</metric>
    <metric>total-modularity</metric>
    <metric>social-radicalization</metric>
    <metric>num-groups</metric>
    <enumeratedValueSet variable="group-disgregation%">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-stability%">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="color-extremism?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="223"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="influentiability-mean">
      <value value="45"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="group-effect%">
      <value value="27"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vision">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-group">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="influentiability-sd">
      <value value="15"/>
    </enumeratedValueSet>
    <steppedValueSet variable="b-polarization%" first="0" step="1" last="100"/>
    <enumeratedValueSet variable="group-creation%">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="u-polarization%">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="get-others-dist?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="extremism-mean">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="extremism-sd">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="color-influentiability?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="paint-links?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voters-random%">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="granularity-polb_exit" repetitions="30" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="401"/>
    <metric>mean-movement</metric>
    <metric>others-distance</metric>
    <metric>mean-cohesion</metric>
    <metric>total-modularity</metric>
    <metric>social-radicalization</metric>
    <metric>num-groups</metric>
    <enumeratedValueSet variable="group-disgregation%">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-stability%">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="color-extremism?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="223"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="influentiability-mean">
      <value value="45"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="group-effect%">
      <value value="27"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vision">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-group">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="influentiability-sd">
      <value value="15"/>
    </enumeratedValueSet>
    <steppedValueSet variable="b-polarization%" first="0" step="1" last="100"/>
    <enumeratedValueSet variable="group-creation%">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="u-polarization%">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="get-others-dist?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="extremism-mean">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="extremism-sd">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="color-influentiability?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="paint-links?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voters-random%">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="extremism-sd" repetitions="30" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="400"/>
    <metric>mean-movement</metric>
    <metric>others-distance</metric>
    <metric>mean-cohesion</metric>
    <metric>total-modularity</metric>
    <metric>social-radicalization</metric>
    <metric>num-groups</metric>
    <enumeratedValueSet variable="group-disgregation%">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-stability%">
      <value value="34"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="color-extremism?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="223"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="influentiability-mean">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="group-effect%">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vision">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-group">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="influentiability-sd">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="b-polarization%">
      <value value="35"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="group-creation%">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="u-polarization%">
      <value value="35"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="extremism-mean">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="get-others-dist?">
      <value value="false"/>
    </enumeratedValueSet>
    <steppedValueSet variable="extremism-sd" first="0" step="1" last="100"/>
    <enumeratedValueSet variable="color-influentiability?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voters-random%">
      <value value="11"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="paint-links?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="influentiability-sd" repetitions="30" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="400"/>
    <metric>mean-movement</metric>
    <metric>others-distance</metric>
    <metric>mean-cohesion</metric>
    <metric>total-modularity</metric>
    <metric>social-radicalization</metric>
    <metric>num-groups</metric>
    <enumeratedValueSet variable="group-disgregation%">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-stability%">
      <value value="34"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="color-extremism?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="223"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="influentiability-mean">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="group-effect%">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vision">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-group">
      <value value="3"/>
    </enumeratedValueSet>
    <steppedValueSet variable="influentiability-sd" first="0" step="1" last="100"/>
    <enumeratedValueSet variable="b-polarization%">
      <value value="35"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="group-creation%">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="u-polarization%">
      <value value="35"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="extremism-mean">
      <value value="35"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="get-others-dist?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="extremism-sd">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="color-influentiability?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voters-random%">
      <value value="11"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="paint-links?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="extremism-sd" repetitions="30" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="400"/>
    <metric>mean-movement</metric>
    <metric>others-distance</metric>
    <metric>mean-cohesion</metric>
    <metric>total-modularity</metric>
    <metric>social-radicalization</metric>
    <metric>num-groups</metric>
    <enumeratedValueSet variable="group-disgregation%">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-stability%">
      <value value="34"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="color-extremism?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="223"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="influentiability-mean">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="group-effect%">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vision">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-group">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="influentiability-sd">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="b-polarization%">
      <value value="35"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="group-creation%">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="u-polarization%">
      <value value="35"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="extremism-mean">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="get-others-dist?">
      <value value="false"/>
    </enumeratedValueSet>
    <steppedValueSet variable="extremism-sd" first="0" step="1" last="100"/>
    <enumeratedValueSet variable="color-influentiability?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voters-random%">
      <value value="11"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="paint-links?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="extremism-sd_dificil" repetitions="30" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="400"/>
    <metric>mean-movement</metric>
    <metric>others-distance</metric>
    <metric>mean-cohesion</metric>
    <metric>total-modularity</metric>
    <metric>social-radicalization</metric>
    <metric>num-groups</metric>
    <enumeratedValueSet variable="group-disgregation%">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-stability%">
      <value value="34"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="color-extremism?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="223"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="influentiability-mean">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="group-effect%">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vision">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-group">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="influentiability-sd">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="b-polarization%">
      <value value="35"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="group-creation%">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="u-polarization%">
      <value value="35"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="extremism-mean">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="get-others-dist?">
      <value value="false"/>
    </enumeratedValueSet>
    <steppedValueSet variable="extremism-sd" first="0" step="1" last="100"/>
    <enumeratedValueSet variable="color-influentiability?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voters-random%">
      <value value="11"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="paint-links?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="influentiability-sd_dificil" repetitions="30" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="400"/>
    <metric>mean-movement</metric>
    <metric>others-distance</metric>
    <metric>mean-cohesion</metric>
    <metric>total-modularity</metric>
    <metric>social-radicalization</metric>
    <metric>num-groups</metric>
    <enumeratedValueSet variable="group-disgregation%">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-stability%">
      <value value="34"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="color-extremism?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="223"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="influentiability-mean">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="group-effect%">
      <value value="35"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vision">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-group">
      <value value="3"/>
    </enumeratedValueSet>
    <steppedValueSet variable="influentiability-sd" first="0" step="1" last="100"/>
    <enumeratedValueSet variable="b-polarization%">
      <value value="35"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="group-creation%">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="u-polarization%">
      <value value="35"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="extremism-mean">
      <value value="35"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="get-others-dist?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="extremism-sd">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="color-influentiability?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voters-random%">
      <value value="11"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="paint-links?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="extremism" repetitions="30" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="400"/>
    <metric>mean-movement</metric>
    <metric>others-distance</metric>
    <metric>mean-cohesion</metric>
    <metric>total-modularity</metric>
    <metric>social-radicalization</metric>
    <metric>num-groups</metric>
    <enumeratedValueSet variable="group-disgregation%">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-stability%">
      <value value="27"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="color-extremism?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="223"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="influentiability-mean">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="group-effect%">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vision">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-group">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="influentiability-sd">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="b-polarization%">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="group-creation%">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="u-polarization%">
      <value value="17"/>
    </enumeratedValueSet>
    <steppedValueSet variable="extremism-mean" first="0" step="1" last="100"/>
    <enumeratedValueSet variable="get-others-dist?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="extremism-sd">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="color-influentiability?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voters-random%">
      <value value="11"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="paint-links?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="granularity-polu" repetitions="30" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="401"/>
    <metric>mean-movement</metric>
    <metric>others-distance</metric>
    <metric>mean-cohesion</metric>
    <metric>total-modularity</metric>
    <metric>social-radicalization</metric>
    <metric>num-groups</metric>
    <enumeratedValueSet variable="group-disgregation%">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-stability%">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="color-extremism?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="223"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="influentiability-mean">
      <value value="45"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="group-effect%">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vision">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-group">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="influentiability-sd">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="b-polarization%">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="group-creation%">
      <value value="50"/>
    </enumeratedValueSet>
    <steppedValueSet variable="u-polarization%" first="0" step="1" last="100"/>
    <enumeratedValueSet variable="get-others-dist?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="extremism-mean">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="extremism-sd">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="color-influentiability?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="paint-links?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voters-random%">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
