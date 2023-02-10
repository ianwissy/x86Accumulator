TITLE Accumulator     (Proj6_IWYSE.asm)

; Author: Ian Wyse
; Last Modified: 11/21/2021
; OSU email address: wysei@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number:  6        Due Date: 12/5/2021
; Description: Program requests numbers from the user, sums them, calculates the average 
; and prints all given numbers, the sum, and the average to the console.

INCLUDE Irvine32.inc

;-----------------------------------------------------------------------------------------------------------------
; Name: mGetString
;
; Description: Requests a string from the user. Stores the string and its length in memory.
;
; Receives: 
;		prompt = OFFSET number request string
;		strStore = OFFSET string storage location
;		strLength = OFFSET DWORD string length storage location
;
; Returns: 
;		Entered string stored at strStore OFFSET
;		Entered string length stored at strLength
;-----------------------------------------------------------------------------------------------------------------
mGetString MACRO prompt:Req, strStore:Req, strLength:Req
	PUSH	ECX
	PUSH	EDX
	MOV		EDX, prompt
	CALL	WriteString
	MOV		EDX, strStore
	MOV		ECX, 13
	CALL	ReadString
	MOV		strLength, EAX
	POP		EDX
	POP		ECX
ENDM

;--------------------------------------------------------------------------------------------------------------
; Name: mDisplayString
;
; Description: Prints string at stringLoc to console.
;
; Recieves:
;		stringLoc = OFFSET of string to be printed.
;
; Postcondition:
;		String at stringLoc printed to console.
;--------------------------------------------------------------------------------------------------------------
mDisplayString MACRO stringLoc:Req
	PUSH	EDX
	MOV		EDX, stringLoc
	CALL	WriteString
	POP		EDX
ENDM

NUMBERS_REQUESTED = 10

.data
	progTitle		BYTE	"Assignment 6: Low Level I/O Procedures. Ian Wyse",10,10,13,0
	userInfo		BYTE	"Please enter 10 signed integers, each number must fit in a 32-bit register.",10,10,13,0
	failMsg			BYTE	"ERROR: Your number was invalid, enter another: ",0
	getStrMsg		BYTE	"Enter a signed integer: ",0
	userStr			BYTE	13 DUP(?)
	userArray		DWORD	NUMBERS_REQUESTED DUP(?)
	userSum			DWORD	?
	userAverage		DWORD	?
	entriesMsg		BYTE	10,13,"Your entered values are:",10,13,0
	sumMsg			BYTE	10,13,"Your sum is: ",0
	averageMsg		BYTE	10,13,"Your average is: ",0
	exitMsg			BYTE	10,10,13,"Thank you for using my program!",0
	
.code
main PROC
	;Call introduction to print introduction messages.
	PUSH	OFFSET progTitle
	PUSH	OFFSET userInfo
	CALL	Introduction

	;Initialize loop to request user values.
	MOV		ECX, NUMBERS_REQUESTED
_fill_array_loop:
	;Call ReadVal to get an integer from the user and store it in userArray if it is valid
	PUSH	ECX
	PUSH	OFFSET failMsg
	PUSH	OFFSET userArray
	PUSH	OFFSET getStrMsg
	PUSH	OFFSET userStr
	CALL	ReadVal
	LOOP	_fill_array_loop

	;Call Calculations to determine the sum and average of the recieved user values.
	PUSH	OFFSET userSum
	PUSH	OFFSET userAverage
	PUSH	OFFSET userArray
	CALL	Calculations

	;Call Display results to display the sum, average, and list of values recieved from the user.
	PUSH	OFFSET entriesMsg
	PUSH	OFFSET sumMsg
	PUSH	OFFSET averageMsg
	PUSH	OFFSET userArray
	PUSH	userSum
	PUSH	userAverage
	PUSH	OFFSET userStr
	CALL	DisplayResults

	;Call exitMsg to display the exit message
	PUSH	OFFSET exitMsg
	CALL	EndMsg

	Invoke ExitProcess,0	; exit to operating system
