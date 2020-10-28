Attribute VB_Name = "mc_admin_functions"
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


' This module contains the following functions that perform tests and actions
' on worksheets and charts:
'
'    1. RunModel()
'    2. IsSheetThere(SheetName)
'    3. TestAndAdd(String, Zoom)
'    4. Graphs(VarSet, NumBins, NumPoints, SheetTitle)
' _____________________________________________________________________________


Public Function RunModel(InputVariables As Collection, OutputVariables As Collection)

Dim Subset As ClsRandomVariableSubset
Dim Subset2 As ClsRandomVariableSubset
Dim num As Long, i As Long, j As Long

' Check that all subsets have the same value of NumIters
For Each Subset In InputVariables
    num = Subset.NumIters
    For Each Subset2 In InputVariables
        If Not (num = Subset2.NumIters) Then
            Err.Raise Number:=vbObjectError + 5, _
            Source:="RunModel", _
            Description:="Input variable subsets don't all have the same number of iterations"
            Exit Function
        End If
    Next Subset2
Next Subset

For Each Subset In OutputVariables
    If Not (num = Subset.NumIters) Then
            Err.Raise Number:=vbObjectError + 6, _
            Source:="RunModel", _
            Description:="Output variable subsets don't all have the same number of iterations as the input variables"
            Exit Function
    End If
Next Subset

For Each Subset In InputVariables
    For j = 1 To Subset.NumVars
        Subset.TempStore(j) = ThisWorkbook.Sheets(Subset.VariableSheet(j)).Range(Subset.VariableRange(j))
    Next j
Next Subset

Application.ScreenUpdating = False
Application.Calculation = xlCalculationManual
For i = 1 To num
    For Each Subset In InputVariables
        For j = 1 To Subset.NumVars
            ThisWorkbook.Sheets(Subset.VariableSheet(j)).Range(Subset.VariableRange(j)).Value2 = Subset.Sample(i, j)
        Next j
    Next Subset
    Application.Calculate
    For Each Subset2 In OutputVariables
        For j = 1 To Subset2.NumVars
            Subset2.Sample(i, j) = ThisWorkbook.Sheets(Subset2.VariableSheet(j)).Range(Subset2.VariableRange(j)).Value2
        Next j
    Next Subset2
Next i
Application.Calculation = xlCalculationAutomatic
Application.ScreenUpdating = True

For Each Subset In InputVariables
    For j = 1 To Subset.NumVars
        ThisWorkbook.Sheets(Subset.VariableSheet(j)).Range(Subset.VariableRange(j)) = Subset.TempStore(j)
    Next j
Next Subset

For Each Subset In OutputVariables
    Subset.GenerateOrderedSample
Next Subset

End Function


Public Function IsSheetThere(ByVal SheetName As String) As Boolean

' Usage: Y = IsSheetThere(SheetName)
'
' Determines whether or not a sheet named "sheetName" exists in the active
' workbook.

Dim TestSheet As Worksheet
Dim bReturn As Boolean
bReturn = False
    For Each TestSheet In ThisWorkbook.Worksheets
        If TestSheet.Name = SheetName Then
            bReturn = True
            Exit For
        End If
    Next TestSheet
IsSheetThere = bReturn
End Function

Public Function TestAndAdd(ByVal SheetName As String, Optional Zoom As Integer) As String

' Usage: Y = TestAndAdd(String, Zoom)
'
' Finds the smallest value of i such that a sheet called sheetNamei doesn't
' already exist and then creates a sheet called "SheetNamei".
'
' That is, it looks in this workbook for a worksheet named sheetName. If it
' doesn't find it, it creates it. If it does find sheetName, it searches for
' sheetName1. If it doesn't find sheetName1 it creates it. If it does find it,
' it sesarches for sheetName2 and so on.
'
' Returns the name of the added sheet as a string.

Dim TestName As String
Dim TempName As String
Dim i As Integer

' Assign the desired name to the string variable testName
If IsSheetThere(SheetName) = False Then
    TestName = SheetName
Else
    i = 2
    TempName = SheetName & i
    Do While IsSheetThere(TempName) = True
        i = i + 1
        TempName = SheetName & i
    Loop
TestName = TempName
End If

'Add a new sheet and change its .Name property to testName
Dim newSheet As Worksheet
Set newSheet = ThisWorkbook.Sheets.Add
newSheet.Name = TestName

' Adjust magnification
If Not IsMissing(Zoom) Then
    ThisWorkbook.Sheets(TestName).Activate
    ActiveWindow.Zoom = Zoom
End If

' Return name of added sheet as string
TestAndAdd = TestName
    
