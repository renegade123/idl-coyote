; docformat = 'rst'
;
; NAME:
;   cgDisplay
;
; PURPOSE:
;   The purpose of cgDisplay is to open a graphics window on the display, or in the
;   PostScript device, or in the Z-graphics buffer, depending upon the current graphics
;   device. In PostScript a window of the proper aspect ratio is created with PSWindow.
;   Using cgDisplay to open "windows" will allow you to more easily write device-independent
;   IDL programs.
;
;******************************************************************************************;
;                                                                                          ;
;  Copyright (c) 2010, by Fanning Software Consulting, Inc. All rights reserved.           ;
;                                                                                          ;
;  Redistribution and use in source and binary forms, with or without                      ;
;  modification, are permitted provided that the following conditions are met:             ;
;                                                                                          ;
;      * Redistributions of source code must retain the above copyright                    ;
;        notice, this list of conditions and the following disclaimer.                     ;
;      * Redistributions in binary form must reproduce the above copyright                 ;
;        notice, this list of conditions and the following disclaimer in the               ;
;        documentation and/or other materials provided with the distribution.              ;
;      * Neither the name of Fanning Software Consulting, Inc. nor the names of its        ;
;        contributors may be used to endorse or promote products derived from this         ;
;        software without specific prior written permission.                               ;
;                                                                                          ;
;  THIS SOFTWARE IS PROVIDED BY FANNING SOFTWARE CONSULTING, INC. ''AS IS'' AND ANY        ;
;  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES    ;
;  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT     ;
;  SHALL FANNING SOFTWARE CONSULTING, INC. BE LIABLE FOR ANY DIRECT, INDIRECT,             ;
;  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED    ;
;  TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;         ;
;  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND             ;
;  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT              ;
;  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS           ;
;  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.                            ;
;******************************************************************************************;
;
;+
;   The purpose of cgDisplay is to open a graphics window on the display, or in the
;   PostScript device, or in the Z-graphics buffer, depending upon the current graphics
;   device. In PostScript a window of the proper aspect ratio is created with PSWindow.
;   Using cgDisplay to open "windows" will allow you to more easily write device-independent
;   IDL programs.
;
; :Categories:
;    Graphics
;    
; :Params:
;    pxsize: in, optional, type=integer, default=640
;         The X size of the graphics window created. By default, 640.
;    pysize: in, optional, type=integer, default=512
;         The Y size of the graphics window created. By default, 512.
;         
; :Keywords:
;    aspect, in, optional, type=float
;        Set this keyword to create a window with this aspect ratio (ysize/xsize).
;        If aspect is greater than 1, then the ysize will be used in the aspect
;        ratio calculation. If the aspect is less than or equal to 1, then the
;        xsize will be used in the aspect ratio calculation of the final window size.
;        If the input to the ASPECT keyword is an image, then the aspect ratio will
;        be calculated from the image itself.
;    color: in, optional, type=string/integer, default='white'
;        If this keyword is a string, the name of the data color. By default, 'white'.
;        Color names are those used with cgColor. Otherwise, the keyword is assumed 
;        to be a color index into the current color table. The color is not used if
;        the "window" is opened in PostScript on the Z-graphics buffer.
;    free: in, optional, type=boolean, default=0
;         Set this keyword to open a window with a free or unused window index number.
;         This keyword applied only to graphics windows created on the computer display.
;    wid: in, optional, type=integer, default=0
;         The window index number of the IDL graphics window to create.
;    window: in, optional, type=integer, default=0
;         Because I want to use cgDisplay everywhere, including in resizeable graphics
;         windows, and I don't want it opening windows then, it first checks to be sure
;         there are no resizeable graphics windows on the display before it creates a window.
;         Setting this keyword will overrule this check and create a normal IDL graphics window
;         on the display. This will allow you to open a normal graphics window at the same
;         time a resizeable graphics window exists on the display.
;    xsize: in, optional, type=integer, default=640
;         The X size of the graphics window created. By default, 640. The PXSIZE parameter 
;         is used in preference to the XSIZE keyword value.
;    ysize: in, optional, type=integer, default=512
;         The Y size of the graphics window created. By default, 512. The PYSIZE parameter 
;         is used in preference to the YSIZE keyword value.
;    _extra: in, optional, type=any
;         Any keywords supported by the WINDOW command are allowed.
;         
; :Examples:
;    Use like the IDL WINDOW command::
;       IDL> cgDisplay, XSIZE=500 YSIZE=400
;       IDL> cgDisplay, 500, 500, WID=1, COLOR='gray'
;       
; :Author:
;       FANNING SOFTWARE CONSULTING::
;           David W. Fanning 
;           1645 Sheely Drive
;           Fort Collins, CO 80526 USA
;           Phone: 970-221-0438
;           E-mail: david@idlcoyote.com
;           Coyote's Guide to IDL Programming: http://www.idlcoyote.com
;
; :History:
;     Change History::
;        Written, 15 November 2010. DWF.
;        Changes so that color variables don't change type. 23 Nov 2010. DWF.
;        Moved the window index argument to the WID keyword. 9 Dec 2010. DWF.
;        Modified to produce a window in PostScript and the Z-buffer, too. 15 Dec 2010. DWF.
;        Added the FREE keyword. 3 January 2011. DWF.
;        I made a change that allows you to call cgDisplay inside a program that is
;           going to be added to a cgWindow. The program will not open a graphics window
;           if the current graphics window ID is found in a list of cgWindow window IDs.
;           It is now possible to use cgDisplay in any graphics program, even those that
;           will be run in cgWindow. 17 Nov 2011. DWF.
;        Added ASPECT keyword. 18 Nov 2011. DWF.
;        Allowed the window ASPECT to be set with an image argument. 25 Nov 2011. DWF.
;        Now use Scope_Level to always create a display when cgDisplay is called from
;           the main IDL level. 7 Feb 2012. DWF.
;
; :Copyright:
;     Copyright (c) 2010-2012, Fanning Software Consulting, Inc.
;-
PRO cgDisplay, pxsize, pysize, $
    ASPECT=aspect, $
    COLOR=scolor, $
    FREE=free, $
    WID=windowIndex, $
    WINDOW=window, $
    XSIZE=xsize, $
    YSIZE=ysize, $
    _EXTRA=extra

    Compile_Opt idl2

    ; Error handling.
    Catch, theError
    IF theError NE 0 THEN BEGIN
        Catch, /CANCEL
        void = Error_Message()
        RETURN
    ENDIF
    
    ; Set up PostScript device for working with colors.
    IF !D.Name EQ 'PS' THEN Device, COLOR=1, BITS_PER_PIXEL=8
    
    ; Check parameters and keywords.
    free = Keyword_Set(free)
    IF N_Elements(scolor) EQ 0 THEN color = 'white' ELSE color = scolor
    IF N_Elements(windowIndex) EQ 0 THEN windowIndex = 0
    IF N_Elements(xsize) EQ 0 THEN xsize = 640
    IF N_Elements(ysize) EQ 0 THEN ysize = 512
    IF N_Elements(pxsize) EQ 0 THEN pxsize = xsize
    IF N_Elements(pysize) EQ 0 THEN pysize = ysize
    
    ; Do you need a window with a particular aspect ratio?
    IF N_Elements(aspect) NE 0 THEN BEGIN
    
       ; If aspect is not a scalar, but an image. Use the aspect
       ; ratio of the image to determine the aspect ratio of the
       ; display.
       ndims = Size(aspect, /N_DIMENSIONS)
       IF  (ndims GE 2) && (ndims LE 4) THEN BEGIN 
           void = Image_Dimensions(aspect, XSIZE=xsize, YSIZE=ysize)
           waspect = Float(ysize) / xsize
       ENDIF ELSE waspect = aspect
       
       IF waspect GT 1.0 THEN BEGIN
          pxsize = pysize / waspect
       ENDIF ELSE BEGIN
          pysize = pxsize * waspect
       ENDELSE
       
    ENDIF
    
    ; If you are on a machine that supports windows, you can create a window
    ; if the current graphics window ID cannot be found in the list of cgWindow IDs.
    ; This will allow you to create a window in a program that can still run in
    ; a resizeable graphics window. If you absolutely MUST have a graphics window,
    ; set the window keyword to force a normal IDL graphics window.
    IF (!D.Flags AND 256) NE 0 THEN BEGIN
    
        ; Assume you can create a window.
        createWindow = 1
        
        IF ~Keyword_Set(window) THEN BEGIN
            ; Get the window ids of all cgWindows.
            windowIDs = cgQuery(COUNT=windowCnt)
            IF windowCnt NE 0 THEN BEGIN
                index = Where(windowIDs EQ !D.Window, foundit)
                IF foundit && (Scope_Level() NE 2) THEN createWindow = 0
            ENDIF 
        ENDIF
        
        ; If you are not running this program in a cgWindow, feel
        ; free to create a window!
        IF createWindow THEN BEGIN
            Window, windowIndex, XSIZE=pxsize, YSIZE=pysize, $
                 FREE=free, _STRICT_EXTRA=extra
            
            ; cgErase will take care of sorting out what kind of 
            ; "color" indicator we are using. No need to do it here.
            cgErase, color   
        ENDIF
    ENDIF ELSE BEGIN
        CASE !D.Name OF
        
            ; There can be some strange interactions with PS_START if PS_START
            ; is called with no current windows open, and cgDisplay is called with
            ; an aspect ratio that results in a PORTRAIT mode display. This checks
            ; for that problem.
            'PS': BEGIN
                COMMON _$FSC_PS_START_, ps_struct
                keywords = PSWindow(AspectRatio=Float(pysize)/pxsize)
                Device, _Extra=keywords
                IF N_Elements(ps_struct) NE 0 THEN ps_struct.landscape = keywords.landscape
                END
            'Z': Device, Set_Resolution=[pxsize,pysize]
            ELSE:
        ENDCASE
    ENDELSE
END