main ENDP

;-----------------------------------------------------------------------------------------
; Name: Introduction
;
; Description: Prints introduction messages to the console window.
;
; Recieves: [EBP + 8] = OFFSET of directions string
;			[EBP + 12] = OFFSET of title string
;			
; Postconditions: Title and directions strings are printed to the console window.
;
;-----------------------------------------------------------------------------------------
Introduction PROC
	; Push used registers and initialize EBP
	PUSH	EBP
	MOV		EBP, ESP
	PUSH	EDX

	; Write title string
	MOV		EDX, [EBP + 12]
	CALL	WriteString

	; Write description string
	MOV		EDX, [EBP + 8]
	CALL	WriteString

	; Pop used registers and return flow of execution.
	POP		EDX
	POP		EBP
	RET		8
Introduction ENDP

;---------------------------------------------------------------------
; Name: ReadVal
;
; Description: Reads a value from the user into a buffer, converts it into an integer if possible, and 
;			   stores it in userArray.
;
; Recieves: [EBP + 8] = OFFSET of buffer to store user string.
;			[EBP + 12] = OFFSET of string to request user number.
;			[EBP + 16] = OFFSET of DWORD array to store user numbers
;			[EBP + 20] = OFFSET of string to print if invalid number is read
;			[EBP + 24] = DWORD, offset value for storing integers in [EBP + 16] DWORD array.
;
; Returns:	[EBP + 8] contains valid user string
;			[EBP + 16][4*[EBP + 24] - 4] contains integer version of valid user string
;			
; Postconditions: String with offset [EBP + 12] written to console. If invalid user value is entered, string
;				  with offset [EBP + 20] will also be written to console.
;--------------------------------------------------------------------
ReadVal PROC
	;Define local variables
	LOCAL	numLength:DWORD

	;Push used registers
	PUSH	ESI
	PUSH	ECX
	PUSH	EDX
	PUSH	EAX

	; Call mGetString macro to get a value from the user.
	mGetString  [EBP + 12], [EBP + 8], numLength
	JMP		_validate

_failure:
	; Call mGetString macro with the invalid response method to get a value from the user.
	mGetString  [EBP + 20], [EBP + 8], numLength

_validate:
	; Call the validate method to determine if entered user value is valid.
	PUSH	[EBP + 24]
	PUSH	[EBP + 16]
	PUSH	[EBP + 8]
	PUSH	numLength
	CALL	Validate

	;Compare the first character of the string stored in [EBP + 8] to 'a'. If it is 'a', jump to to _failure
	MOV		ESI, [EBP + 8]
	MOV		EAX, "a"
	CMP		[ESI], EAX	
	JE		_failure

	;Pop pushed registers and return flow of execution
	POP		EAX
	POP		EDX
	POP		ECX
	POP		ESI
	RET		20
ReadVal ENDP