End Function


Public Function Graphs(VarSet As Collection, NumBins As Long, NumPoints As Long, SheetTitle As String)

' Usage: Graphs(VarSet As Collection, NumBins As Long, NumPoints As Long, _
                SheetTitle As String)
'
' Creates a new worksheet containing an array of embedded charts showing
' the frequency distributions of the outputs of the spreadsheet model.
'
' Calculates statistics and writes them into the worksheet.
'
' VarSet is a collection of ClsRandomVariableSubset objects.
'
' NumBins is the number of bins the the histogram.
'
' NumPoints is the number of points to be plotted in a cumulative distribution
' plot.
' _____________________________________________________________________________

' DECLARATIONS (in aphabetical order)

Dim AbsBinLeft As Double
Dim AbsBinRight As Double
Dim Absomax As Double
Dim BinContentCount() As Long
Dim BinLabels() As String
Dim BinLeft As Double
Dim BinRight As Double
Dim ChtHeightCells As Integer
Dim ChtHeightPts As Integer
Dim ChtHorizGapCells As Long
Dim ChtTopLeftCellColumn As Integer
Dim ChtTopLeftCellRow As Integer
Dim ChtVertGapCells As Long
Dim ChtWidthCells As Integer
Dim ChtWidthPts As Integer
Dim CumChtAbscissaRange() As Range
Dim CumChtOrdinateRange() As Range
Dim CumChtTitleRange() As Range
Dim CumSubsetRange As Range
Dim CumSubsetTitleRange As Range
Dim CumulativePlot() As Object
Dim DeltaX As Double
Dim Distribution() As Object
Dim ExponentX As Long
Dim EXsquared As Double
Dim Fstep As Long
Dim FXabscissa() As Double
Dim FXordinate() As Double
Dim HistChtAbscissaRange() As Range
Dim HistChtOrdinateRange() As Range
Dim HistChtTitleRange() As Range
Dim Histogram() As Object
Dim HistSigFigs As Integer
Dim HistSubsetRange As Range
Dim HistSubsetTitleRange As Range
Dim HOffset As Long
Dim i As Long
Dim j As Long
Dim k As Long
Dim l As Long
Dim LeftX As Double
Dim m As Long
Dim n As Long
Dim NumIters As Long
Dim NumVars As Long
Dim PreviousSubsetNumVars As Long
Dim PreviousSubsets As Long
Dim r As Long
Dim RightX As Double
Dim SampleMax As Double
Dim SampleMean As Double
Dim SampleMin As Double
Dim SampleSigma As Double
Dim SheetName As String
Dim StatsTopLeftCellColumn As Long
Dim StatsTopLeftCellRow As Long
Dim StatSubsetRange As Range
Dim str1 As String
Dim str2 As String
Dim StrExponentX As String
Dim StrX As String
Dim Subset As ClsRandomVariableSubset
Dim SubsetRowStride As Long
Dim SumFormula As String
Dim TotalPreviousNumVars As Long
Dim VOffset As Long
Dim x As Double
Dim y As Long

SheetName = TestAndAdd(SheetTitle, 75)

Application.ScreenUpdating = False
Application.Calculation = xlCalculationManual

ChtWidthCells = 5
ChtHeightCells = 15
ChtHorizGapCells = 2
ChtVertGapCells = 2

PreviousSubsets = 0
PreviousSubsetNumVars = 0
TotalPreviousNumVars = 0

