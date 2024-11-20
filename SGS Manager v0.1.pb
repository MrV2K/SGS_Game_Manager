;- ### Speccy Game Selector File Manager Info ###
;
Global Version.s="0.1"
;
; © 2024 Paul Vince (MrV2k)
;
; https://www.amigagameselector.co.uk
;
; [ PB V5.7x/V6.x / 32Bit / 64Bit / Windows / DPI ]
;
; A scraper and file manager for TOSEC ZX Spectrum images
;
;- ############### Version Info
;
;============================================
; VERSION INFO v0.1
;============================================
;
; Initial Release
;
;============================================

EnableExplicit

;- ############### Imports

Import ""
  GetConsoleWindow(Void)
EndImport

;- ############### Enumerations
;
Enumeration
  #MAIN_WINDOW
  #MAIN_LIST
  #MAIN_MENU
  #MAIN_STATUS
  
  #FILTER_CONTAINER
  
  #LOAD_BUTTON
  #EXPORT_BUTTON
  #CLOSE_BUTTON
  #ALT_BUTTON
  #HACK_BUTTON
  #LANGUAGE_BUTTON
  #BAD_DUMP_BUTTON
  #COUNTRY_BUTTON
  #RERELEASE_BUTTON
  #ADULT_BUTTON
  #A16K_BUTTON
  #A48K_BUTTON
  #A16K_48K_BUTTON
  #A48K_128K_BUTTON
  #A128K_BUTTON
  #CSSCGC_BUTTON
  #CRACKED_BUTTON
  #MASTER_TAPE_BUTTON
  #COVER_TAPE_BUTTON
  #TRAINED_BUTTON
  #LENSLOK_BUTTON
  #MODIFIED_BUTTON
  #PASSWORDED_BUTTON
  #REFRESH_BUTTON
  #RESET_BUTTON
  
  #EXPORT_WINDOW
  #EXPORT_FAT32_BUTTON
  #EXPORT_TREE
  #EXPORT_MEMORY_CHECK
  #EXPORT_START_BUTTON
  
  #FILE
  #REGEX
EndEnumeration

;- ############### Structures
;
Structure SGS_Data
  SGS_Name.s
  SGS_File.s
  SGS_Size.i
  SGS_Folder.s
  SGS_Format.s
  SGS_Year.s
  SGS_Filtered.b
  SGS_Alt.i
  SGS_Memory.s
  SGS_Loader.s
  SGS_Protection.s
  SGS_Covertape.b
  SGS_Passworded.b
  SGS_Country.s
  SGS_Language.s
  SGS_ReRelease.b
  SGS_Multi_Tape.s
  SGS_Tape_Number.i
  SGS_Tape_Max.i 
  SGS_Multi_Sided.b
  SGS_Tape_Side.s
  SGS_Cracked.b
  SGS_Fixed.b
  SGS_OverDump.b
  SGS_UnderDump.b
  SGS_Virus.b
  SGS_Verified.b
  SGS_Trained.b
  SGS_Bad_Dump.b
  SGS_Beta.b
  SGS_Hack.b
  SGS_Demo.b
  SGS_Version.s
  SGS_Copyright.s
  SGS_Status.s
  SGS_Multi_Program.s
  SGS_Pirate.s
  SGS_CSSCGC.b
  SGS_Adult.b
  SGS_Modified.b
  SGS_Unpublished.b
  SGS_Master_Tape.b
EndStructure

Structure Sort_Struct
  s_name.s
  List s_list.i()
EndStructure

Structure Download_Struct
  d_old_path.s
  d_new_path.s
EndStructure

;- ############### List & Maps
;
Global NewList SGS_Database.SGS_Data()
Global NewList File_List.s()
Global NewList Filtered_List()

