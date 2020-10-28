Attribute VB_Name = "mc_maths_functions"
Option Explicit
Option Compare Text

' Excluding the function NumberOfArrayDimensions, Copyright 2015 Howard J Rudd
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
' _____________________________________________________________________________
'
' This module contains the following functions that perform mathematical
' calculations needed for Monte Carlo risk analysis:
'
'    1. arrayrank(vArray)
'    2. chol(A)
'    3. expon(x)
'    4. finvs(F, S)
'    5. ic(x, C)
'    6. matmult(A, B)
'    7. mattransmult(A, B
'    8. normalscores(n, m)
'    9. NumberOfArrayDimensions(Arr)
'   10. qs1dd(inLow, inHi, keyArray, otherArray)
'   11. qs1ds(inLow, inHi, keyArray)
'   12. qs2dd(inLow, inHi, keyArray, column, otherArray)
'   13. qs2ds(inLow, inHi, keyArray, column)
'   14. quicksort(keyArray, Optional column, Optional otherArray)
'   15. shuffle(vArray, Optional column)
'   16. unifun(n)
'
'______________________________________________________________________________

Public Function arrayrank(vArray() As Double) As Long()

' Usage: Y = arrayrank(vArray)
'
' Returns an array of longs representing the the rank orders of the elements
' of vArray. If vArray is two-dimensional, then it returns an array with
' the same number of rows and columns with the columns containing the ranks
' of the corresponding columns of "vArray".

Dim vDims As Long
Dim i As Long
Dim j As Long
Dim k As Long
Dim m As Long
Dim n As Long
Dim vRank() As Long
Dim tmpRank() As Long

' Check that dimensionality of vArray is either 1 or 2
vDims = NumberOfArrayDimensions(vArray)
If Not (vDims = 1 Or vDims = 2) Then
    Err.Raise Number:=vbObjectError + 7, _
              Source:="arrayrank", _
              Description:="Input argument not one or two dimensional"
    Debug.Print "Arrayrank input argument not one or two dimensional"
    Debug.Print vDims
    Exit Function
End If

' Check that array indices are numbered from 1
If vDims = 1 Then
    If Not (LBound(vArray) = 1) Then
        Err.Raise Number:=vbObjectError + 8, _
                  Source:="arrayrank", _
                  Description:="One dimensional array input argument not numbered from 1"
        Debug.Print "arrayrank input argument start index = " & LBound(vArray)
        Exit Function
    End If
    n = UBound(vArray)
ElseIf vDims = 2 Then
    If Not (LBound(vArray, 1) = 1 And LBound(vArray, 2) = 1) Then
        Err.Raise Number:=vbObjectError + 9, _
                  Source:="arrayrank", _
                  Description:="Two dimensional array input argument not numbered from 1"
        Debug.Print "column index starts from" & LBound(vArray, 1) & " and row index starts from" & LBound(vArray, 1)
    End If
    n = UBound(vArray, 1) - LBound(vArray, 1) + 1
    m = UBound(vArray, 2) - LBound(vArray, 2) + 1
End If

' Create array of consecutive longs from startIndex to endIndex
If vDims = 1 Then
    ReDim vRank(1 To n)
    ReDim tmpRank(1 To n)
ElseIf vDims = 2 Then
    ReDim vRank(1 To n, 1 To m)
    ReDim tmpRank(1 To n)
End If

' Pass this array to QuickSort along with the array to be ranked
If vDims = 1 Then
    For i = 1 To n
        tmpRank(i) = i
    Next i
        Call quicksort(keyArray:=vArray, otherArray:=tmpRank)
    For i = 1 To n
        vRank(tmpRank(i)) = i
    Next i
ElseIf vDims = 2 Then
    For j = 1 To m
        For i = 1 To n
            tmpRank(i) = i
        Next i
            Call quicksort(keyArray:=vArray, Column:=j, otherArray:=tmpRank)
        For i = 1 To n
            vRank(tmpRank(i), j) = i
        Next i
    Next j
End If

arrayrank = vRank

End Function

Public Function chol(A() As Double) As Double()

' Usage: Y = chol(A)
'
' Returns the upper triangular Cholesky root of A. A must by square, symmetric
' and positive definite.

Dim i As Long
Dim j As Long
Dim k As Long
Dim m As Long
Dim n As Long
Dim G() As Double

