divert(-1) 
`%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
`returns $1 aligned according to $2'
define(`align_d', `eval(((($1 + $2 - 1)/ $2) * $2))')
`%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
define(`local_var', `!local variables define(`last_sym', 0)')
define(`var', `define(`last_sym', 
eval((last_sym - ifelse($3,,$2,$3)) & -$2)) $1 = last_sym')

define(`begin_main',`.global	main
	.align	4
main:	save	%sp, eval(( -92 ifdef(`last_sym',` last_sym')) & -8), %sp')

define(`end_main',`mov	1, %g1
	ta	 0')

`%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
`stack offset definitions'
define(`struct_s', 64)
`define stack offset for the n th. argument, $1, starting at 1'
define(arg_d,`eval($1 * 4 + struct_s)')

`%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
`define which also prints an assembly language comment'
define(`cdef',`define(`$1', `$2')!`$1 = $2 $3'')
define(comment)

`%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
`subroutine entry, $1 = subroutine name'
define(begin_fn,`.global	$1
	.align	4
$1:	save	%sp, eval( -92 ifdef(`last_sym',` last_sym') & -8), %sp
undefine(`last_sym')define(`name_of_funct',$1)')

`subroutine end, return sequence,
 $1 = subroutine name, $2 = src1, $3 = src2 or imm, $4 = dst'
define(end_fn,`ifelse(
$1,name_of_funct,`ret
	restore' `ifelse($2,,,	`$2, $3, $4')'
	.type	name_of_funct`,' #function
	.size	name_of_funct`,' . - name_of_funct`'undefine(`name_of_funct')
,`
errprint(`	subroutine begin does not match end')')')

`%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
`begin defining the fields of a structure'
`$1 = struct name'
define(begin_struct, `!`define' structure $1
define(`size_of_struct',0)define(
`name_of_struct',$1)define(
`align_of_struct', 0)')

`define a field of a struct'
`$1 = name of field, $2 = alignment, $3 if present number of bytes'
define(field, `name_of_struct`_'$1 = align_d(
	size_of_struct,$2)define(
		`size_of_struct', eval(align_d(size_of_struct,$2) 
   + ifelse($3,,$2,$3)))define(
   `align_of_struct', ifelse( 
   eval($2 > align_of_struct),1,$2,align_of_struct))')

`end definition of a struct'
`$1 = name, defines size_of_$1 to be the size in bytes aligned to
align_of_struct'
define(`end_struct', `ifelse(
$1,name_of_struct,`define(
`size_of_$1',align_d(size_of_struct, align_of_struct)) define(
`align_of_$1',align_of_struct)
	!`align_of_$1', align_of_$1 bytes
	!`size_of_$1', size_of_$1 bytes',`
errprint(`	structure begin does not match end')')')
`%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
`convert a decimal number into reverse binary, i.e. lsb as msb'
define(convert_d,`ifelse(eval($1/2),0,$1,
`eval($1 % 2)convert_d(eval($1 /2))')')

`generate code to multiply by number in terms of shifts < and adds +'
define(translate_d,
`ifelse($1,,,substr($1,0,1),1,`+<translate_d(substr($1,1))',
`<translate_d(substr($1,1))')')

`detect where to apply booth_d recoding'
define(booth_d,
  `ifelse($1,,,
    `ifelse($1,<,,substr($1,0,4),+<+<,`-<<gobble_d(substr($1,4))',
			  `substr($1,0,1)booth_d(substr($1,1))')')')

`gobble_d up rest of string of <'s'
define(gobble_d,
  `ifelse($1,,+,
    `ifelse(substr($1,0,2),+<,`<gobble_d(substr($1,2))',
			 `+<booth_d(substr($1,1))')')')
`digits of a base 30 number system'
define(code_d,0123456789!@$%^&*=~|\/<>{}[]:;")

`translate_d <<< into counts'
define(compact_d,`ifelse($1,,,
 `ifelse(substr($1,0,1),<,`count_d($1,0)',
`substr($1,0,1)compact_d(substr($1,1))')')')

`counts strings of <<< in base 30'
define(count_d,
 `ifelse(substr($1,0,1),<,`count_d(substr($1,1),incr($2))',
`substr(code_d,$2,1)compact_d($1)')')

`%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
`cmul (1=multiplicand register, 2=constant multiplier, 
       3=temp, 4 = product)'
define(cmul,
`ifelse($4,,`errprint(
`cmul usage: multiplicand reg, const mult, temp reg, prod reg')',
substr($2,0,1),-,`errprint(`positive constants only')',
$1,$3,`errprint(`cmul: multiplicand and temp registers must be different')',
$3,$4,`errprint(`cmul: temp and product registers must be different')',
index(0123456789, substr($2,0,1)),-1,`errprint(
`cmul: attempt to covert non numeric constant')',
`
			    !start open coded multiply for
			    !$4 = $1 * eval($2), using $3 as temp
	start_d($1,compact_d(booth_d(translate_d(convert_d(eval($2))))),$3,$4)
			    ! `end' open coded multiply
')')

`generates the beginning of multiply code'
`$1 = multiplicand, $2 = string, $3 = temp, $4 = prod'
define(start_d,
`ifelse($2,,`clr	$4',
$2,+,`ifelse($1,$4,,`mov	$1, $4')',
len($2),2,`sll	$1,   index(code_d,substr($2,0,1)), $4',
substr($2,1,1),+,`sll	$1,   index(code_d,substr($2,0,1)), $4
	sll	$4,   index(code_d,substr($2,2,1)), $3
generate_d(substr($2,3),$3,$4)',
substr($2,1,1),-,`sll	$1,   index(code_d, substr($2,0,1)), $4
	sll	$4,   index(code_d, substr($2,2,1)), $3
	sub	$3, $4, $4
generate_d(substr($2,4),$3,$4)',
substr($2,0,1),+,`ifelse(
substr($2,2,1),+,`sll	$1,   index(code_d,substr($2,1,1)), $3
	add	$3, $1, $4',
`sll	$1,   index(code_d,substr($2,1,1)), $3
	sub	$1, $3, $4')
generate_d(substr($2,3),$3,$4)',
`sll	$1,   index(code_d, substr($2,1,1)), $3
	sub	$3, $1, $4
generate_d(substr($2,3),$3,$4)')')

`generates tail of code'
`$1 = string, $2 = temp, $3 = prod'
define(generate_d,
`ifelse($1,,,
`ifelse(substr($1,0,1),+,`	add	$3, $2, $3
generate_d(substr($1,1),$2,$3)',
substr($1,0,1),-,`	sub	$3, $2, $3
generate_d(substr($1,1),$2,$3)',
`	sll	$2,   index(code_d,substr($1,0,1)), $2
generate_d(substr($1,1),$2,$3)')')')
divert dnl