;- ############### Global Variables
;
Global W_Title.s="SGS File Manager "+Version
Global Build.s=FormatDate("%dd%mm%yy-%hh%mm%ss", #PB_Compiler_Date)

Global event, gadget, type, hWnd, size

Global filter.b=#True

Global Home_Path.s=GetCurrentDirectory()

Global Path.s

;- ############### Macros

Macro DpiX(value) ; <--------------------------------------------------> DPI X Scaling
  DesktopScaledX(value)
EndMacro

Macro DpiY(value) ; <--------------------------------------------------> DPI Y Scaling
  DesktopScaledY(value)
EndMacro

Macro Window_Update() ; <---------------------------------------------> Waits For Window Update
  While WindowEvent() : Wend
EndMacro

Macro Pause_Console()
  PrintS()
  PrintN("Press A Key To Continue...")
  Repeat : Until Inkey()<>""
EndMacro

Macro Pause_Gadget(gadget)
  SendMessage_(GadgetID(gadget),#WM_SETREDRAW,#False,0)
EndMacro

Macro Resume_Gadget(gadget)
  SendMessage_(GadgetID(gadget),#WM_SETREDRAW,#True,0)
  InvalidateRect_(GadgetID(gadget), 0, 0)             ; invalidate control area
  UpdateWindow_(GadgetID(gadget))                     ; redraw invalidated area
EndMacro

Macro Pause_Window(window)
  SendMessage_(WindowID(window),#WM_SETREDRAW,#False,0)
EndMacro

Macro Resume_Window(window)
  SendMessage_(WindowID(window),#WM_SETREDRAW,#True,0)
  RedrawWindow_(WindowID(window),#Null,#Null,#RDW_INVALIDATE)
EndMacro

Macro Center_Console()
  hWnd = GetConsoleWindow(0)
  MoveWindow_(hWnd, DpiX(WindowX(#MAIN_WINDOW))+(WindowWidth(#MAIN_WINDOW)/8), DpiY(WindowY(#MAIN_WINDOW))+(WindowHeight(#MAIN_WINDOW)/8), DpiX(WindowWidth(#MAIN_WINDOW)/1.25), DpiY(WindowHeight(#MAIN_WINDOW)/1.25), 1)
EndMacro

Macro Update_Title()
  
  size=0
  
  ForEach Filtered_List()
    SelectElement(SGS_Database(),Filtered_List())
    size+SGS_Database()\SGS_Size
  Next
  
  size=size/1024
  size=size/1024
  
  SetWindowTitle(#MAIN_WINDOW,W_Title+" - ("+Str(ListSize(Filtered_List()))+" files) ("+ Str(size)+"mb)")
  
EndMacro

Macro Toggle_Filter_Gadgets(bool)
  
 DisableGadget(#ALT_BUTTON,bool)
 DisableGadget(#HACK_BUTTON,bool)
 DisableGadget(#LANGUAGE_BUTTON,bool)
 DisableGadget(#COUNTRY_BUTTON,bool)
 DisableGadget(#BAD_DUMP_BUTTON,bool)
 DisableGadget(#RERELEASE_BUTTON,bool)
 DisableGadget(#ADULT_BUTTON,bool)
 DisableGadget(#A16K_BUTTON,bool)
 DisableGadget(#A16K_48K_BUTTON,bool)
 DisableGadget(#A48K_BUTTON,bool)
 DisableGadget(#A48K_128K_BUTTON,bool)
 DisableGadget(#A128K_BUTTON,bool)
 DisableGadget(#CSSCGC_BUTTON,bool)
 DisableGadget(#CRACKED_BUTTON,bool)
 DisableGadget(#MASTER_TAPE_BUTTON,bool)
 DisableGadget(#COVER_TAPE_BUTTON,bool)
 DisableGadget(#TRAINED_BUTTON,bool)
 DisableGadget(#LENSLOK_BUTTON,bool)
 DisableGadget(#MODIFIED_BUTTON,bool)
 DisableGadget(#PASSWORDED_BUTTON,bool)
 
 DisableGadget(#EXPORT_BUTTON,bool)
 DisableGadget(#RESET_BUTTON,bool)
 DisableGadget(#REFRESH_BUTTON,bool)
 
EndMacro

Macro Set_Filter_Gadgets(bool)
  
  SetGadgetState(#ALT_BUTTON,bool)
  SetGadgetState(#HACK_BUTTON,bool)
  SetGadgetState(#LANGUAGE_BUTTON,bool)
  SetGadgetState(#COUNTRY_BUTTON,bool)
  SetGadgetState(#BAD_DUMP_BUTTON,bool)
  SetGadgetState(#RERELEASE_BUTTON,bool)
  SetGadgetState(#ADULT_BUTTON,bool)
  SetGadgetState(#A16K_BUTTON,bool)
  SetGadgetState(#A16K_48K_BUTTON,bool)
  SetGadgetState(#A48K_BUTTON,bool)
  SetGadgetState(#A48K_128K_BUTTON,bool)
  SetGadgetState(#A128K_BUTTON,bool)
  SetGadgetState(#CSSCGC_BUTTON,bool)
  SetGadgetState(#CRACKED_BUTTON,bool)
  SetGadgetState(#MASTER_TAPE_BUTTON,bool)
  SetGadgetState(#COVER_TAPE_BUTTON,bool)
  SetGadgetState(#TRAINED_BUTTON,bool)
  SetGadgetState(#LENSLOK_BUTTON,bool)
  SetGadgetState(#MODIFIED_BUTTON,bool)
  SetGadgetState(#PASSWORDED_BUTTON,bool)
    
EndMacro

;- ############### File I/O Procedures

Procedure List_Files_Recursive(Dir.s, List Files.s(), Extension.s) ; <------> Adds All Files In A Folder Into The Supplied List
  
  Protected NewList Directories.s()
  
  Protected FOLDER_LIST
  
  If Right(Dir, 1) <> "\"
    Dir + "\"
  EndIf
  
  If ExamineDirectory(FOLDER_LIST, Dir, Extension)
    While NextDirectoryEntry(FOLDER_LIST)
      Select DirectoryEntryType(FOLDER_LIST)
        Case #PB_DirectoryEntry_File
          AddElement(Files())
          Files() = Dir + DirectoryEntryName(FOLDER_LIST)
          Window_Update()
        Case #PB_DirectoryEntry_Directory
          Select DirectoryEntryName(FOLDER_LIST)
            Case ".", ".."
              Continue
            Default
              AddElement(Directories())
              Directories() = Dir + DirectoryEntryName(FOLDER_LIST)
          EndSelect
      EndSelect
    Wend
    FinishDirectory(FOLDER_LIST)
    ForEach Directories()
      List_Files_Recursive(Directories(), Files(), Extension)
    Next
  EndIf 
  
  FreeList(Directories())
  
EndProcedure

;- ############### Windows & Gadgets Procedures

Macro Find_Element(letter)
  
  ForEach Sort_List()
    If Sort_List()\s_name=letter
      Break
    EndIf
  Next
  
EndMacro

Macro Add_Element(letter)
  
  Find_Element(letter)
  AddElement(Sort_List()\s_list())
  Sort_List()\s_list()=ListIndex(SGS_Database()) 
  
EndMacro

Macro Add_Item()
  
  ForEach Sort_List()\s_list()
    SelectElement(SGS_Database(),Sort_List()\s_list())
    AddGadgetItem(#EXPORT_TREE,-1,SGS_Database()\SGS_File,0,1)
  Next
  
EndMacro

Procedure TreeExpandAllItems(TreeId)
  Pause_Gadget(TreeId)
  Protected CurItem.i, CurState.i, ItemCnt.i = CountGadgetItems(TreeId) 
  If ItemCnt <= 0: ProcedureReturn: EndIf 
  For CurItem = 0 To ItemCnt-1
    CurState = GetGadgetItemState(TreeId, CurItem)
    CurState = CurState ! #PB_Tree_Collapsed
    If CurState & #PB_Tree_Checked
      CurState = #PB_Tree_Checked | #PB_Tree_Expanded
    ElseIf CurState & #PB_Tree_Inbetween
      CurState = #PB_Tree_Inbetween | #PB_Tree_Expanded
    Else
      CurState = #PB_Tree_Expanded
    EndIf
    SetGadgetItemState(TreeId, CurItem, CurState)    
  Next
  Resume_Gadget(TreeId)
EndProcedure

Procedure Export_Files(fat32.b)
  
  ; Normal Sort (255)
  ; 1. Separate the letters
  ; 2. If letter list is over 255 entries move first 255 to a temporary list.
  ; 3. Call that list (letter + number)
  ; 4. Repeat 2 & 3 until list is under 255
  ; 5. Move onto next letter and repeat 2,3 & 4
  
  Protected NewList Sort_List.Sort_Struct()
  Protected NewList Download_List.Sort_Struct()
  Protected NewList temp_list.i()
  
  Protected count,i,j
  
  Protected old_file.s, new_file.s
  
  AddElement(Sort_List())
  Sort_List()\s_name="0"
  
  For i = 97 To 122
    AddElement(Sort_List())
    Sort_List()\s_name=Chr(i)
  Next
  
  ; Load database into alphabetical lists
  
  ForEach Filtered_List()
    
        SelectElement(SGS_Database(),Filtered_List())
        Path=Left(LCase(SGS_Database()\SGS_Name),1)
        
        Select Path
            
          Case "0","1","2","3","4","5","6","7","8","9" 
            Add_Element("0")
          Case "a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"
            Add_Element(Path)
            
        EndSelect
    
  Next  
  
  ForEach Sort_List()
    Debug Sort_List()\s_name
    Debug ListSize(Sort_List()\s_list())
  Next
    
  ForEach Sort_List()
    
    If fat32
      If ListSize(Sort_List()\s_list())<255
        AddElement(Download_List())
        Download_List()\s_name=Sort_List()\s_name
        CopyList(Sort_List()\s_list(),Download_List()\s_list())  
      Else  
        count=0
        CopyList(Sort_List()\s_list(),temp_list())
        Repeat
          AddElement(Download_List())
          Download_List()\s_name=Sort_List()\s_name+" ("+Str(count)+")"
          If ListSize(temp_list())>255
            j=254
          Else
            j=ListSize(temp_list())-1
          EndIf
          For i=0 To j
            AddElement(Download_List()\s_list())
            SelectElement(temp_list(),0)
            Download_List()\s_list()=temp_list()
            DeleteElement(temp_list())
          Next 
          count+1
        Until ListSize(temp_list())=0
      EndIf 
    Else
      CopyList(Sort_List(),Download_List())
    EndIf
    
  Next
  
  ForEach Download_List()
    If fat32
      If ListSize(Download_List()\s_list())>0
        FirstElement(Download_List()\s_list())
        SelectElement(SGS_Database(),Download_List()\s_list())
        path=Left(SGS_Database()\SGS_Name,2)
        LastElement(Download_List()\s_list())
        SelectElement(SGS_Database(),Download_List()\s_list())
        path+" - "+Left(SGS_Database()\SGS_Name,2)
        Download_List()\s_name=path
      EndIf
    EndIf
  Next     
  
  path=PathRequester("Export Path",Home_Path)
  
  ForEach Download_List()
    ForEach Download_List()\s_list()
      If ListSize(Download_List()\s_list())>0
        SelectElement(SGS_Database(),Download_List()\s_list())
        old_file=SGS_Database()\SGS_Folder+SGS_Database()\SGS_File
        new_file=path+UCase(Download_List()\s_name)+"\"+SGS_Database()\SGS_File
        OpenConsole("Copying files...")
        PrintN("Copying... "+old_file)
        PrintN("To... "+new_file)
        ;If FileSize(path+UCase(Download_List()\s_name))<>-2 : CreateDirectory(path+UCase(Download_List()\s_name)) : EndIf
        ;CopyFile(old_file,new_file)
      EndIf
    Next
  Next
    
EndProcedure

Procedure Export_Window()
  
  Protected ex_event, ex_gadget, ex_type, i

  OpenWindow(#EXPORT_WINDOW, 0, 0, 300, 200, "Export Files ("+Str(ListSize(Filtered_List()))+")" , #PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_MinimizeGadget)
  
  DisableWindow(#MAIN_WINDOW,#True)
  
  TextGadget(#PB_Any,5,5,100,20,"Preview Example")
  TreeGadget(#EXPORT_TREE,5,25,290,115) 
  CheckBoxGadget(#EXPORT_FAT32_BUTTON,5,145,150,25,"Fat32 Folder (255 files)")
  ButtonGadget(#EXPORT_START_BUTTON,175,145,120,50,"Start")
  
  AddGadgetItem(#EXPORT_TREE,-1,"[ROMS]",0,0)
  AddGadgetItem(#EXPORT_TREE,-1,"A",0,1)
  AddGadgetItem(#EXPORT_TREE,-1,"MyRom1.rom",0,2)
  AddGadgetItem(#EXPORT_TREE,-1,"MyRom2.rom",0,2)
  AddGadgetItem(#EXPORT_TREE,-1,"MyRom3.rom",0,2)
  
  TreeExpandAllItems(#EXPORT_TREE)
  SetGadgetState(#EXPORT_TREE,0)    
  SetGadgetState(#EXPORT_FAT32_BUTTON,#False)
  
  Repeat
    
    Event=WaitWindowEvent()
    gadget=EventGadget()
    type=EventType()
    
    Select Event
        
      Case #PB_Event_CloseWindow
        If EventWindow()=#EXPORT_WINDOW
          Window_Update()
          CloseWindow(#EXPORT_WINDOW)
          DisableWindow(#MAIN_WINDOW,#False)
          Break
        EndIf
        
    EndSelect
    
    Select gadget
        
      Case #EXPORT_START_BUTTON
        Export_Files(GetGadgetState(#EXPORT_FAT32_BUTTON))
        Window_Update()
        
      Case #EXPORT_MEMORY_CHECK
        If EventWindow()=#EXPORT_WINDOW
          If GetGadgetState(#EXPORT_MEMORY_CHECK)=#PB_Checkbox_Checked
            Pause_Gadget(#EXPORT_TREE)
            ClearGadgetItems(#EXPORT_TREE)
            AddGadgetItem(#EXPORT_TREE,-1,"[ROMS]",0,0)
            AddGadgetItem(#EXPORT_TREE,-1,"48K",0,1)
            AddGadgetItem(#EXPORT_TREE,-1,"A",0,2)
            AddGadgetItem(#EXPORT_TREE,-1,"MyRom1.rom",0,3)
            AddGadgetItem(#EXPORT_TREE,-1,"MyRom2.rom",0,3)
            AddGadgetItem(#EXPORT_TREE,-1,"MyRom3.rom",0,3)
            TreeExpandAllItems(#EXPORT_TREE)
            SetGadgetState(#EXPORT_TREE,0)  
            Window_Update()
          Else
            Pause_Gadget(#EXPORT_TREE)
            ClearGadgetItems(#EXPORT_TREE)
            AddGadgetItem(#EXPORT_TREE,-1,"[ROMS]",0,0)
            AddGadgetItem(#EXPORT_TREE,-1,"A",0,1)
            AddGadgetItem(#EXPORT_TREE,-1,"MyRom1.rom",0,2)
            AddGadgetItem(#EXPORT_TREE,-1,"MyRom2.rom",0,2)
            AddGadgetItem(#EXPORT_TREE,-1,"MyRom3.rom",0,2)     
            TreeExpandAllItems(#EXPORT_TREE)
            SetGadgetState(#EXPORT_TREE,0)  
            Window_Update()
          EndIf

        EndIf        
    EndSelect
    
  ForEver
  
EndProcedure

Procedure Filter_List()
  
  ClearList(Filtered_List())
  
  ForEach SGS_Database()
    SGS_Database()\SGS_Filtered=#False
    If GetGadgetState(#ALT_BUTTON)=0 And SGS_Database()\SGS_Alt<>-1 : SGS_Database()\SGS_Filtered=#True : EndIf
    If GetGadgetState(#HACK_BUTTON)=0 And SGS_Database()\SGS_Hack=#True: SGS_Database()\SGS_Filtered=#True : EndIf
    If GetGadgetState(#LANGUAGE_BUTTON)=0 And SGS_Database()\SGS_Language<>"en": SGS_Database()\SGS_Filtered=#True : EndIf
    If GetGadgetState(#BAD_DUMP_BUTTON)=0 And SGS_Database()\SGS_Bad_Dump=#True: SGS_Database()\SGS_Filtered=#True : EndIf
    If GetGadgetState(#COUNTRY_BUTTON)=0 And SGS_Database()\SGS_Country<>"GB": SGS_Database()\SGS_Filtered=#True : EndIf
    If GetGadgetState(#RERELEASE_BUTTON)=0 And SGS_Database()\SGS_ReRelease=#True: SGS_Database()\SGS_Filtered=#True : EndIf
    If GetGadgetState(#ADULT_BUTTON)=0 And SGS_Database()\SGS_Adult=#True: SGS_Database()\SGS_Filtered=#True : EndIf
    If GetGadgetState(#A16K_BUTTON)=0 And SGS_Database()\SGS_Memory="16K": SGS_Database()\SGS_Filtered=#True : EndIf
    If GetGadgetState(#A16K_48K_BUTTON)=0 And SGS_Database()\SGS_Memory="16K-48K": SGS_Database()\SGS_Filtered=#True : EndIf
    If GetGadgetState(#A48K_BUTTON)=0 And SGS_Database()\SGS_Memory="48K": SGS_Database()\SGS_Filtered=#True : EndIf
    If GetGadgetState(#A48K_128K_BUTTON)=0 And SGS_Database()\SGS_Memory="48K-128K": SGS_Database()\SGS_Filtered=#True : EndIf
    If GetGadgetState(#A128K_BUTTON)=0 And SGS_Database()\SGS_Memory="128K": SGS_Database()\SGS_Filtered=#True : EndIf
    If GetGadgetState(#CSSCGC_BUTTON)=0 And SGS_Database()\SGS_CSSCGC=#True: SGS_Database()\SGS_Filtered=#True : EndIf
    If GetGadgetState(#CRACKED_BUTTON)=0 And SGS_Database()\SGS_Cracked=#True: SGS_Database()\SGS_Filtered=#True : EndIf
    If GetGadgetState(#MASTER_TAPE_BUTTON)=0 And SGS_Database()\SGS_Master_Tape=#True: SGS_Database()\SGS_Filtered=#True : EndIf
    If GetGadgetState(#COVER_TAPE_BUTTON)=0 And SGS_Database()\SGS_Covertape=#True: SGS_Database()\SGS_Filtered=#True : EndIf
    If GetGadgetState(#TRAINED_BUTTON)=0 And SGS_Database()\SGS_Trained=#True: SGS_Database()\SGS_Filtered=#True : EndIf
    If GetGadgetState(#LENSLOK_BUTTON)=0 And SGS_Database()\SGS_Protection="Lenslok": SGS_Database()\SGS_Filtered=#True : EndIf
    If GetGadgetState(#MODIFIED_BUTTON)=0 And SGS_Database()\SGS_Modified=#True: SGS_Database()\SGS_Filtered=#True : EndIf
    If GetGadgetState(#PASSWORDED_BUTTON)=0 And SGS_Database()\SGS_Passworded=#True: SGS_Database()\SGS_Filtered=#True : EndIf
    If SGS_Database()\SGS_Filtered=#False : AddElement(Filtered_List()) : Filtered_List()=ListIndex(SGS_Database()) : EndIf
  Next
    
EndProcedure

Procedure Draw_List()
  
  Protected count
  
  Pause_Gadget(#MAIN_LIST)
  
  ClearGadgetItems(#MAIN_LIST)
  
  Filter_List()
  
  ForEach Filtered_List()
    SelectElement(SGS_Database(),Filtered_List())
    AddGadgetItem(#MAIN_LIST,-1,SGS_Database()\SGS_File)
  Next
  
  For count=0 To CountGadgetItems(#MAIN_LIST) Step 2
    SetGadgetItemColor(#MAIN_LIST,count,#PB_Gadget_BackColor,$ffeeee)
  Next

  If GetWindowLongPtr_(GadgetID(#MAIN_LIST), #GWL_STYLE) & #WS_VSCROLL
    SetGadgetItemAttribute(#MAIN_LIST,0,#PB_ListIcon_ColumnWidth,GadgetWidth(#MAIN_LIST)-18)
  Else
    SetGadgetItemAttribute(#MAIN_LIST,0,#PB_ListIcon_ColumnWidth,GadgetWidth(#MAIN_LIST)-4)
  EndIf
  
  Update_Title()
  
  Resume_Gadget(#MAIN_LIST)
  
EndProcedure

Procedure Draw_Gadgets()
    
  ListIconGadget(#MAIN_LIST,5,5,620,590,"File Name",616,#PB_ListIcon_FullRowSelect|#PB_ListIcon_GridLines|#LVS_NOCOLUMNHEADER)

  ContainerGadget(#FILTER_CONTAINER,630,5,165,555,#PB_Container_Flat)
  CheckBoxGadget(#ALT_BUTTON,5,5,130,25,"Alt Games")
  CheckBoxGadget(#HACK_BUTTON,5,30,130,25,"Hacked Games")
  CheckBoxGadget(#LANGUAGE_BUTTON,5,55,130,25,"Non-English")
  CheckBoxGadget(#COUNTRY_BUTTON,5,80,130,25,"All Countries")
  CheckBoxGadget(#BAD_DUMP_BUTTON,5,105,130,25,"Bad Dumps")
  CheckBoxGadget(#RERELEASE_BUTTON,5,130,130,25,"Re-Releases")
  CheckBoxGadget(#ADULT_BUTTON,5,155,130,25,"Adult Games")
  CheckBoxGadget(#A16K_BUTTON,5,180,130,25,"16k Games")
  CheckBoxGadget(#A16K_48K_BUTTON,5,205,130,25,"16K-48K Games")
  CheckBoxGadget(#A48K_BUTTON,5,230,130,25,"48K Games")
  CheckBoxGadget(#A48K_128K_BUTTON,5,255,130,25,"48K-128K Games")
  CheckBoxGadget(#A128K_BUTTON,5,280,130,25,"128K Games")
  CheckBoxGadget(#CSSCGC_BUTTON,5,305,130,25,"CSSCGC Games")
  CheckBoxGadget(#CRACKED_BUTTON,5,330,130,25,"Cracked Games")
  CheckBoxGadget(#MASTER_TAPE_BUTTON,5,355,130,25,"Master Tapes")
  CheckBoxGadget(#COVER_TAPE_BUTTON,5,380,130,25,"Cover Tapes")
  CheckBoxGadget(#TRAINED_BUTTON,5,405,130,25,"Trained Game")
  CheckBoxGadget(#LENSLOK_BUTTON,5,430,130,25,"Lenslok Protected")
  CheckBoxGadget(#MODIFIED_BUTTON,5,455,130,25,"Modified Games")
  CheckBoxGadget(#PASSWORDED_BUTTON,5,480,130,25,"Passworded Games")
  
  ButtonGadget(#REFRESH_BUTTON,5,520,75,30,"Refresh")
  ButtonGadget(#RESET_BUTTON,85,520,75,30,"Toggle")
  
  CloseGadgetList()
  
  ButtonGadget(#LOAD_BUTTON,630,565,80,30,"Scan",#PB_Button_Default) 
  ButtonGadget(#EXPORT_BUTTON,715,565,80,30,"Export",#PB_Button_Default) 
  
  Set_Filter_Gadgets(#True)
  Toggle_Filter_Gadgets(#True)
    
EndProcedure

Procedure Draw_Main_Window()
  
  OpenWindow(#MAIN_WINDOW, 0, 0, 800, 600, W_Title, #PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_MinimizeGadget)
  
EndProcedure

;- ############### Database Procedures

Procedure Scrape_Data()
  
  Protected output$, count
  
  ForEach SGS_Database()
       
    output$=SGS_Database()\SGS_File
    
    ; Extract Name
    
    SGS_Database()\SGS_Name=Trim(Left(output$,FindString(output$," (",0)))    
    SGS_Database()\SGS_Format=GetExtensionPart(SGS_Database()\SGS_File)
    SGS_Database()\SGS_Alt=-1 
    SGS_Database()\SGS_Country="GB"  
    SGS_Database()\SGS_Language="en"
    SGS_Database()\SGS_Verified=#False   
    SGS_Database()\SGS_Memory="48K"
    
    ; Extract Year
    
    CreateRegularExpression(#REGEX,"(19|20)\d{2}")
    ExamineRegularExpression(#REGEX,output$)
    While NextRegularExpressionMatch(#REGEX)
      SGS_Database()\SGS_Year=RegularExpressionMatchString(#REGEX)
    Wend
    FreeRegularExpression(#REGEX)
     
    ; Check if Verified
    
    If FindString(output$,"[!]") : SGS_Database()\SGS_Verified=#True : EndIf
   
    ; Check if hack
    
    If FindString(output$,"[h]") : SGS_Database()\SGS_Hack=#True : EndIf
    If FindString(output$,"[h ") : SGS_Database()\SGS_Hack=#True : EndIf    

    ; Check if trained
    
    If FindString(output$,"[t]") : SGS_Database()\SGS_Trained=#True : EndIf
    If FindString(output$,"[t ") : SGS_Database()\SGS_Trained=#True : EndIf
    
    ; Check if cracked
    
    If FindString(output$,"[cr]") : SGS_Database()\SGS_Cracked=#True : EndIf
    If FindString(output$,"[cr ") : SGS_Database()\SGS_Cracked=#True : EndIf
    
    ; Check if modified
    
    If FindString(output$,"[m]") : SGS_Database()\SGS_Modified=#True : EndIf
    If FindString(output$,"[m ") : SGS_Database()\SGS_Modified=#True : EndIf
        
    ; Check if fixed
    
    If FindString(output$,"[f]") : SGS_Database()\SGS_Fixed=#True : EndIf
    If FindString(output$,"[f ") : SGS_Database()\SGS_Fixed=#True : EndIf
    
    ; Check if bad dump
    
    If FindString(output$,"[b]") : SGS_Database()\SGS_Bad_Dump=#True : EndIf
    
    ; Check for re-release
    
    If FindString(output$,"[re-release]") : SGS_Database()\SGS_ReRelease=#True : EndIf
    
    ; Check for passworded
    
    If FindString(output$,"[passworded]") : SGS_Database()\SGS_Passworded=#True : EndIf
    
    ; Check for cover tape
    
    If FindString(output$,"Covertape]") : SGS_Database()\SGS_Covertape=#True : EndIf
    
    ; Check for master tape
    
    If FindString(output$,"[master-tape]") : SGS_Database()\SGS_Master_Tape=#True : EndIf
    If FindString(output$,"[master tape]") : SGS_Database()\SGS_Master_Tape=#True : EndIf
        
    ; Check for adult
    
    If FindString(output$,"[adult]") : SGS_Database()\SGS_Adult=#True : EndIf
    
    ; Check for loader
    
    If FindString(output$,"[SpeedLock 1]") : SGS_Database()\SGS_Loader="SpeedLock 1" : output$=RemoveString(output$,"["+SGS_Database()\SGS_Loader+"]") : EndIf
    If FindString(output$,"[SpeedLock 2]") : SGS_Database()\SGS_Loader="SpeedLock 2" : output$=RemoveString(output$,"["+SGS_Database()\SGS_Loader+"]") : EndIf
    If FindString(output$,"[SpeedLock 3]") : SGS_Database()\SGS_Loader="SpeedLock 3" : output$=RemoveString(output$,"["+SGS_Database()\SGS_Loader+"]") : EndIf
    If FindString(output$,"[SpeedLock 4]") : SGS_Database()\SGS_Loader="SpeedLock 4" : output$=RemoveString(output$,"["+SGS_Database()\SGS_Loader+"]") : EndIf
    If FindString(output$,"[SpeedLock 5]") : SGS_Database()\SGS_Loader="SpeedLock 5" : output$=RemoveString(output$,"["+SGS_Database()\SGS_Loader+"]") : EndIf
    If FindString(output$,"[SpeedLock 6]") : SGS_Database()\SGS_Loader="SpeedLock 6" : output$=RemoveString(output$,"["+SGS_Database()\SGS_Loader+"]") : EndIf
    If FindString(output$,"[SpeedLock 7]") : SGS_Database()\SGS_Loader="SpeedLock 7" : output$=RemoveString(output$,"["+SGS_Database()\SGS_Loader+"]") : EndIf
    If FindString(output$,"[BleepLoad]") : SGS_Database()\SGS_Loader="BleepLoad" : output$=RemoveString(output$,"["+SGS_Database()\SGS_Loader+"]") : EndIf
    If FindString(output$,"[Power-Load]") : SGS_Database()\SGS_Loader="Power-Load" : output$=RemoveString(output$,"["+SGS_Database()\SGS_Loader+"]") : EndIf
    If FindString(output$,"[Poliload]") : SGS_Database()\SGS_Loader="Poliload" : output$=RemoveString(output$,"["+SGS_Database()\SGS_Loader+"]") : EndIf
    If FindString(output$,"[ZetaLoad]") : SGS_Database()\SGS_Loader="ZetaLoad" : output$=RemoveString(output$,"["+SGS_Database()\SGS_Loader+"]") : EndIf
    
    ; Check for CSSCGC
    
    If FindString(output$,"[CSSCGC]") : SGS_Database()\SGS_CSSCGC=#True : output$=RemoveString(output$,"[CSSCGC]") : EndIf
    
    ; Check for Protection
    
    If FindString(output$,"[Alkatraz Protection System]") : SGS_Database()\SGS_Protection="Alkatraz Protection System" : output$=RemoveString(output$,"["+SGS_Database()\SGS_Protection+"]") : EndIf
    If FindString(output$,"[Lenslok]") : SGS_Database()\SGS_Protection="Lenslok" : output$=RemoveString(output$,"["+SGS_Database()\SGS_Protection+"]") : EndIf
    If FindString(output$,"[Softlock]") : SGS_Database()\SGS_Protection="Softlock" : output$=RemoveString(output$,"["+SGS_Database()\SGS_Protection+"]") : EndIf
    
    ; Check for memory
    
    If FindString(output$,"(16K)") : SGS_Database()\SGS_Memory="16K" : output$=RemoveString(output$,"(16K)") : EndIf
    If FindString(output$,"(16K-48K)") : SGS_Database()\SGS_Memory="16K-48K" : output$=RemoveString(output$,"(16K-48K)") : EndIf
    If FindString(output$,"(48K-128K)") : SGS_Database()\SGS_Memory="48K-128K" : output$=RemoveString(output$,"(48K-128K)") : EndIf
    If FindString(output$,"(128K)") : SGS_Database()\SGS_Memory="128K" : output$=RemoveString(output$,"(128K)") : EndIf
       
    ; Check for alternates
    
    If FindString(output$,"[a]") : SGS_Database()\SGS_Alt=0 : output$=RemoveString(output$,"[a]") : EndIf
    If FindString(output$,"[a1]") : SGS_Database()\SGS_Alt=1 : output$=RemoveString(output$,"[a1]") : EndIf
    If FindString(output$,"[a2]") : SGS_Database()\SGS_Alt=2 : output$=RemoveString(output$,"[a2]") : EndIf
    If FindString(output$,"[a3]") : SGS_Database()\SGS_Alt=3 : output$=RemoveString(output$,"[a3]") : EndIf
    If FindString(output$,"[a4]") : SGS_Database()\SGS_Alt=4 : output$=RemoveString(output$,"[a4]") : EndIf
    If FindString(output$,"[a5]") : SGS_Database()\SGS_Alt=5 : output$=RemoveString(output$,"[a5]") : EndIf
    If FindString(output$,"[a6]") : SGS_Database()\SGS_Alt=6 : output$=RemoveString(output$,"[a6]") : EndIf
    
    ; Scrape Countries
    
    If FindString(output$,"(AE)") : SGS_Database()\SGS_Country="AE" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(AL)") : SGS_Database()\SGS_Country="AL" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(AR)") : SGS_Database()\SGS_Country="AR" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(AS)") : SGS_Database()\SGS_Country="AS" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(AT)") : SGS_Database()\SGS_Country="AT" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(AU)") : SGS_Database()\SGS_Country="AU" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(BA)") : SGS_Database()\SGS_Country="BA" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(BE)") : SGS_Database()\SGS_Country="BE" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(BG)") : SGS_Database()\SGS_Country="BG" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(BR)") : SGS_Database()\SGS_Country="BR" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(CA)") : SGS_Database()\SGS_Country="CA" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(CH)") : SGS_Database()\SGS_Country="CH" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(CL)") : SGS_Database()\SGS_Country="CL" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(CN)") : SGS_Database()\SGS_Country="CN" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(CS)") : SGS_Database()\SGS_Country="CS" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(CY)") : SGS_Database()\SGS_Country="CY" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(CZ)") : SGS_Database()\SGS_Country="CZ" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(DE)") : SGS_Database()\SGS_Country="DE" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(DK)") : SGS_Database()\SGS_Country="DK" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(EE)") : SGS_Database()\SGS_Country="EE" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(EG)") : SGS_Database()\SGS_Country="EG" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(ES)") : SGS_Database()\SGS_Country="ES" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(EU)") : SGS_Database()\SGS_Country="EU" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(FI)") : SGS_Database()\SGS_Country="FI" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(FR)") : SGS_Database()\SGS_Country="FR" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(GB)") : SGS_Database()\SGS_Country="GB" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(GR)") : SGS_Database()\SGS_Country="GR" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(HK)") : SGS_Database()\SGS_Country="HK" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(HR)") : SGS_Database()\SGS_Country="HR" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(HU)") : SGS_Database()\SGS_Country="HU" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(ID)") : SGS_Database()\SGS_Country="ID" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(IE)") : SGS_Database()\SGS_Country="IE" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(IL)") : SGS_Database()\SGS_Country="IL" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(IN)") : SGS_Database()\SGS_Country="IN" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(IR)") : SGS_Database()\SGS_Country="IR" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(IS)") : SGS_Database()\SGS_Country="IS" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(IT)") : SGS_Database()\SGS_Country="IT" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(JO)") : SGS_Database()\SGS_Country="JO" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(JP)") : SGS_Database()\SGS_Country="JP" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(KR)") : SGS_Database()\SGS_Country="KR" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(LT)") : SGS_Database()\SGS_Country="LT" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(LU)") : SGS_Database()\SGS_Country="LU" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(LV)") : SGS_Database()\SGS_Country="LV" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(MN)") : SGS_Database()\SGS_Country="MN" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(MX)") : SGS_Database()\SGS_Country="MX" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(MY)") : SGS_Database()\SGS_Country="MY" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(NL)") : SGS_Database()\SGS_Country="NL" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(NO)") : SGS_Database()\SGS_Country="NO" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(NP)") : SGS_Database()\SGS_Country="NP" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(NZ)") : SGS_Database()\SGS_Country="NZ" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(OM)") : SGS_Database()\SGS_Country="OM" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(PE)") : SGS_Database()\SGS_Country="PE" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(PH)") : SGS_Database()\SGS_Country="PH" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(PL)") : SGS_Database()\SGS_Country="PL" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(PT)") : SGS_Database()\SGS_Country="PT" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(QA)") : SGS_Database()\SGS_Country="QA" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(RO)") : SGS_Database()\SGS_Country="RO" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(RS)") : SGS_Database()\SGS_Country="RS" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(RU)") : SGS_Database()\SGS_Country="RU" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(SE)") : SGS_Database()\SGS_Country="SE" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(SG)") : SGS_Database()\SGS_Country="SG" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(SI)") : SGS_Database()\SGS_Country="SI" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(SK)") : SGS_Database()\SGS_Country="SK" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(TH)") : SGS_Database()\SGS_Country="TH" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(TR)") : SGS_Database()\SGS_Country="TR" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(TW)") : SGS_Database()\SGS_Country="TW" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(US)") : SGS_Database()\SGS_Country="US" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(VN)") : SGS_Database()\SGS_Country="VN" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(YU)") : SGS_Database()\SGS_Country="YU" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    If FindString(output$,"(SA)") : SGS_Database()\SGS_Country="SA" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Country+")") : EndIf
    
    If FindString(output$,"(ar)") : SGS_Database()\SGS_Language="ar" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Language+")") : EndIf
    If FindString(output$,"(bg)") : SGS_Database()\SGS_Language="bg" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Language+")") : EndIf
    If FindString(output$,"(bs)") : SGS_Database()\SGS_Language="bs" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Language+")") : EndIf
    If FindString(output$,"(cs)") : SGS_Database()\SGS_Language="cs" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Language+")") : EndIf
    If FindString(output$,"(cy)") : SGS_Database()\SGS_Language="cy" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Language+")") : EndIf
    If FindString(output$,"(da)") : SGS_Database()\SGS_Language="da" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Language+")") : EndIf
    If FindString(output$,"(de)") : SGS_Database()\SGS_Language="de" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Language+")") : EndIf
    If FindString(output$,"(el)") : SGS_Database()\SGS_Language="el" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Language+")") : EndIf
    If FindString(output$,"(en)") : SGS_Database()\SGS_Language="en" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Language+")") : EndIf
    If FindString(output$,"(en-es)") : SGS_Database()\SGS_Language="en-es" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Language+")") : EndIf
    If FindString(output$,"(en-ru)") : SGS_Database()\SGS_Language="en-ru" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Language+")") : EndIf
    If FindString(output$,"(en-sk)") : SGS_Database()\SGS_Language="en-sk" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Language+")") : EndIf
    If FindString(output$,"(eo)") : SGS_Database()\SGS_Language="eo" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Language+")") : EndIf
    If FindString(output$,"(es)") : SGS_Database()\SGS_Language="es" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Language+")") : EndIf
    If FindString(output$,"(et)") : SGS_Database()\SGS_Language="et" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Language+")") : EndIf
    If FindString(output$,"(fa)") : SGS_Database()\SGS_Language="fa" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Language+")") : EndIf
    If FindString(output$,"(fi)") : SGS_Database()\SGS_Language="fi" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Language+")") : EndIf
    If FindString(output$,"(fr)") : SGS_Database()\SGS_Language="fr" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Language+")") : EndIf
    If FindString(output$,"(ga)") : SGS_Database()\SGS_Language="ga" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Language+")") : EndIf
    If FindString(output$,"(gu)") : SGS_Database()\SGS_Language="gu" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Language+")") : EndIf
    If FindString(output$,"(he)") : SGS_Database()\SGS_Language="he" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Language+")") : EndIf
    If FindString(output$,"(hi)") : SGS_Database()\SGS_Language="hi" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Language+")") : EndIf
    If FindString(output$,"(hr)") : SGS_Database()\SGS_Language="hr" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Language+")") : EndIf
    If FindString(output$,"(hu)") : SGS_Database()\SGS_Language="hu" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Language+")") : EndIf
    If FindString(output$,"(is)") : SGS_Database()\SGS_Language="is" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Language+")") : EndIf
    If FindString(output$,"(it)") : SGS_Database()\SGS_Language="it" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Language+")") : EndIf
    If FindString(output$,"(ja)") : SGS_Database()\SGS_Language="ja" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Language+")") : EndIf
    If FindString(output$,"(ko)") : SGS_Database()\SGS_Language="ko" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Language+")") : EndIf
    If FindString(output$,"(lt)") : SGS_Database()\SGS_Language="lt" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Language+")") : EndIf
    If FindString(output$,"(lv)") : SGS_Database()\SGS_Language="lv" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Language+")") : EndIf
    If FindString(output$,"(ms)") : SGS_Database()\SGS_Language="ms" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Language+")") : EndIf
    If FindString(output$,"(nl)") : SGS_Database()\SGS_Language="nl" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Language+")") : EndIf
    If FindString(output$,"(no)") : SGS_Database()\SGS_Language="no" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Language+")") : EndIf
    If FindString(output$,"(pl)") : SGS_Database()\SGS_Language="pl" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Language+")") : EndIf
    If FindString(output$,"(pt)") : SGS_Database()\SGS_Language="pt" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Language+")") : EndIf
    If FindString(output$,"(ro)") : SGS_Database()\SGS_Language="ro" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Language+")") : EndIf
    If FindString(output$,"(ru)") : SGS_Database()\SGS_Language="ru" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Language+")") : EndIf
    If FindString(output$,"(sh)") : SGS_Database()\SGS_Language="sh" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Language+")") : EndIf
    If FindString(output$,"(sk)") : SGS_Database()\SGS_Language="sk" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Language+")") : EndIf
    If FindString(output$,"(sl)") : SGS_Database()\SGS_Language="sl" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Language+")") : EndIf
    If FindString(output$,"(sq)") : SGS_Database()\SGS_Language="sq" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Language+")") : EndIf
    If FindString(output$,"(sr)") : SGS_Database()\SGS_Language="sr" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Language+")") : EndIf
    If FindString(output$,"(sv)") : SGS_Database()\SGS_Language="sv" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Language+")") : EndIf
    If FindString(output$,"(th)") : SGS_Database()\SGS_Language="th" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Language+")") : EndIf
    If FindString(output$,"(tr)") : SGS_Database()\SGS_Language="tr" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Language+")") : EndIf
    If FindString(output$,"(ur)") : SGS_Database()\SGS_Language="ur" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Language+")") : EndIf
    If FindString(output$,"(vi)") : SGS_Database()\SGS_Language="vi" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Language+")") : EndIf
    If FindString(output$,"(yi)") : SGS_Database()\SGS_Language="yi" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Language+")") : EndIf
    If FindString(output$,"(zh)") : SGS_Database()\SGS_Language="zh" : output$=RemoveString(output$,"("+SGS_Database()\SGS_Language+")") : EndIf  

    If SGS_Database()\SGS_Year="" : SGS_Database()\SGS_Year="19xx" : EndIf  
    
  Next
 
EndProcedure

Procedure Process_TOSEC()
  
  Protected Count
  
  ForEach File_List()
    AddElement(SGS_Database())
    SGS_Database()\SGS_File=GetFilePart(File_List())
    SGS_Database()\SGS_Folder=GetPathPart(File_List())
    SGS_Database()\SGS_Size=FileSize(File_List())
  Next
  
  Scrape_Data()
      
EndProcedure

Procedure Load_Tosec_Folder()
  
  ClearList(SGS_Database())
  ClearList(File_List())
  
  Path=PathRequester("Select Folder",Home_Path)
  
  If Path<>""
    
    OpenConsole("Loading TOSEC files...")
    Center_Console()
    
    PrintN("Scanning folder...")
    
    List_Files_Recursive(Path,File_List(),"*.*")
    
    PrintN("")
    PrintN(Str(ListSize(File_List()))+" scanned...")
    PrintN("")
    
    PrintN("Scraping data...")
    
    Process_TOSEC()
    
    If ListSize(SGS_Database())>0
      Toggle_Filter_Gadgets(#False)
      DisableGadget(#EXPORT_BUTTON,#False)
    EndIf
    
    CloseConsole()
    
    SelectElement(SGS_Database(),0)
    
    ClearList(File_List())
    
  Else
    
    MessageRequester("Error","No Path Selected!",#PB_MessageRequester_Error|#PB_MessageRequester_Ok)
    
  EndIf
  
EndProcedure

;- ############### Init Program

Draw_Main_Window()
Draw_Gadgets()

;- ############### Main Loop

Repeat
  
  event=WaitWindowEvent()
  gadget=EventGadget()
  type=EventType()
  
  Select event
      
    Case #PB_Event_CloseWindow
      If EventWindow()=#MAIN_WINDOW
        End
      EndIf
      
    Case #PB_Event_Gadget
      
      Select gadget
          
        Case #MAIN_LIST
          If ListSize(SGS_Database())>0
            If type=#PB_EventType_LeftClick
              SelectElement(SGS_Database(),GetGadgetState(#MAIN_LIST))
            EndIf
          EndIf
          
        Case #LOAD_BUTTON
          Load_Tosec_Folder()
          Draw_List()
          
        Case #EXPORT_BUTTON
          Export_Window()
          ShowWindow_(WindowID(#MAIN_WINDOW), #SW_NORMAL)
          SetForegroundWindow_(WindowID(#MAIN_WINDOW))
          
        Case #REFRESH_BUTTON
          Draw_List()
          
        Case #RESET_BUTTON
          If filter=#True
            filter=#False
          Else
            filter=#True
          EndIf
          Set_Filter_Gadgets(filter)
          
      EndSelect
      
  EndSelect

ForEver

; IDE Options = PureBasic 6.12 LTS (Windows - x64)
; CursorPosition = 400
; FirstLine = 215
; Folding = EAgR9
; Optimizer
; EnableXP
; DPIAware
; UseIcon = rainbow.ico
; CurrentDirectory = E:\Speccy Stuff\Games\[TAP]\
; Compiler = PureBasic 6.12 LTS (Windows - x64)
; Debugger = Standalone