'Determine the number of rows, n, and number of columns, m, in A
n = UBound(A, 1) - LBound(A, 1) + 1
m = UBound(A, 2) - LBound(A, 2) + 1

'TESTS

' Check that A is indexed from 1
If Not (LBound(A, 1) = 1 And LBound(A, 2) = 1) Then
    Err.Raise Number:=vbObjectError + 10, _
        Source:="chol", _
        Description:="Matrix not indexed from 1"
    Debug.Print "column index starts from" & LBound(A, 1) & " and row index starts from" & LBound(A, 1)
End If

'Check that A is square
If Not (n = m) Then
    Debug.Print "Attempted to perform Cholesky factorisation on a matrix" _
                & "that is not square"
    Err.Raise Number:=vbObjectError + 11, _
              Source:="chol", _
              Description:="Matrix not square"
    Exit Function
End If

'Check that A is at least 2 x 2
If Not WorksheetFunction.Min(n, m) >= 2 Then
    Debug.Print "Attempted to perform Cholesky factorisation on a 1 x 1 matrix"
    Err.Raise Number:=vbObjectError + 12, _
              Source:="chol", _
              Description:="Input matrix only has one element"
    Exit Function
End If

'Check that A is symmetric
For i = 1 To n
    For j = 1 To m
        If Not A(i, j) = A(j, i) Then
               Debug.Print "Attempted to perform Cholesky factorisation on a matrix" _
                         & "that is not symmetric"
                Err.Raise Number:=vbObjectError + 13, _
                          Source:="chol", _
                          Description:="Matrix not symmetric"
            Exit Function
        End If
    Next j
Next i

' Check that the first diagonal element of A is >= 0
If A(1, 1) <= 0 Then
    Debug.Print "Attempted to perform Cholesky factorisation on a matrix" & _
                "that is not positive definite"
    Err.Raise Number:=vbObjectError + 14, _
                Source:="chol", _
                Description:="Matrix not positive definite"
    Exit Function
End If

' END OF TESTS (almost). Actual maths starts here!

ReDim G(1 To n, 1 To m)

' Calculate 1st element
G(1, 1) = Sqr(A(1, 1))

' Calculate remainder of 1st row
For j = 2 To m
    G(1, j) = A(1, j) / G(1, 1)
Next j

' Calculate remaining rows
For i = 2 To n
' Calculate diagonal element of row i
    G(i, i) = A(i, i)
    For k = 1 To i - 1
        G(i, i) = G(i, i) - G(k, i) * G(k, i)
    Next k
' Check that g(i,i) is > 0
    If G(i, i) <= 0 Then
        Debug.Print "Attempted to perform Cholesky factorisation on a matrix" & _
                    "that is not positive definite"
        Err.Raise Number:=vbObjectError + 15, _
                  Source:="chol", _
                  Description:="Matrix not positive definite"
        Exit Function
    End If
    G(i, i) = Sqr(G(i, i))
' Calculate remaining elements of row i
    For j = i + 1 To m
        G(i, j) = A(i, j)
        For k = 1 To i - 1
            G(i, j) = G(i, j) - G(k, i) * G(k, j)
        Next k
        G(i, j) = G(i, j) / G(i, i)
    Next j
Next i

' Calculate lower triangular half of G
For i = 2 To n
    For j = 1 To i - 1
        G(i, j) = 0
    Next j
Next i

chol = G

End Function

Public Function expon(x As Double) As Integer

' Usage: Y = expon(x)
'
' Returns the exponent to the base 10 of x. That is the value 'b' such that
' x = a * 10^b, where 1<= a < 10.

Dim y As Double

y = Log(x) / Log(10)
expon = Int(y)

End Function

Public Function finvs(F, S) As Double()

' Usage: Y = finvs(F, S)
'
' Returns the product of F^-1 and S for F and S both upper triangular. Actually
' solves FZ = S, i.e. finds Z such that FZ = S.

Dim i As Long
Dim j As Long
Dim k As Long
Dim m As Long
Dim n As Long

Dim nRowsF As Long
Dim nColsF As Long
Dim nRowsS As Long
Dim nColsS As Long

Dim z() As Double
Dim w As Double

nRowsF = UBound(F, 1) - LBound(F, 1) + 1
nColsF = UBound(F, 2) - LBound(F, 2) + 1
nRowsS = UBound(S, 1) - LBound(S, 1) + 1
nColsS = UBound(S, 2) - LBound(S, 2) + 1

' TESTS

