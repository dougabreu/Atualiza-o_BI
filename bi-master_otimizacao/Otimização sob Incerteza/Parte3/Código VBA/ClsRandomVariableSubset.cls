VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "ClsRandomVariableSubset"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit
Option Compare Text

' Copyright 2015 Howard J Rudd
'
' Licensed under the Apache License, Version 2.0 (the "License");
' you may not use this file except in compliance with the License.
' You may obtain a copy of the License at
'
'    http://www.apache.org/licenses/LICENSE-2.0
'
' Unless required by applicable law or agreed to in writing, this software
' is distributed on an "AS IS" BASIS WITHOUT WARRANTIES OR CONDITIONS OF
' ANY KIND, either express or implied, not even for MERCHANTABILITY or
' FITNESS FOR A PARTICULAR PURPOSE. See the License for the specific language
' governing permissions and limitations under the License. You are free to use
' this code as you wish within the provisions of the license but it is your
' responsibility to test it and ensure it is fit for the use to which you
' intend to put it.
'
' _____________________________________________________________________________


' This class generates objects that contain sample matrices, other
' parameters and methods relating to subsets of the variables

Private i As Long
Private j As Long

Private pNumVars As Long
Private pNumIters As Long

Private pSubsetName As String
Private pVariableName() As String
Private pVariableSheet() As String
Private pVariableRange() As String
Private v As Double
Private w As Double
Private x As Double
Private pTempStore() As Variant

Private pCorrelationMatrixSheet As String
Private pCorrelationMatrixRange As String
Private pCorrelationMatrix() As Double
Private pGap As Long

Private pQuantileIndex As Long
Private pQuantileAbscissa As Double
Private pVariance As Double

Private pOrderedSample() As Double
Private pTempSample() As Double
Private pSample() As Double

Public Property Let SubsetName(text As String)
    pSubsetName = text
End Property

Public Property Get SubsetName() As String
     SubsetName = pSubsetName
End Property

Public Property Let NumVars(Number As Long)
    pNumVars = Number
End Property

Public Property Get NumVars() As Long
    NumVars = pNumVars
End Property

Public Property Let NumIters(Number As Long)
    pNumIters = Number
End Property

Public Property Get NumIters() As Long
    NumIters = pNumIters
End Property

Public Property Let VariableName(Index As Long, Desc As String)
    pVariableName(Index) = Desc
End Property

Public Property Get VariableName(Index As Long) As String
    VariableName = pVariableName(Index)
End Property

Public Property Let VariableSheet(Index As Long, Desc As String)
    pVariableSheet(Index) = Desc
End Property

Public Property Get VariableSheet(Index As Long) As String
    VariableSheet = pVariableSheet(Index)
End Property

Public Property Let VariableRange(Index As Long, Desc As String)
    pVariableRange(Index) = Desc
End Property

Public Property Get VariableRange(Index As Long) As String
    VariableRange = pVariableRange(Index)
End Property

Public Property Let TempStore(Index As Long, Value As Variant)
    pTempStore(Index) = Value
End Property

Public Property Get TempStore(Index As Long) As Variant
    TempStore = pTempStore(Index)
End Property

Public Property Let OrderedSample(rowIndex As Long, colIndex As Long, Value As Double)
    pOrderedSample(rowIndex, colIndex) = Value
End Property

Public Property Get OrderedSample(rowIndex As Long, colIndex As Long) As Double
    OrderedSample = pOrderedSample(rowIndex, colIndex)
End Property

Public Property Let Sample(rowIndex As Long, colIndex As Long, Value As Double)
    pSample(rowIndex, colIndex) = Value
End Property

Public Property Get Sample(rowIndex As Long, colIndex As Long) As Double
    Sample = pSample(rowIndex, colIndex)
End Property

Public Property Get CorrelationMatrix(rowIndex As Long, colIndex As Long) As Double
    CorrelationMatrix = pCorrelationMatrix(rowIndex, colIndex)
