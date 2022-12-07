Attribute VB_Name = "Macro"
' This macro creates the JSON equivalent of the Excel file compatible with html visuals
'
' WebTreeView (c) by Erwan Hamon
' WebTreeView is licensed under a MIT License
' https://github.com/ThalesGroup/WebTreeView

Sub SaveToHTML(json)
    Dim html As String
    Dim template, placeholder, strFileExists As String
    Dim my_file As Integer
    Dim text_line As String
    
    template = ActiveWorkbook.Path & "\WebViewTemplate.html"
    placeholder = "VBA EXPORT PLACEHOLDER"

    strFileExists = Dir(template)
 
    If strFileExists = "" Then
        MsgBox "Template file not found " & template
        Exit Sub
    End If

    my_file = FreeFile()
    Open template For Input As my_file

    While Not EOF(my_file)
        Line Input #my_file, text_line
        If InStr(text_line, placeholder) Then
            html = html & json
        Else
            html = html & text_line & vbCrLf
        End If
    Wend
    Close my_file
    SaveToFile (html)
End Sub

Sub SaveToFile(html)
    Dim fso As Object
    Set fso = CreateObject("Scripting.FileSystemObject")
    Dim oFile As Object
    Set oFile = fso.CreateTextFile(ActiveWorkbook.Path & "\WebView.html")
    oFile.WriteLine html
    oFile.Close
    Set fso = Nothing
    Set oFile = Nothing
    MsgBox ("File " & ActiveWorkbook.Path & "\WebView.html saved")
End Sub


Function genJSON_SC() As String
    Dim tb As String                ' Tabulation
    Dim index As Integer            ' Current row
    Dim json As String              ' Output JSON string
    
    index = 2
    tb = "    "
    json = "{" & vbCrLf
    
    Sheets("Scenarios").Activate
    Do While Not IsEmpty(Cells(index, 1))
        json = json & tb & """sc" & Cells(index, 1) & """: {""name"": """ & Cells(index, 2) & """, ""color"": """ & "#FFFFFF" & """}"
        If Not IsEmpty(Cells(index + 1, 1)) Then
            json = json & ","
        End If
        json = json & vbCrLf
        index = index + 1
    Loop
    Sheets("Attack Paths").Activate
    
    genJSON_SC = json & "  }"
End Function

Function genArray_AP() As String
    Dim index As Integer            ' Current row
    Dim json As String              ' Output JSON string
    Dim priotity As Integer         ' Index of priority column
    Dim scenario As Integer         ' Index of scenario column
    Dim level As Integer            ' Current tree level
    Dim n_level As Integer          ' Tree level of next row
    Dim still As Boolean            ' Still work to do
    Dim prio As String              ' Current leaf color
    Dim tb As String                ' Tabulation
    Dim i, j As Integer             ' For loop index
    
    tb = "    "
    index = 2
    Priority = 10
    scenario = 12
    json = "[" & vbCrLf
    level = 1
    still = True
    
    While (still)
        n_level = level + 1
        ' Look for tree level of the next line
        Do While IsEmpty(Cells(index + 1, n_level))
            n_level = n_level - 1
            ' Ugly but there is no lazy "And" evaluation in VBA !!!! (!!)
            If n_level = 0 Then
                Exit Do
            End If
        Loop
        ' If next line found
        
        For i = 0 To level - 1
            json = json & tb
        Next i
        If n_level <= level Then ' Leaf of the Tree
            prio = LCase(Cells(index, Priority))
            json = json & "{""text"": """ & Cells(index, level) & """, ""prio"": """ + prio + """"
            If Not IsEmpty(Cells(index, scenario)) Then
                json = json & ", ""scenario"": """ & Cells(index, scenario) & """"
            End If
            json = json & "}"
            If n_level = level Then
                json = json & ","
            End If
        Else ' New group
            json = json & "{""text"": """ & Cells(index, level) & """, ""children"": ["
        End If
        ' No comma for last entry
        If n_level = 0 Then
            still = False
        End If
        
        json = json & vbCrLf
        If n_level < level Then
            For i = 0 To level - n_level - 1
                For j = 0 To level - i - 2
                    json = json & tb
                Next j
                If level - i - 2 > -1 Then
                    json = json & "]}"
                Else
                    json = json & "]"
                End If
                If i = level - n_level - 1 Then
                    If level - i - 2 >= 0 Then
                        json = json & ","
                    End If
                End If
                json = json & vbCrLf
            Next i
        End If
        level = n_level
        index = index + 1
    Wend
    
    genArray_AP = json
End Function

Function genVERSION() As String
    Dim tb As String                ' Tabulation
    Dim index As Integer            ' Current row
    Dim json As String              ' Output JSON string
    
    index = 2
    tb = "    "
    json = "{" & vbCrLf
    
    Sheets("Version").Activate
    Do While (StrComp(Cells(index, 1), "Version") <> 0)
        index = index + 1
    Loop
    index = index + 1
    Do While Not IsEmpty(Cells(index, 1))
        index = index + 1
    Loop
    json = json & tb & """title"": """ & Cells(1, 2) & """," & vbCrLf
    json = json & tb & """version"": """ & Cells(index - 1, 1) & """," & vbCrLf
    json = json & tb & """date"": """ & Cells(index - 1, 2) & """" & vbCrLf
    json = json & "}"
    Sheets("Attack Paths").Activate
    
    genVERSION = json
End Function

Sub genJSON()
    Dim json As String
    
    Application.ScreenUpdating = False
    json = "{""roots"": "
    json = json & genArray_AP() & ","
    json = json & " ""scenarios"": " & genJSON_SC() & vbCrLf
    json = json & ", ""version"": " & genVERSION() & vbCrLf
    json = json & "}"
    Application.ScreenUpdating = True
    SaveToHTML (json)
End Sub