' Check that F is indexed from 1
If Not (LBound(F, 1) = 1 And LBound(F, 2) = 1) Then
    Err.Raise Number:=vbObjectError + 16, _
        Source:="finvs", _
        Description:="Matrix F not indexed from 1"
    Debug.Print "column index starts from" & LBound(F, 1) & " and row index starts from" & LBound(F, 1)
End If

' Check that S is indexed from 1
If Not (LBound(S, 1) = 1 And LBound(S, 2) = 1) Then
    Err.Raise Number:=vbObjectError + 17, _
        Source:="finvs", _
        Description:="Matrix S not indexed from 1"
    Debug.Print "column index starts from" & LBound(S, 1) & " and row index starts from" & LBound(F, 1)
End If

' Test whether F is square
If Not nRowsF = nColsF Then
    Debug.Print "Matrix F is not square"
    Err.Raise Number:=vbObjectError + 18, _
              Source:="finvs", _
              Description:="Matrix F is not square"
    Exit Function
End If

' Test whether S is square
If Not nRowsS = nColsS Then
    Debug.Print "Matrix S is not square"
    Err.Raise Number:=vbObjectError + 19, _
              Source:="finvs", _
              Description:="Matrix S is not square"
    Exit Function
End If

' Test whether F and S have same dimensions
If Not nRowsF = nRowsS And nColsF = nColsS Then
    Debug.Print "Matrices F and S have different dimensions"
    Err.Raise Number:=vbObjectError + 20, _
              Source:="finvs", _
              Description:="Matrices F and S have different dimensions"
    Exit Function
End If

' Test whether F is upper triangular
For i = 1 To nRowsF
    For j = 1 To i - 1
        If Not (F(i, j) = 0 And (Not F(j, i) = 0)) Then
            Debug.Print "Matrix F is not upper triangular"
            Err.Raise Number:=vbObjectError + 21, _
                      Source:="finvs", _
                      Description:="Matrix F not upper triangular"
            Exit Function
        End If
    Next j
Next i

' Test whether S is upper triangular
For i = 2 To nRowsS
    For j = 1 To i - 1
        If S(i, j) > 10 ^ (-16) Then
            Debug.Print "Matrix S is not upper triangular"
            Err.Raise Number:=vbObjectError + 22, _
                      Source:="finvs", _
                      Description:="Matrix S not upper triangular"
            Exit Function
        End If
    Next j
Next i

' Test whether F has all non-zero diagonal elements
For i = 1 To nRowsF
        If F(i, i) = 0 Then
            Debug.Print "Matrix F has at least one zero diagonal element and so is not invertible"
            Err.Raise Number:=vbObjectError + 23, _
                      Source:="finvs", _
                      Description:="Matrix F has at least one zero diagonal element and so is not invertible"
            Exit Function
        End If
Next i

' END OF TESTS. Actual maths starts here!

n = nRowsF

ReDim z(1 To n, 1 To n)

' Construct the nth row of Z
For j = 1 To n - 1
    z(n, j) = 0
Next j
    z(n, n) = S(n, n) / F(n, n)

' Construct the rows of Z above the nth
For i = n - 1 To 1 Step -1
    For j = 1 To n
        w = 0
        For k = i + 1 To n
            w = w + F(i, k) * z(k, j)
        Next k
        z(i, j) = (S(i, j) - w) / F(i, i)
    Next j
Next i

finvs = z

End Function

Public Function ic(Xascending() As Double, C() As Double) As Double()

' Usage: y = ic(Xascending, C)
'
' Performs the Iman-Conover method on Xind and returns a matrix Xcorr with the same
' dimensions as Xind.
'
' Xascending is an n-instance sample from an m-element random row-vector, with
' each column sorted in ascending order.
'
' If the columns of Xascending are in ascending order then the correlation
' matrix of Xcorr will be approximately equal to C. This function does not test
' Xascending to check that its columns are in ascending order. To do so would
' incur too large a computational burden.
'
' C must be square, symmetric and positive definite.
'
' The number of rows and columns of C must equal the number of columns Xascending.

Dim nRowsC As Long
Dim nColsC As Long
Dim nRowsX As Long
Dim nColsX As Long

nRowsC = UBound(C, 1) - LBound(C, 1) + 1
nColsC = UBound(C, 2) - LBound(C, 2) + 1
nRowsX = UBound(Xascending, 1) - LBound(Xascending, 1) + 1
nColsX = UBound(Xascending, 2) - LBound(Xascending, 2) + 1