COMMENT `
;----------------------------------------------------------------------------------------------------------------
; Name: ReadFloatVal
;
;
;
;
;
;
;
;
;------------------------------------------------------------------------------------------------------------------
ReadFloatVal PROC
	;Define local variables
	LOCAL	numLength:DWORD

	;Push used registers
	PUSH	ESI
	PUSH	ECX
	PUSH	EDX
	PUSH	EAX

	; Call mGetString macro to get a value from the user.
	mGetString  [EBP + 12], [EBP + 8], numLength
	JMP		_validate

_failure:
	; Call mGetString macro with the invalid response method to get a value from the user.
	mGetString  [EBP + 20], [EBP + 8], numLength

_validate:
	; Call the validate method to determine if entered user value is valid.
	PUSH	[EBP + 24]
	PUSH	[EBP + 16]
	PUSH	[EBP + 8]
	PUSH	numLength
	CALL	ValidateFloat

	;Compare the first character of the string stored in [EBP + 8] to 'a'. If it is 'a', jump to to _failure
	MOV		ESI, [EBP + 8]
	MOV		EAX, "a"
	CMP		[ESI], EAX	
	JE		_failure

	;Pop pushed registers and return flow of execution
	POP		EAX
	POP		EDX
	POP		ECX
	POP		ESI
	RET		20
ReadFloatVal ENDP

;----------------------------------------------------------------------------------------------------------------
;
;
;
;
;
;----------------------------------------------------------------------------------------------------------------
ValidateFloat PROC
	; Create local variables
	LOCAL	sign:REAL4
	LOCAL	userFlt:REAL4
	LOCAL	decDigit:DWORD
	LOCAL	multiplier:REAL4
	LOCAL	currentDigit:DWORD

	; Push used registers
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX
	PUSH	EDI
	PUSH	ESI

	; Initialize local variables and load passed variables to registers.
	MOV		userFlt, 0
	MOV		sign, -1
	MOV		multiplier, 10
	MOV		decDigit, 0
	MOV		ECX, [EBP + 8]
	MOV		ESI, [EBP + 12]

	; Load first character of the string to AL, initialize FPU
	MOV		EAX, 0
	LODSB
	FINIT

	; Compare the first character of the string to + and -. If it is either, jump to sign. If it is +, set the sign local variable to 1.
	CMP		AL, '-'
	JE		_sign
	MOV		sign, 1
	CMP		AL, '+'
	JNE		_loop

_sign:
	; Load the next charater of the string into AL and LOOP to the start of _loop.
	MOV		EAX, 0
	LODSB
	LOOP	_loop

_invalid:
	; set the first character in the user's string to "a", then jump to _exit
	MOV		EDI, [EBP + 12]
	MOV		EAX, "a"
	MOV		[EDI], EAX
	JMP		_exit

_loop:
	; Check of the current character is "." If so jump to _decimal.
	CMP		AL, 46
	JE		_decimal

	; Subtract 48 from AL to convert from ASCII to integer.
	SUB		AL, 48

	; Determine if the character given is in the range [0,9]. If not, jump to _invalid.
	CMP		AL, 0
	JL		_invalid
	CMP		AL, 9
	JG		_invalid

	MOV		currentDigit, EAX

	; Add the next digit to the result
	FILD	multiplier
	FLD		userFlt
	FMUL
	FILD	currentDigit
	FADD
	FST		userFlt

	; Load the next digit and loop back to _loop
	MOV		EAX, 0
	LODSB
	LOOP	_loop
	
	JMP		_decimal_placement

_decimal:
	; Store the location of the decimal place in the float
	CMP		decDigit, 0
	JNE		_invalid
	MOV		decDigit, ECX

	; Load next digit and loop back to _loop
	MOV		EAX, 0
	LODSB
	LOOP	_loop

_decimal_placement:
	CMP		decDigit, 0
	JE		_sign_correction
	
	MOV		ECX, decDigit
	SUB		ECX, 2
	MOV		EAX, 10
	MOV		EBX, 10

_exp_loop:
	MUL		EBX
	LOOP	_exp_loop
	MOV		multiplier, EAX

	FLD		userFlt
	FLD		multiplier
	FDIV
	FST		userFlt

_sign_correction:
	; Multiply userInt by sign to give it the proper sign.
	FLD		userFlt
	FILD		sign
	FMUL	
	FST		userFlt

	Call	WriteFloat

	; Store the created integer in the userArray, indexed by the loop variable of the main function.
	MOV		EDI, [EBP + 16]
	MOV		EBX, [EBP + 20]
	DEC		EBX
	IMUL	EBX, 4
	ADD		EDI, EBX
	MOV		EAX, userFlt
	MOV		[EDI], EAX

_exit:
	; Pop all pushed registers and return flow of execution
	POP		ESI
	POP		EDI
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX
	RET		16
ValidateFloat ENDP
`