End Property

Public Property Let CorrelationMatrixSheet(Desc As String)
    pCorrelationMatrixSheet = Desc
End Property

Public Property Get CorrelationMatrixSheet() As String
    CorrelationMatrixSheet = pCorrelationMatrixSheet
End Property

Public Property Let CorrelationMatrixRange(Desc As String)
    pCorrelationMatrixRange = Desc
End Property

Public Property Get CorrelationMatrixRange() As String
    CorrelationMatrixRange = pCorrelationMatrixRange
End Property

Public Sub Size()

    ReDim pVariableName(1 To pNumVars)
    ReDim pVariableSheet(1 To pNumVars)
    ReDim pVariableRange(1 To pNumVars)
    ReDim pTempStore(1 To pNumVars)
    ReDim pTempSample(1 To pNumIters) As Double
    ReDim pOrderedSample(1 To pNumIters, 1 To pNumVars)
    ReDim pSample(1 To pNumIters, 1 To pNumVars)
    
End Sub

Public Sub GenerateIndependentSample()

' This routine makes a copy of the ordered sample matrix and randomly shuffles
' the elements of each column. Each column is shuffled independently of the
' others.
       
    pSample = pOrderedSample

    For i = 1 To pNumVars
        Call shuffle(pSample, i)
    Next i
    
End Sub

Private Sub ImportCorrelationMatrix()

' Imports values from a worksheet and assigns them to an array inside the
' object. The values must be contained in the upper triangular half of a square
' array of cells. These are assumed to form the upper triangular half of a
' symmetric matrix. The lower half is generated by reflection in the diagonal.
' The user only needs to enter the upper triangular half. Row and column
' headings are added to the user-inputted array to enable the user to check
' that the correlation coefficients s/he entered correspond to the correct pair
' of variables. The colour of the cells from which values were imported is
' changed to enable the user to tell that the correct cells have been imported.
' A copy of the full array is printed below the user-inputted array to confirm
' that it has been imported correctly.

    ReDim pCorrelationMatrix(1 To pNumVars, 1 To pNumVars)
            
    With ThisWorkbook.Sheets(pCorrelationMatrixSheet).Range(pCorrelationMatrixRange)
        
      ' Test that the chosen range is square
        If Not .Rows.Count = .Columns.Count Then
      ' Error message
            Err.Raise Number:=vbObjectError + 1, _
            Source:="ImportCorrelationMatrix", _
            Description:="Correlation matrix range not square"
        End If
        
      ' Test that the range is the correct size for the number of variables
        If Not (.Rows.Count = pNumVars And .Columns.Count = pNumVars) Then
      ' Error message
            Err.Raise Number:=vbObjectError + 2, _
            Source:="ImportCorrelationMatrix", _
            Description:="Correlation matrix size doesn't match number of variables"
        End If
        
      ' Test that the diagonal elements are all unity
        For i = 1 To pNumVars
        ' Debug.Print "diagonal element = " & .Cells(i, i).Value
            If Not (.Cells(i, i).Value = 1) Then
                Debug.Print "error criterion met: " & i
                Err.Raise Number:=vbObjectError + 3, _
                Source:="ImportCorrelationMatrix", _
                Description:="Correlation matrix diagonal elements not all unity"
            End If
        Next i
        
        For i = 1 To pNumVars
            For j = i To pNumVars
              
              ' Import cells into array
                pCorrelationMatrix(i, j) = .Cells(i, j)
                
              ' Write column headings above or below matrix range
                If .Cells(1, 1).Row > 1 Then
                    'Debug.Print .Cells(1, 1).Row
                   .Cells(1, j).Offset(rowOffset:=-1).Value = pVariableName(j)
                Else
                   .Cells(1 + pNumVars, j).Value = pVariableName(j)
                End If
                
              ' Write row headinsg to the right of matrix range
               .Cells(i, pNumVars + 1).Value = pVariableName(i)
              
              ' Shade cells or, if already shaded, change colour
                With .Cells(i, j).Interior
                    If .Color = RGB(240, 240, 240) Then
                        .Color = RGB(200, 240, 240)
                    Else
                        .Color = RGB(240, 240, 240)
                    End If
                End With
            Next j
        Next i
    End With
        
    For i = 2 To pNumVars
        For j = 1 To i - 1
            pCorrelationMatrix(i, j) = pCorrelationMatrix(j, i)
        Next j
    Next i
    
    ' Write a copy of the full correlation matrix below the user-entered one to
    ' confirm that it has been imported correctly.
    pGap = 5
    With ThisWorkbook.Sheets(pCorrelationMatrixSheet).Range(pCorrelationMatrixRange)
        For i = 1 To pNumVars
            For j = 1 To pNumVars
                .Cells(i + pNumVars + pGap, j).Value = pCorrelationMatrix(i, j)
                .Cells(i + pNumVars + pGap, pNumVars + 1).Value = pVariableName(i)
                .Cells(pNumVars + pGap, j).Value = pVariableName(j)
            Next j
        Next i
    End With
    