Dim i As Long
Dim j As Long
Dim k As Long

Dim EX() As Double
ReDim EX(1 To nColsX, 1 To nColsX)
Dim FX() As Double
ReDim FX(1 To nColsX, 1 To nColsX)
Dim ZX() As Double
ReDim ZX(1 To nColsX, 1 To nColsX)
Dim S() As Double
ReDim S(1 To nColsX, 1 To nColsX)

Dim MX() As Double
ReDim MX(1 To nRowsX, 1 To nColsX)
Dim TX() As Double
ReDim TX(1 To nRowsX, 1 To nColsX)
Dim YX() As Double
ReDim YX(1 To nRowsX, 1 To nColsX)
Dim ranks() As Long
ReDim ranks(1 To nRowsX, 1 To nColsX)

' TESTS!

' Test if C is square
If Not nRowsC = nColsC Then
    MsgBox Title:="Iman-Conover Function", _
           prompt:="Correlation matrix is not square"
End If
  
' Test if C is symmetric
For i = 1 To nRowsC
    For j = i To nColsC
        If Abs(C(i, j) - C(j, i)) >= 10 ^ (-16) Then
            MsgBox Title:="Iman-Conover Function", _
                prompt:="Correlation matrix is not symmetric"
            Exit Function
        End If
    Next j
Next i

' Test if the number of rows of C is greater than the number of columns of X
If nRowsC > nColsX Then
    MsgBox Title:="Iman-Conover Function", _
           prompt:="Correlation matrix too large"
End If

' Test if the number of rows of C is less than the number of columns of X
If nRowsC < nColsX Then
    MsgBox Title:="Iman-Conover Function", _
           prompt:="Correlation matrix too small"
End If

' END OF TESTS: Actual maths starts here!

' Calculate the upper triangular Cholesky root of C
S = chol(C)

' Calculate the matrix, MX, of "normal scores"
MX = normalscores(nRowsX, nColsX)

' Calculate the matrix EX = MX' * MX
EX = mattransmult(MX, MX)

' Calculate Fx, the Cholesky root of Ex.
FX = chol(EX)

' Calculate ZX = FX^{-1) * S
ZX = finvs(FX, S)

' Calculate TX, the reordered matrix of "scores".
TX = matmult(MX, ZX)

' Calculate the rank orders of TX.
ranks = arrayrank(TX)

' Reorder columns of X to match T.
For j = 1 To nColsX
    For k = 1 To nRowsX
        YX(k, j) = Xascending(ranks(k, j), j)
    Next k
Next j

ic = YX

End Function

Public Function matmult(A, B) As Double()

'Usage: C = matmult(A, B)
'
' Returns the product of A and B. Start indices of A and B can be arbitrary but
' start indices of the product C are both 1.

Dim startIndexRowsA As Long
Dim endIndexRowsA As Long
Dim startIndexColsA As Long
Dim endIndexColsA As Long
Dim startIndexRowsB As Long
Dim endIndexRowsB As Long
Dim startIndexColsB As Long
Dim endIndexColsB As Long
Dim nRowsA As Long
Dim nColsA As Long
Dim nRowsB As Long
Dim nColsB As Long
Dim nRowsC As Long
Dim nColsC As Long
Dim i As Long
Dim j As Long
Dim k As Long

startIndexRowsA = LBound(A, 1)
endIndexRowsA = UBound(A, 1)
startIndexColsA = LBound(A, 2)
endIndexColsA = UBound(A, 2)
startIndexRowsB = LBound(B, 1)
endIndexRowsB = UBound(B, 1)
startIndexColsB = LBound(B, 2)
endIndexColsB = UBound(B, 2)

nRowsA = endIndexRowsA - startIndexRowsA + 1
nColsA = endIndexColsA - startIndexColsA + 1
nRowsB = endIndexRowsB - startIndexRowsB + 1
nColsB = endIndexColsB - startIndexColsB + 1

' Test that the two matrices are conformable
If Not nColsA = nRowsB Then
    Debug.Print "Attempted to multiply non conformable matrices"
    Err.Raise Number:=vbObjectError + 24, _
              Source:="matmult", _
              Description:="Matrices not conformable"
    Exit Function
End If
          
nRowsC = nRowsA
nColsC = nColsB

Dim C() As Double
ReDim C(1 To nRowsC, 1 To nColsC)