;----------------------------------------------------------------------------------------------------------------
; Name: Validate
;
; Description: Determines if a passed string can be converted into an integer that fits in a 32-bit register. If so,
;			   converts it and stores it in an array.
;
; Recieves: [EBP + 8] = DWORD, number of characters in string passed in [EBP + 12]
;			[EBP + 12] = OFFSET of string to be validated and converted to an integer
;			[EBP + 16] = OFFSET of DWORD array to store validated strings as integers
;			[EBP + 20] = DWORD, offset value for storing integers in [EBP + 16] DWORD array.
;
; Returns:	First character of string referenced by [EBP + 12] = 'a' if string is invalid. 
;			If string is valid, [EBP + 16][4 * [EBP + 20] - 4] is integer version of string
;------------------------------------------------------------------------------------------------------------------
Validate PROC
	; Create local variables
	LOCAL	sign:DWORD
	LOCAL	userInt:DWORD

	; Push used registers
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX
	PUSH	EDI
	PUSH	ESI

	; Initialize local variables and load passed variables to registers.
	MOV		userInt, 0
	MOV		sign, -1
	MOV		ECX, [EBP + 8]
	MOV		ESI, [EBP + 12]

	; Load first character of the string to AL
	LODSB

	; Compare the first character of the string to + and -. If it is either, jump to sign. If it is +, set the sign local variable to 1.
	CMP		AL, '-'
	JE		_sign
	MOV		sign, 1
	CMP		AL, '+'
	JNE		_loop

_sign:
	; Load the next charater of the string into AL and LOOP to the start of _loop.
	LODSB
	LOOP	_loop

_invalid:
	; set the first character in the user's string to "a", then jump to _exit
	MOV		EDI, [EBP + 12]
	MOV		EAX, "a"
	MOV		[EDI], EAX
	JMP		_exit

_loop:
	; Subtract 48 from AL to convert from ASCII to integer.
	SUB		AL, 48

	; Determine if the character given is in the range [0,9]. If not, jump to _invalid.
	CMP		AL, 0
	JL		_invalid
	CMP		AL, 9
	JG		_invalid

	; Move the curent userInt value to EBX, then multiply it by 10. If the overflow flag is raised, jump to _invalid.
	MOV		EBX, userInt
	IMUL	EBX, 10
	JO		_invalid

	; Add EBX to EAX, again jumping to _invalid of the overflow flag is raised.
	ADD		EAX, EBX
	JO		_invalid

	; Move EAX back to userInt, then move the next element of the string to AL and loop back to _loop
	MOV		userInt, EAX
	LODSB
	LOOP	_loop

	; Multiply userInt by sign to give it the proper sign.
	MOV		EAX, userInt
	IMUL	EAX, sign

	; Store the created integer in the userArray, indexed by the loop variable of the main function.
	MOV		EDI, [EBP + 16]
	MOV		EBX, [EBP + 20]
	MOV		[EDI + 4*EBX - 4], EAX

_exit:
	; Pop all pushed registers and return flow of execution
	POP		ESI
	POP		EDI
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX
	RET		16
Validate ENDP

;-------------------------------------------------------------------------------------------------------------------------
; Name: Calculations
;
; Description: Calculates the sum and average of the elements in an array and stores them at given locations.
;
; Recieves: [EBP + 8] = OFFSET of DWORD array of values to calculate the sum and average of.
;			[EBP + 12] = OFFSET of DWORD to store average.
;			[EBP + 16] = OFFSET of DWORD to store sum.
;
; Returns: [EBP + 12] = Average of values in array at [EBP + 8]
;		   [EBP + 16] = Sum of values in array at [EBP + 8]
;-------------------------------------------------------------------------------------------------------------------------
Calculations PROC
	; Create local variables
	LOCAL	average:DWORD
	LOCAL	sum:DWORD

	; Push used registers
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX
	PUSH	EDI
	PUSH	ESI

	;Initalize local variable values
	MOV		average, 0
	MOV		sum, 0

	;Initialize loop variable
	MOV		ECX, NUMBERS_REQUESTED