End Sub

Public Sub GenerateCorrelatedSample()
    Call ImportCorrelationMatrix
    pSample = ic(pOrderedSample, pCorrelationMatrix)
End Sub

Public Sub GenerateOrderedSample()
' need some tests to test whether pOrderedSample already contains numbers.
pOrderedSample = pSample
    For j = 1 To pNumVars
        Call quicksort(pOrderedSample, j)
    Next j
End Sub

Public Property Get Min(Index As Long) As Double
    Min = pOrderedSample(1, Index)
End Property

Public Property Get Max(Index As Long) As Double
    Max = pOrderedSample(pNumIters, Index)
End Property

Public Property Get Quantile(Probability As Double, colIndex As Long) As Double

' Returns a value, x, such that the fraction of members of the sample that are
' <= x is equal to "probability". Values that are not exactly equal to numbers
' in the sample are calculated by linear interpolation between the two adjacent
' sample elements. "colIndex" is the column number.
'

' Test that probability is valid
    If (Probability < 1 / (NumIters + 1)) Or (Probability > NumIters / (NumIters + 1)) Then
      ' Error message
        Err.Raise Number:=vbObjectError + 4, _
        Source:="Subset.Quantile", _
        Description:="Probability outside of valid range"
        Exit Function
    End If
    
    pQuantileAbscissa = Probability * (pNumIters + 1)
    pQuantileIndex = Int(pQuantileAbscissa)
    Quantile = pOrderedSample(pQuantileIndex, colIndex) + _
              (pOrderedSample((pQuantileIndex + 1), colIndex) - _
               pOrderedSample(pQuantileIndex, colIndex)) * _
              (pQuantileAbscissa - pQuantileIndex)

End Property

Private Function pSampleSum(colIndex As Long) As Double
    x = 0
    For i = 1 To pNumIters
        x = x + pSample(i, colIndex)
    Next i
    pSampleSum = x
End Function

Public Property Get SampleMean(colIndex As Long) As Double
    SampleMean = pSampleSum(colIndex) / pNumIters
End Property

Public Property Get CumulativeAbscissa(rowIndex As Long, colIndex As Long) As Double
    CumulativeAbscissa = pOrderedSample(rowIndex, colIndex)
End Property

Public Property Get CumulativeOrdinate(rowIndex As Long, colIndex As Long) As Double
    CumulativeOrdinate = rowIndex / (NumIters + 1)
End Property

Public Property Get Variance(colIndex As Long) As Double

    w = 0
    i = 0
    Do
        v = 0
        Do
            i = i + 1
            v = v + pSample(i, colIndex) ^ 2
        Loop Until (v >= 9E+300 Or i = pNumIters)
        w = w + (v / pNumIters)
    Loop Until i = pNumIters
    Variance = w - (pSampleSum(colIndex) / pNumIters) ^ 2

End Property
