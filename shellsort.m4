include(macro_defs.m)
define(SIZE, 20)
define(gap_r, l0)
define(i_r, l1)
define(j_r, l2)
define(temp_r, l3)

local_var
var(v_s, 4, 4 * SIZE)         !array v with size = 20

begin_main

mov SIZE, %i_r
ba test1
mov 0, %j_r

loop1:
  add %fp, %o0, %o0             !add fp
  st %j_r, [%o0 + v_s]          !store j into v[i]
  add %j_r, 1, %j_r             !j++

test1:              
  sub %i_r, 1, %i_r             !--i
  cmp %i_r, %g0                 !i>=0
  bge,a loop1
  sll %i_r, 2, %o0              !multiply i by 4


afterinit:
  mov SIZE, %o0                 !gap = SIZE/2
  call .div
  mov 2, %o1
  ba outtest
  mov %o0, %gap_r

innerloop:
  add %fp, %o0, %o0
  ld [%o0 + v_s], %temp_r

  add %j_r, %gap_r, %o0         !v[j+gap]
  sll %o0, 2, %o0
  add %fp, %o0, %o0
  ld [%o0 + v_s], %o0

  sll %j_r, 2, %o1              !v[j]
  add %fp, %o1, %o1
  st %o0, [%o1 + v_s]           !v[j] = v[j + gap]

  add %j_r, %gap_r, %o0         !v[j+gap]
  sll %o0, 2, %o0
  add %fp, %o0, %o0

  st %temp_r, [%o0 + v_s]       !v[j+gap] = temp

  sub %j_r, %gap_r, %j_r        !j -= gap

innertest:
  cmp %j_r, %g0                 !j >= 0
  bl,a midtest
  add %i_r, 1, %i_r             !i++ from middle forloop

  add %j_r, %gap_r, %o0         !v[j + gap]
  sll %o0, 2, %o0         
  add %fp, %o0, %o0
  ld [%o0 + v_s], %o0

  sll %j_r, 2, %o1              !v[j]
  add %fp, %o1, %o1
  ld [%o1 + v_s], %o1

  cmp %o1, %o0                  !v[j] > v[j+gap]

  bl,a midtest
  add %i_r, 1, %i_r             !i++ from middle forloop

  ba innerloop
  sll %j_r, 2, %o0              !first instruction of innerloop


midtest:
  cmp  %i_r, SIZE              !i < SIZE
  bl,a innertest            
  sub %i_r, %gap_r, %j_r       !j = i - gap


  mov %gap_r, %o0              !gap /= 2
  call .div
  mov 2, %o1
  mov %o0, %gap_r

outtest:
  cmp %gap_r, %g0              !gap > 0
  bg,a midtest                 
  mov %gap_r, %i_r             !i = gap

end:
  end_main