_sum_loop:
	; Move the element of the userArray indexed by ECX - 1 to EAX
	MOV		ESI, [EBP + 8]
	MOV		EAX, [ESI + 4*ECX - 4]
	
	; Add the curent user value to the sum
	ADD		sum, EAX
	LOOP	_sum_loop

	; Store the sum at location [EBP + 16]
	MOV		EDI, [EBP + 16]
	MOV		EAX, sum
	MOV		[EDI], EAX

	; Divide the sum by the number of values recieved from the user and move that value to average
	CDQ
	MOV		EBX, NUMBERS_REQUESTED
	IDIV	EBX
	MOV		average, EAX

	; If the remainder of division is 0, jump to _none
	CMP		EDX, 0
	JE		_none

	; Divide the number of values recieved from the user by the the remainder of divison.
	MOV		EAX, NUMBERS_REQUESTED
	MOV		EBX, EDX
	CDQ
	IDIV	EBX

	; Determines what time of round is required
	CMP		EAX, 2
	JG		_none
	CMP		EAX, -2
	JLE		_none
	CMP		EAX, 0
	JG		_up
	JMP		_down

_down:
	; Round down and then jump to none
	DEC		average
	JMP		_none

_up:
	; Round up
	INC		average

_none:
	; Stores the value contained in average to [EBP + 12]
	MOV		EDI, [EBP + 12]
	MOV		EAX, average
	MOV		[EDI], EAX

	; Pop pushed values and return flow of execution
	POP		ESI
	POP		EDI
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX
	RET		12
Calculations ENDP

;-----------------------------------------------------------------------------------------------------------
; Name: DisplayResults
;
; Description: Displays the elements of an array, their sum, and average, and messages informing the user about
;			   what is being displayed.
;
; Recieves: [EBP + 8] = OFFSET of string storage to pass to WriteString
;			[EBP + 12] = DWORD, Integer to display as the user average
;			[EBP + 16] = DWORD, Integer to displayas the user sum
;			[EBP + 20] = OFFSET of DWORD array of integers to display as user integers
;			[EBP + 24] = OFFSET of average display string
;			[EBP + 28] = OFFSET of sum display string
;			[EBP + 32] = OFFSET of entries display string
; 
; Postconditions: String at [EBP + 32] will be displayed to console window, followed by comma delineated 
;				  elements of array at [EBP + 20]. Further, string at [EBP + 28] will be displayed to console,
;				  followed by [EBP + 16]. Finally, string at [EBP + 24] will be printed to console, followed
;				  by [EBP + 12].
;-----------------------------------------------------------------------------------------------------------
DisplayResults PROC
	; Initialize EBP and push used registers. 
	PUSH	EBP
	MOV		EBP, ESP
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX
	PUSH	ESI

	; Print display user values message to console.
	MOV		EDX, [EBP + 32]
	CALL	WriteString
	
	; Initialize loop counter
	MOV		ECX, NUMBERS_REQUESTED

_numbers_loop:
	; Call WriteVal to write the value pointed to by ESI to the console, if last number was written, jump to _sum
	MOV		ESI, [EBP + 20]
	PUSH	[ESI + 4*ECX - 4]
	PUSH	[EBP + 8]
	CALL	WriteVal
	DEC		ECX
	CMP		ECX, 0
	JE		_sum

	; Write a comma and a space to the console, then jump back to _numbers_loop
	MOV		AL, ","
	CALL	WriteChar
	MOV		AL, " "
	CALL	WriteChar
	JMP	_numbers_loop

_sum:
	; Write the sum title string to the console
	MOV		EDX, [EBP + 28]
	CALL	WriteString
	
	; Call WriteVal to print the sum to the console
	PUSH	[EBP + 16]
	PUSH	[EBP + 8]
	CALL	WriteVal

	; Write the average title string to the console
	MOV		EDX, [EBP + 24]
	CALL	WriteString

	; Call WriteVal to print the average to the console
	PUSH	[EBP + 12]
	PUSH	[EBP + 8]
	CALL	WriteVal

	; Pop pushed variables and return flow of execution
	POP		ESI
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX
	POP		EBP
	RET		28
DisplayResults ENDP

