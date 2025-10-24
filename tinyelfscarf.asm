    ;; Copyright © 2025 bx Shapiro <bx@dartmouth.edu>

    ;; Permission is hereby granted, free of charge, to any person obtaining a
    ;; copy of this software and associated documentation files (the
    ;; “Software”), to deal in the Software without restriction, including
    ;; without limitation the rights to use, copy, modify, merge, publish,
    ;; distribute, sublicense, and/or sell copies of the Software, and to permit
    ;; persons to whom the Software is furnished to do so, subject to the
    ;; following conditions:
    ;;
    ;;The above copyright notice and this permission notice shall be included in
    ;; all copies or substantial portions of the Software.
    ;;
    ; THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    ; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    ; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
    ; THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    ; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
    ; FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
    ; DEALINGS IN THE SOFTWARE.

    ;; based on Muppetlab's teensy elf https://muppetlabs.com/~breadbox/software/tiny/


  
  BITS 32
  
                org     0x80000000
  
  ehdr:
        db      0x7F, "ELF"             ; e_ident
_start:	
	mov cl, 0x41 		; mov %ecx, address takes 5 bytes but I'll do it in 4 by
                        ; writing 0x41 to register and ror so its value becomes
                        ; 0x80000020, the offset to the string
	ror ecx, 1		; address of string is now in ecx
	mov al, 0x4 		; syscall number for write
	mov dl, 0x6		; number of bytes to print
        int 0x80		; calls printf() (ebx, file descriptor happens to be 0)
	mov eax, esp 		; put a value into eax that is a valid pointer
        dw      2       ; e_type, will be interpreted as add al, [eax]
        dw      3       ; e_machine, will be interpreted as add eax, [eax]
	xchg eax,ebx		; makes eax equal to 0, ebx seems to be 0x0 at this point
	inc eax			; makes eax equal to 1
	int 0x80			; calls exit system call
        dd      _start                  ; e_entry
        dd      phdr - $$               ; e_phoff
msg:	db "scarf", 0xa, 0x0, 0x0	; e_shoff, e_flags (e_shnum is 0 so e_shoff is ignored)
        dw      ehdrsize                ; e_ehsize
        dw      phdrsize                ; e_phentsize
  phdr:         dd      1               ; e_phnum       ; p_type
                                        ; e_shentsize
        dd      0                       ; e_shnum       ; p_offset
                                        ; e_shstrndx
  ehdrsize      equ     $ - ehdr
        dd      $$                      ; p_vaddr
        dd      $$                      ; p_paddr
        dd      filesize                ; p_filesz
        dd      filesize                ; p_memsz
        dd      5                       ; p_flags
        dd      0x1000                  ; p_align
  phdrsize      equ     $ - phdr
	
filesize	equ	$ - $$	


  ;; typedef struct {
  ;;     unsigned char       e_ident[EI_NIDENT]; 0-15
  ;;     Elf32_Half          e_type; 16-17
  ;;     Elf32_Half          e_machine; 18-19
  ;;     Elf32_Word          e_version; 20-23
  ;;     Elf32_Addr          e_entry; 24-27
  ;;     Elf32_Off           e_phoff; 28-31
  ;;     Elf32_Off           e_shoff; 32-35
  ;;     Elf32_Word          e_flags; 36-39
  ;;     Elf32_Half          e_ehsize; 40-41
  ;;     Elf32_Half          e_phentsize; 42-43
  ;;     Elf32_Half          e_phnum; 44-45
  ;;     Elf32_Half          e_shentsizxe; 46-47
  ;;     Elf32_Half          e_shnum; 48-49
  ;;     Elf32_Half          e_shstrndx; 50-41
  ;; } Elf32_Ehdr;
	
;; ndisasm tiny -b 32 -e 84
;; 00000000  B971800408        mov ecx,0x8048071
;; 00000005  B804000000        mov eax,0x4
;; 0000000A  BB01000000        mov ebx,0x1
;; 0000000F  BA0F000000        mov edx,0xf
;; 00000014  CD80              int 0x80
;; 00000016  B801000000        mov eax,0x1
;; 0000001B  CD80              int 0x80
;; 0000001D  48                dec eax
;; 0000001E  656C              gs insb
;; 00000020  6C                insb
;; 00000021  6F                outsd
;; 00000022  2C20              sub al,0x20
;; 00000024  53                push ebx
;; 00000025  636172            arpl [ecx+0x72],sp
;; 00000028  66210A            and [edx],cx
;; ➜  knitting
;;;   Magic:   7f 45 4c 46 01 01 01 00 00 00 00 00 00 00 00 00 

;; ELF Header:
;;   Magic:   7f 45 4c 46 01 00 00 00 00 00 00 00 00 00 01 00 
;;   Class:                             ELF32
;;   Data:                              none
;;   Version:                           0 
;;   OS/ABI:                            UNIX - System V
;;   ABI Version:                       0
;;   Type:                              EXEC (Executable file)
;;   Machine:                           Intel 80386
;;   Version:                           0x10020
;;   Entry point address:               0x10020
;;   Start of program headers:          4 (bytes into file)
;;   Start of section headers:          3224447667 (bytes into file)
;;   Flags:                             0x80cd40
;;   Size of this header:               52 (bytes)
;;   Size of program headers:           32 (bytes)
;;   Number of program headers:         1
;;   Size of section headers:           0 (bytes)
;;   Number of section headers:         0
;;   Section header string table index: 0
;; readelf: Warning: possibly corrupt ELF file header - it has a non-zero section header offset, but no section headers

;; There are no sections to group in this file.

;; Program Headers:
;;   Type           Offset   VirtAddr   PhysAddr   FileSiz MemSiz  Flg Align
;;   LOAD           0x000000 0x00010000 0x00030002 0x10020 0x10020 R   0xc0312ab3

;; There is no dynamic section in this file.

;; There are no relocations in this file.

;; The decoding of unwind sections for machine type Intel 80386 is not currently supported.

;; Dynamic symbol information is not available for displaying symbols.

;; No version information found in this file.