For i = 1 To nRowsC
    For j = 1 To nColsC
        C(i, j) = 0
        For k = 1 To nColsA
            C(i, j) = C(i, j) + A(i + startIndexRowsA - 1, k + startIndexColsA - 1) * _
                                B(k + startIndexRowsB - 1, j + startIndexColsB - 1)
        Next k
    Next j
Next i

matmult = C

End Function

Public Function mattransmult(A, B) As Double()

'Usage: C = mattransmult(A, B)
'
' Returns the product of A-transpose and B. Start indices of A and B
' can be arbitrary but start indices of the product C are both 1.

Dim startIndexRowsA As Long
Dim endIndexRowsA As Long
Dim startIndexColsA As Long
Dim endIndexColsA As Long
Dim startIndexRowsB As Long
Dim endIndexRowsB As Long
Dim startIndexColsB As Long
Dim endIndexColsB As Long
Dim nRowsA As Long
Dim nColsA As Long
Dim nRowsB As Long
Dim nColsB As Long
Dim nRowsC As Long
Dim nColsC As Long
Dim i As Long
Dim j As Long
Dim k As Long

startIndexRowsA = LBound(A, 1)
endIndexRowsA = UBound(A, 1)
startIndexColsA = LBound(A, 2)
endIndexColsA = UBound(A, 2)
startIndexRowsB = LBound(B, 1)
endIndexRowsB = UBound(B, 1)
startIndexColsB = LBound(B, 2)
endIndexColsB = UBound(B, 2)

nRowsA = endIndexRowsA - startIndexRowsA + 1
nColsA = endIndexColsA - startIndexColsA + 1
nRowsB = endIndexRowsB - startIndexRowsB + 1
nColsB = endIndexColsB - startIndexColsB + 1

' Test that the two matrices are conformable
If Not nRowsA = nRowsB Then
    Debug.Print "Attempted to multiply non conformable matrices"
    Err.Raise Number:=vbObjectError + 25, _
              Source:="matmult", _
              Description:="Matrices not conformable"
    Exit Function
End If
          
nRowsC = nColsA
nColsC = nColsB

Dim C() As Double
ReDim C(1 To nRowsC, 1 To nColsC)

For i = 1 To nColsA
    For j = 1 To nColsB
        C(i, j) = 0
        For k = 1 To nRowsA
            C(i, j) = C(i, j) + A(k + startIndexRowsA - 1, i + startIndexColsA - 1) * _
                                B(k + startIndexRowsB - 1, j + startIndexColsB - 1)
        Next k
    Next j
Next i

mattransmult = C

End Function

Public Function normalscores(n, m)

Dim Omega() As Double

ReDim Omega(1 To n, 1 To m)

Dim i As Long
Dim j As Long
Dim k As Long
Dim x As Double
Dim NormalisationFactor As Double

x = 0
For i = 1 To n \ 2
    Omega(i, 1) = WorksheetFunction.NormInv((i / (n + 1)), 0, 1)
    x = x + Omega(i, 1) ^ 2
Next i

NormalisationFactor = Sqr(2 * x / n)

For i = 1 To n \ 2
    Omega(i, 1) = Omega(i, 1) / NormalisationFactor
Next i

k = Int(n / 2) + 1

If Not 2 * Int(n / 2) = n Then
    Omega(k, 1) = 0
    For i = k + 1 To n
        Omega(i, 1) = -Omega(n - i + 1, 1)
    Next i
Else
    For i = k To n
        Omega(i, 1) = -Omega(n - i + 1, 1)
    Next i
End If

For j = 2 To m
    For i = 1 To n
        Omega(i, j) = Omega(i, 1)
    Next i
Next j

For i = 1 To m
    Call shuffle(Omega, i)
Next i

normalscores = Omega

ReDim Omega(0)

End Function

Public Function NumberOfArrayDimensions(Arr As Variant) As Long
' This function is from http://www.cpearson.com/Excel/VBAArrays.htm

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' NumberOfArrayDimensions
' This function returns the number of dimensions of an array. An unallocated dynamic array
' has 0 dimensions.
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Dim Ndx As Long
Dim Res As Long
On Error Resume Next
' Loop, increasing the dimension index Ndx, until an error occurs.
' An error will occur when Ndx exceeds the number of dimension
' in the array. Return Ndx - 1.
Do
    Ndx = Ndx + 1
    Res = UBound(Arr, Ndx)