;---------------------------------------------------------------------------------------------------------------------------------------------
; Name: WriteVal
;
; Description: Converts a given integer value to string and writes that string to the console window. 
;
; Recieves: [EBP + 8] = OFFSET of location to store string before writing to console.
;			[EBP + 12] = integer to be converted to string and written to console.
;
; Return: [EBP + 8] = OFFSET of string version of integer [EBP + 12]
;
; Postconditions: Number [EBP + 12] posted to the console window.
;----------------------------------------------------------------------------------------------------------------------------------------------
WriteVal PROC
	; Create local variables
	LOCAL	userVal:DWORD
	LOCAL	divisor:DWORD
	LOCAL	alwaysStore:DWORD
	
	; Push used registers
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX
	PUSH	EDI

	;Initialize local variables, and set EDI to point to the buffer for string editing
	MOV		divisor, 1000000000
	MOV		EAX, [EBP + 12]
	MOV		userVal, EAX
	MOV		alwaysStore, 0
	MOV		EDI, [EBP + 8]

	;Determines if the user's integer is positive or negative. 
	;If positive, add a + to the begining of the output string, if negative, add a -. 
	CMP		EAX, 0
	JGE		_positive
	IMUL	EAX, -1
	MOV		userVal, EAX
	MOV		AL, '-'
	STOSB
	JMP		_string_loop
_positive:
	MOV		AL, '+'
	STOSB	

;-----------------------------------------------------------------------------------------------------------------
; Note: The always store variable prevents the storage of excess zeros at the front of the string.
; Always store is initially set to 0. If it is 0 and the digit to be stored is 0, that digit is not written to the string.
; When the first value is written to string, the always store value is set to 1, resulting in all future digits being written.
; If the always store variable is still 0 when the loop terminates, the integer must have been 0, so a 0 is written to the string.
;---------------------------------------------------------------------------------------------------------------------------
_string_loop:
	; Divide the curent userVal by the divisor variable. Store the remainder as the new userVal.
	MOV		EAX, userVal
	MOV		EDX, 0
	DIV		divisor
	MOV		userVal, EDX

	; If alwaysStore is 1, jump to _store, if alwaysStore and EAX are 0, jump to _decrement
	CMP		alwaysStore, 1
	JE		_store
	CMP		EAX, 0
	JE		_decrement

_store:
	; Add 48 to EAX to change int value to ascii value, store the value, and set alwaysStore to 1
	ADD		EAX, 48
	STOSB
	MOV		alwaysStore, 1

_decrement:
	; Divide the divisor by 10, allowing it to pick out the next digit in the user integer.
	MOV		EAX, divisor
	MOV		EDX, 0
	MOV		EBX, 10
	DIV		EBX

	; If the divisor was previously 1, exit the loop by jumping to _check_zero
	CMP		EAX, 0
	JE		_check_zero

	; Set divisor to the new value and return to the start of the loop
	MOV		divisor, EAX
	JMP		_string_loop

_check_zero:
	; Compare alwaysStore to 0. If it is zero, then the integer was 0, so write 0 to the string.
	CMP		alwaysStore, 0
	JNE		_print
	MOV		AL, 48
	STOSB

_print:
	;Null terminate the created string and run mDisplayString to print it to the console window.
	MOV		AL, 0
	STOSB
	mDisplayString [EBP + 8]
	
	; Pop pushed registers and return flow of execution
	POP		EDI
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX
	RET		8	
WriteVal ENDP

;------------------------------------------------------------------------------------------------------------------------------
; Name: EndMsg
;
; Description: Displays the exit message for the program.
;
; Receives: [EBP + 8] = OFFSET of string to display
;
; Postconditions: String at [EBP + 8] displayed to console window.
;-------------------------------------------------------------------------------------------------------------------------------
EndMsg PROC
	; Pushed used registers and initialize EBP
	PUSH	EBP
	MOV		EBP, ESP
	PUSH	EDX

	; Write string to console.
	MOV		EDX, [EBP + 8]
	CALL	WriteString

	; Pop pushed registers and return flow of execution
	POP		EDX
	POP		EBP
	RET		4
EndMsg ENDP

END main