For Each Subset In VarSet

    NumVars = Subset.NumVars
    NumIters = Subset.NumIters

    ReDim BinContentCount(1 To NumBins, 1 To NumVars)
    ReDim BinLabels(1 To NumBins, 1 To NumVars)
    ReDim FXordinate(1 To NumPoints, 1 To NumVars)
    ReDim FXabscissa(1 To NumPoints, 1 To NumVars)

    ReDim HistChtTitleRange(1 To NumVars)
    ReDim HistChtAbscissaRange(1 To NumVars)
    ReDim HistChtOrdinateRange(1 To NumVars)

    ReDim CumChtTitleRange(1 To NumVars)
    ReDim CumChtAbscissaRange(1 To NumVars)
    ReDim CumChtOrdinateRange(1 To NumVars)
    
    Fstep = Int(NumIters / NumPoints)
    
  ' Set gap between top of sheet and top of first graph of Subset
    SubsetRowStride = TotalPreviousNumVars * (ChtHeightCells + ChtVertGapCells) + ChtVertGapCells
    
  ' Set left column for both data tables
    HOffset = 2 * (ChtWidthCells + 1) + 10 + 2 * TotalPreviousNumVars
        
  ' Define worksheet ranges to contain histogram data
    Set HistSubsetRange = ThisWorkbook.Sheets(SheetName) _
        .Range(Cells(1, HOffset + 1), Cells(NumBins + 3, HOffset + 2 * NumVars))
    With HistSubsetRange
        Set HistSubsetTitleRange = .Range(Cells(1, 1), Cells(1, 2 * NumVars))
        For k = 1 To NumVars
            Set HistChtTitleRange(k) = .Range(Cells(2, 2 * k - 1), Cells(2, 2 * k))
            Set HistChtAbscissaRange(k) = .Range(Cells(3, 2 * k - 1), Cells(NumBins + 2, 2 * k - 1))
            Set HistChtOrdinateRange(k) = .Range(Cells(3, 2 * k), Cells(NumBins + 2, 2 * k))
        Next k
    End With
    
  ' Define worksheet ranges to contain cumulative chart data
    Set CumSubsetRange = ThisWorkbook.Sheets(SheetName) _
        .Range(Cells(NumBins + 5, HOffset + 1), Cells(NumBins + 4 + NumPoints + 3, HOffset + 2 * NumVars))
    With CumSubsetRange
        Set CumSubsetTitleRange = .Range(Cells(1, 1), Cells(1, 2 * NumVars))
        For k = 1 To NumVars
            Set CumChtTitleRange(k) = .Range(Cells(2, 2 * k - 1), Cells(2, 2 * k))
            Set CumChtAbscissaRange(k) = .Range(Cells(3, 2 * k - 1), Cells(NumPoints + 2, 2 * k - 1))
            Set CumChtOrdinateRange(k) = .Range(Cells(3, 2 * k), Cells(NumPoints + 2, 2 * k))
        Next k
    End With
       
  ' Translate chart dimensions into points
    With ThisWorkbook.Sheets(SheetName)
        ChtWidthPts = ChtWidthCells * (Cells(1, 2).left - Cells(1, 1).left)
        ChtHeightPts = ChtHeightCells * (Cells(2, 1).Top - Cells(1, 1).Top)
    End With
    ' Debug.Print "Chart width = " & ChtWidthPts & ", height = " & ChtHeightPts
    
  ' HISTOGRAMS
  
    HistSigFigs = 4
  
    For k = 1 To NumVars
        
    ' Calculate histogram data for the kth variable in Subset
    
      ' Calculate exponent for rounding
        With Subset
            SampleMin = .Min(k)
            SampleMax = .Max(k)
            SampleMean = .SampleMean(k)
            SampleSigma = .Variance(k)
        End With
        SampleSigma = Sqr(SampleSigma)
        
        Absomax = WorksheetFunction.Max(Abs(SampleMin), Abs(SampleMax))
        ExponentX = expon(Absomax)
        
      ' Calculate histogram bin dimensions
      
        LeftX = WorksheetFunction.Max(SampleMin, (SampleMean - 3 * SampleSigma))
        RightX = WorksheetFunction.Min(SampleMax, (SampleMean + 3 * SampleSigma))
        
        If LeftX < 0 Then
            LeftX = -WorksheetFunction.RoundUp(Abs(LeftX), (HistSigFigs - ExponentX - 1))
        Else
            LeftX = WorksheetFunction.RoundDown(LeftX, (HistSigFigs - ExponentX - 1))
        End If
       
        DeltaX = (RightX - LeftX) / NumBins
        DeltaX = WorksheetFunction.Round(DeltaX, (HistSigFigs - ExponentX - 1))
    
      ' Initialise histogram bins
        For i = 1 To NumBins
            BinContentCount(i, k) = 0
        Next i
    
      ' Populate histogram bins
        For i = 1 To NumIters
            x = Subset.OrderedSample(i, k)
            BinLeft = LeftX
            For j = 1 To NumBins
                BinRight = BinLeft + DeltaX
                If (x >= BinLeft) And (x < BinRight) Then
                    BinContentCount(j, k) = BinContentCount(j, k) + 1
                End If
                BinLeft = BinRight
            Next j
        Next i
    
      ' Generate bin label text
        BinLeft = LeftX
        For j = 1 To NumBins
            BinRight = BinLeft + DeltaX
            BinRight = WorksheetFunction.Round(BinRight, (HistSigFigs - 1 - ExponentX))
            If Not (Abs(DeltaX) < 10 ^ HistSigFigs And Abs(DeltaX) > 0.1) Then
                BinLabels(j, k) = Format(BinLeft, "Scientific") & " to " & Format(BinRight, "Scientific")
            Else
                BinLabels(j, k) = BinLeft & " to " & BinRight
            End If
            BinLeft = BinRight
        Next j

    ReDim Histogram(1 To NumVars)
                
   ' Populate histogram worksheet ranges
      ' Subset title
        With HistSubsetTitleRange
            .Merge
            .HorizontalAlignment = xlCenter
            .Value = "Histogram data, " & Subset.SubsetName
        End With
        
      ' Dataset title
        With HistChtTitleRange(k)
            .Merge
            .HorizontalAlignment = xlCenter
            .Value = Subset.VariableName(k)
        End With
        
      ' Abscissa data
        With HistChtAbscissaRange(k)
            For i = 1 To NumBins
                .Cells(i, 1) = BinLabels(i, k)
            Next i
            str1 = .Address(ReferenceStyle:=xlR1C1)
            SumFormula = "=SUM(" & str1 & ")"
            .Cells(NumBins + 1, 1).Formula = SumFormula
        End With
        
      ' Ordinate data
        With HistChtOrdinateRange(k)
            For i = 1 To NumBins
                .Cells(i, 1) = BinContentCount(i, k)
            Next i
            str1 = .Address(ReferenceStyle:=xlR1C1)
            SumFormula = "=SUM(" & str1 & ")"
            .Cells(NumBins + 1, 1).Formula = SumFormula
        End With
        
    Next k
    
  ' Create histograms
    For i = 1 To NumVars
        ChtTopLeftCellColumn = ChtHorizGapCells
        ChtTopLeftCellRow = (i - 1) * (ChtHeightCells + ChtVertGapCells) + SubsetRowStride + 1
        Set Histogram(i) = ThisWorkbook.Sheets(SheetName).ChartObjects.Add( _
            left:=Cells(ChtTopLeftCellRow, ChtTopLeftCellColumn).left, _
            Top:=Cells(ChtTopLeftCellRow, ChtTopLeftCellColumn).Top, _
            Width:=ChtWidthPts, _
            Height:=ChtHeightPts)
        With Histogram(i).chart
            .SetSourceData Source:=HistChtOrdinateRange(i)
            .SeriesCollection(1).XValues = HistChtAbscissaRange(i)
            .ChartType = 51
            .ChartGroups(1).GapWidth = 0
            .SetElement (msoElementLegendNone)
            .HasTitle = True
            .chartTitle.text = Subset.VariableName(i)
            .chartTitle.Font.FontStyle = "Regular"
            .chartTitle.Font.Size = 10
            .Axes(xlValue).TickLabelPosition = xlNone
            .Axes(xlValue).MinimumScale = 0
            .Axes(xlCategory).TickLabels.Orientation = xlUpward
            .ChartArea.Border.LineStyle = xlNone
        End With
    Next i
        
  ' CUMULATIVE DISTRIBUTION PLOTS

    For k = 1 To NumVars
    
  ' Generate cumulative distribution data for the kth variable in Subset
    
        FXabscissa(1, k) = Subset.CumulativeAbscissa(1, k)
        FXordinate(1, k) = Subset.CumulativeOrdinate(1, k)
        For i = 2 To NumPoints - 1
            FXabscissa(i, k) = Subset.CumulativeAbscissa((i - 1) * Fstep, k)
            FXordinate(i, k) = Subset.CumulativeOrdinate((i - 1) * Fstep, k)
        Next i
        FXabscissa(NumPoints, k) = Subset.CumulativeAbscissa(NumIters, k)
        FXordinate(NumPoints, k) = Subset.CumulativeOrdinate(NumIters, k)
        
   ' Populate Cumulative distribution worksheet ranges
      ' Subset title
        With CumSubsetTitleRange
            .Merge
            .HorizontalAlignment = xlCenter
            .Value = "Cumulative distribution data, " & Subset.SubsetName
        End With
        
      ' Dataset title
        With CumChtTitleRange(k)
            .Merge
            .HorizontalAlignment = xlCenter
            .Value = Subset.VariableName(k)
        End With
        
      ' Abscissa data
        With CumChtAbscissaRange(k)
            For i = 1 To NumPoints
                .Cells(i, 1) = FXabscissa(i, k)
            Next i
            str1 = .Address(ReferenceStyle:=xlR1C1)
            SumFormula = "=SUM(" & str1 & ")"
            .Cells(NumPoints + 1, 1).Formula = SumFormula
        End With
        
      ' Ordinate data
        With CumChtOrdinateRange(k)
            For i = 1 To NumPoints
                .Cells(i, 1) = FXordinate(i, k)
            Next i
            str1 = .Address(ReferenceStyle:=xlR1C1)
            SumFormula = "=SUM(" & str1 & ")"
            .Cells(NumPoints + 1, 1).Formula = SumFormula
        End With
        
    Next k
    
    ReDim CumulativePlot(1 To NumVars)
        
  ' Create cumulative distribution charts
    For i = 1 To NumVars
        ChtTopLeftCellColumn = (ChtWidthCells + 1) + 2
        ChtTopLeftCellRow = (i - 1) * (ChtHeightCells + ChtVertGapCells) + SubsetRowStride + 1
        Set CumulativePlot(i) = ThisWorkbook.Sheets(SheetName).ChartObjects.Add( _
            left:=Cells(ChtTopLeftCellRow, ChtTopLeftCellColumn).left, _
            Top:=Cells(ChtTopLeftCellRow, ChtTopLeftCellColumn).Top, _
            Width:=ChtWidthPts, _
            Height:=ChtHeightPts)
        With CumulativePlot(i).chart
            .SetSourceData Source:=CumChtOrdinateRange(i)
            .ChartType = xlXYScatter
            With .SeriesCollection(1)
                .XValues = CumChtAbscissaRange(i)
                .MarkerStyle = xlNone
                .Border.LineStyle = xlContinuous
            End With
            .ChartGroups(1).GapWidth = 0
            .SetElement (msoElementLegendNone)
            .HasTitle = True
            .chartTitle.text = Subset.VariableName(i)
            .chartTitle.Font.FontStyle = "Regular"
            .chartTitle.Font.Size = 10
            .Axes(xlValue).TickLabelPosition = xlTickLabelPositionNone
            .Axes(xlValue).MinimumScale = 0
            .Axes(xlValue).MaximumScale = 1
            .Axes(xlCategory).MinimumScale = Subset.Min(i)
            .Axes(xlCategory).MaximumScale = Subset.Max(i)
            .Axes(xlCategory).TickLabels.Orientation = xlUpward
            .Axes(xlCategory).TickLabels.NumberFormat = "General"
            .ChartArea.Border.LineStyle = xlNone
        End With
    Next i
    
  ' Write statistics into worksheet

    For k = 1 To NumVars
    
      ' Define worksheet ranges to contain statistics
        StatsTopLeftCellRow = (k - 1) * (ChtHeightCells + ChtVertGapCells) + SubsetRowStride + 1
        StatsTopLeftCellColumn = 2 * ChtWidthCells + 4
        Set StatSubsetRange = ThisWorkbook.Sheets(SheetName).Cells(StatsTopLeftCellRow, StatsTopLeftCellColumn)

        With StatSubsetRange
        
                With .Range(Cells(1, 1), Cells(1, 2))
                        .Merge
                        .HorizontalAlignment = xlCenter
                        .Value2 = Subset.VariableName(k) & " Statistics"
                End With
                        
                .Cells(2, 1).Value2 = "Min"
                .Cells(3, 1).Value2 = "10th percentile"
                .Cells(4, 1).Value2 = "Lower quartile"
                .Cells(5, 1).Value2 = "Median"
                .Cells(6, 1).Value2 = "Mean"
                .Cells(7, 1).Value2 = "Upper quartile"
                .Cells(8, 1).Value2 = "90th percentile"
                .Cells(9, 1).Value2 = "Max"
                .Cells(10, 1).Value2 = "Variance"
                .Cells(11, 1).Value2 = "St. dev."

                .Cells(2, 2).Value2 = Subset.Min(k)
                .Cells(3, 2).Value2 = Subset.Quantile(0.1, k)
                .Cells(4, 2).Value2 = Subset.Quantile(0.25, k)
                .Cells(5, 2).Value2 = Subset.Quantile(0.5, k)
                .Cells(6, 2).Value2 = Subset.SampleMean(k)
                .Cells(7, 2).Value2 = Subset.Quantile(0.75, k)
                .Cells(8, 2).Value2 = Subset.Quantile(0.9, k)
                .Cells(9, 2).Value2 = Subset.Max(k)
                .Cells(10, 2).Value2 = Subset.Variance(k)
                .Cells(11, 2).Value2 = Sqr(Subset.Variance(k))

                .Cells(1, 1).EntireColumn.AutoFit
        End With
    
    Next k
    
    PreviousSubsets = PreviousSubsets + 1
    PreviousSubsetNumVars = NumVars
    TotalPreviousNumVars = TotalPreviousNumVars + NumVars
    
    Application.Calculate

Next Subset

Application.Calculation = xlCalculationAutomatic
Application.ScreenUpdating = True

End Function