Loop Until Err.Number <> 0

NumberOfArrayDimensions = Ndx - 1

End Function

Private Function qs1ds(inLow, inHi, keyArray)

' Usage: quicksort(inLow, inHi, keyArray)
'
' "qs1ds" = quick sort one dimensional single array
'
' Sorts keyArray in place between indices inLow and inHi, keyArray must be of
' type Double
'
' This function is based on code suggested in:
' http://stackoverflow.com/questions/152319/vba-array-sort-function

Dim tmpLow As Long
Dim tmpHi As Long
Dim pivot As Double
Dim keyTmpSwap As Double

tmpLow = inLow
tmpHi = inHi
pivot = keyArray((inLow + inHi) \ 2)

Do While (tmpLow <= tmpHi)
    Do While keyArray(tmpLow) < pivot And tmpLow < inHi
        tmpLow = tmpLow + 1
    Loop
    Do While keyArray(tmpHi) > pivot And tmpHi > inLow
        tmpHi = tmpHi - 1
    Loop
    If (tmpLow <= tmpHi) Then
        keyTmpSwap = keyArray(tmpLow)
        keyArray(tmpLow) = keyArray(tmpHi)
        keyArray(tmpHi) = keyTmpSwap
        tmpLow = tmpLow + 1
        tmpHi = tmpHi - 1
    End If
Loop

If (inLow < tmpHi) Then qs1ds inLow, tmpHi, keyArray
If (tmpLow < inHi) Then qs1ds tmpLow, inHi, keyArray

End Function

Private Function qs1dd(inLow, inHi, keyArray, otherArray)

' Usage: qs1dd(inLow, inHi, keyArray, otherArray)
'
' "qs1dd" = quick sort one dimensional double array
'
' Sorts keyArray in place between indices inLow and inHi.
'
' An array, "otherArray" is sorted in parallel, also in-place. "otherArray" must
' be one dimensional and have the same start and end indices as the first dimen-
' sion of "keyArray".
'
' "keyArray" must be of type Double, "otherArray" must be of type long.
'
' This function is based on code suggested in:
' http://stackoverflow.com/questions/152319/vba-array-sort-function

Dim pivot As Double
Dim tmpLow As Long
Dim tmpHi As Long
Dim keyTmpSwap As Double
Dim otherTmpSwap As Long
Dim keyDims As Long
Dim otherDims As Long

tmpLow = inLow
tmpHi = inHi
pivot = keyArray((inLow + inHi) \ 2)

Do While (tmpLow <= tmpHi)

    Do While keyArray(tmpLow) < pivot And tmpLow < inHi
        tmpLow = tmpLow + 1
    Loop
    
    Do While keyArray(tmpHi) > pivot And tmpHi > inLow
        tmpHi = tmpHi - 1
    Loop
    
    If (tmpLow <= tmpHi) Then
    
        keyTmpSwap = keyArray(tmpLow)
        otherTmpSwap = otherArray(tmpLow)
        
        keyArray(tmpLow) = keyArray(tmpHi)
        otherArray(tmpLow) = otherArray(tmpHi)
        
        keyArray(tmpHi) = keyTmpSwap
        otherArray(tmpHi) = otherTmpSwap
        
        tmpLow = tmpLow + 1
        tmpHi = tmpHi - 1
        
    End If
    
Loop

If (inLow < tmpHi) Then qs1dd inLow, tmpHi, keyArray, otherArray
If (tmpLow < inHi) Then qs1dd tmpLow, inHi, keyArray, otherArray

End Function

Private Function qs2ds(inLow As Long, inHi As Long, keyArray() As Double, Column As Long)

' Usage: qs2ds(inLow, inHi, keyArray, column)
'
' "qs2ds" = quick sort two dimensional single array
'
' Sorts a column of "keyArray", in place ' between indices "inLow" and "inHi".
' "keyArray" must be is two-dimensional (i.e. a matrix). Only the column
' specified by the optional argument "column" will be sorted, the other columns
' are left untouched.
'
' "keyArray" must be of type Double, column and "column" must be of type
' long
'
' This function is based on code suggested in:
' http://stackoverflow.com/questions/152319/vba-array-sort-function

Dim pivot As Double
Dim tmpLow As Long
Dim tmpHi As Long
Dim keyTmpSwap As Double
Dim keyDims As Long

tmpLow = inLow
tmpHi = inHi
pivot = keyArray((inLow + inHi) \ 2, Column)

Do While (tmpLow <= tmpHi)
    Do While keyArray(tmpLow, Column) < pivot And tmpLow < inHi
        tmpLow = tmpLow + 1
    Loop
    Do While keyArray(tmpHi, Column) > pivot And tmpHi > inLow
        tmpHi = tmpHi - 1
    Loop
    If (tmpLow <= tmpHi) Then
        keyTmpSwap = keyArray(tmpLow, Column)
        keyArray(tmpLow, Column) = keyArray(tmpHi, Column)
        keyArray(tmpHi, Column) = keyTmpSwap
        tmpLow = tmpLow + 1
        tmpHi = tmpHi - 1
    End If
Loop

If (inLow < tmpHi) Then qs2ds inLow, tmpHi, keyArray, Column
If (tmpLow < inHi) Then qs2ds tmpLow, inHi, keyArray, Column

End Function

Private Function qs2dd(inLow, inHi, keyArray, Column, otherArray)

' Usage: qs2dd(inLow, inHi, keyArray, column, otherArray)
'
' "qs1dd" = quick sort two dimensional double array
'
' Sorts "keyArray" and "otherArray" in place between indices inLow and inHi.
'
' An array, "otherArray" is sorted in parallel, also in-place. "otherArray" must
' be one dimensional and have the same start and end indices as the first dimen-
' sion of "keyArray".
'
' "keyArray" must be of type Double, "column" and "otherArray" must be of type
' long.
'
' This function is based on code suggested in:
' http://stackoverflow.com/questions/152319/vba-array-sort-function

Dim pivot As Double
Dim tmpLow As Long
Dim tmpHi As Long
Dim keyTmpSwap As Double
Dim otherTmpSwap As Long
Dim keyDims As Long
Dim otherDims As Long

tmpLow = inLow
tmpHi = inHi
pivot = keyArray((inLow + inHi) \ 2, Column)

Do While (tmpLow <= tmpHi)

    Do While keyArray(tmpLow, Column) < pivot And tmpLow < inHi
        tmpLow = tmpLow + 1
    Loop
    
    Do While keyArray(tmpHi, Column) > pivot And tmpHi > inLow
        tmpHi = tmpHi - 1
    Loop
    
    If (tmpLow <= tmpHi) Then
    
        keyTmpSwap = keyArray(tmpLow, Column)
        otherTmpSwap = otherArray(tmpLow)
        
        keyArray(tmpLow, Column) = keyArray(tmpHi, Column)
        otherArray(tmpLow) = otherArray(tmpHi)
        
        keyArray(tmpHi, Column) = keyTmpSwap
        otherArray(tmpHi) = otherTmpSwap
        
        tmpLow = tmpLow + 1
        tmpHi = tmpHi - 1
        
    End If
    
Loop

If (inLow < tmpHi) Then qs2dd inLow, tmpHi, keyArray, Column, otherArray
If (tmpLow < inHi) Then qs2dd tmpLow, inHi, keyArray, Column, otherArray

End Function

Public Function quicksort(keyArray() As Double, Optional Column As Long, Optional otherArray)

' Usage: quicksort(keyArray, column, otherArray)
'
' Sorts keyArray in place. If keyArray is two-dimensional (i.e. a matrix) then
' only the column specified by the optional argument "column" will be sorted.
'
' An optional "otherArray" can be sorted in parallel, also in-place. If
' "otherArray" is used it must be one-dimensional and have the same start and
' end indices as the columns of "keyArray".
'
' "keyArray" must be of type Double, "column" and otherArray must be of type
' long

Dim keyDims As Long
Dim otherDims As Long
Dim inLow As Long
Dim inHi As Long
Dim i As Long

' TESTS

' Check that the dimensionality of "keyArray" is either 1 or 2
keyDims = NumberOfArrayDimensions(keyArray)
If Not (keyDims = 1 Or keyDims = 2) Then
    Debug.Print "input argument not one or two dimensional"
    Exit Function
End If

If Not IsMissing(otherArray) Then
' Check that "otherArray" is one-dimensional
    otherDims = NumberOfArrayDimensions(otherArray)
    If Not otherDims = 1 Then
        Debug.Print "'otherArray' not one-dimensional"
        Exit Function
    End If
    If keyDims = 1 Then
' Check that "keyArray" and "otherArray" are conformable
        If Not ( _
                    UBound(keyArray) = UBound(otherArray) And _
                    LBound(keyArray) = LBound(otherArray) _
                ) Then
                Debug.Print "'keyArray' and 'otherArray' not conformable"
                Exit Function
        End If
    ElseIf keyDims = 2 Then
' Check that the argument "column" has been supplied
        If IsMissing(Column) Then
            Debug.Print "'column' argument not passed"
            Exit Function
        End If
' Check that "otherArray" is conformable to columns of "keyArray"
        If Not ( _
                UBound(keyArray, 1) = UBound(otherArray) And _
                LBound(keyArray, 1) = LBound(otherArray) _
            ) Then
            Debug.Print "'keyArray' and 'otherArray' not conformable"
            Exit Function
        End If
    End If
End If

' Check that the argument "column" points to one of the columns of "keyArray"
If Not (LBound(keyArray, 2) <= Column And Column <= UBound(keyArray, 2)) Then
    ' ERROR: Argument "column" does not point to one of the columns of "keyArray"
    Exit Function
End If

' END OF TESTS

' Calculate "inHi" and "inLow"

If keyDims = 1 Then
    inLow = LBound(keyArray)
    inHi = UBound(keyArray)
ElseIf keyDims = 2 Then
    inLow = LBound(keyArray, 1)
    inHi = UBound(keyArray, 1)
End If

' Call appropriate sort function

If keyDims = 1 And IsMissing(otherArray) Then
    Call qs1ds(inLow, inHi, keyArray)
        
ElseIf keyDims = 1 And Not IsMissing(otherArray) Then
    Call qs1dd(inLow, inHi, keyArray, otherArray)

ElseIf keyDims = 2 And IsMissing(otherArray) Then
    Call qs2ds(inLow, inHi, keyArray, Column)

ElseIf keyDims = 2 And Not IsMissing(otherArray) Then
    Call qs2dd(inLow, inHi, keyArray, Column, otherArray)

End If

End Function

Public Function shuffle(vArray, Optional Column)

' Usage: shuffle(vArray, column)
'
' shuffles vArray in place randomly. If vArray is 2-dimensional, then it shuffles
' the column specified by the optional variable "column"

Dim j As Long
Dim k As Long
Dim startIndex As Long
Dim endIndex As Long
Dim vDims As Long

Dim temp As Double

' Check that dimensionality of "vArray" is either 1 or 2
vDims = NumberOfArrayDimensions(vArray)
If Not (vDims = 1 Or vDims = 2) Then
    Debug.Print "input argument not one or two dimensional"
    Debug.Print vDims
    Exit Function
End If

If vDims = 1 Then
    startIndex = LBound(vArray)
    endIndex = UBound(vArray)
    j = endIndex
    Do While j > startIndex
        k = CLng(startIndex + Rnd() * (j - startIndex))
        temp = vArray(j)
        vArray(j) = vArray(k)
        vArray(k) = temp
        j = j - 1
    Loop
ElseIf vDims = 2 Then
    If IsMissing(Column) Then
        'ERROR: Argument 'column' not supplied
        Exit Function
    End If
' Check that the argument "column" points to one of the columns of "vArray"
    If Not (LBound(vArray, 2) <= Column And Column <= UBound(vArray, 2)) Then
        ' ERROR: Argument "column" does not point to one of the columns of "vArray"
        Exit Function
    End If
    startIndex = LBound(vArray, 1)
    endIndex = UBound(vArray, 1)
    j = endIndex
    Do While j > startIndex
        k = CLng(startIndex + Rnd() * (j - startIndex))
        temp = vArray(j, Column)
        vArray(j, Column) = vArray(k, Column)
        vArray(k, Column) = temp
        j = j - 1
    Loop
End If

End Function

Public Function unifun(ByVal n As Long) As Double()

' Usage: y = unifun(n)
'
' Returns an array of n random numbers in ascending order, the ith member of
' which is a uniformly distributed on the range (i - 1)/n <= x < i/n, except
' for the 1st member, which is uniformly distributed on the range
' 0 < x < 1/n.

Dim U As Double
Dim y() As Double
ReDim y(1 To n)
Dim i As Long

' First member of the sequence
Do
    U = Rnd()
Loop Until U <> 0
y(1) = U / n
    
' Remaining members of the sequence
For i = 2 To n
    y(i) = (Rnd() + i - 1) / n
Next i
    
unifun = y

End Function
