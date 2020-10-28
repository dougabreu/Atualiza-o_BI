Attribute VB_Name = "mc_quantile_functions"
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


' This module contains functions that return the quantiles of the random
' variables that are needed in the simulations. These are in a separate module
' to make it easier for the user to add new ones as required. The following
' functions are included:
'
'   01. TriangularInv(y, left, middle, right)
'   02. UniformInv(y, left, right)
'
'______________________________________________________________________________


Public Function TriangularInv(y, left, middle, right) As Double

' Returns the quantile function of a random variable distributed according to
' the triangular distribution with corners at x = a, x = b and x = c.

Dim tmp As Variant
Dim cond12 As Boolean
Dim cond23 As Boolean
Dim test1 As Boolean
Dim test2 As Boolean
Dim test3 As Boolean
Dim i As Integer

cond12 = left > middle
cond23 = middle > right

If cond12 Then
    MsgBox Title:="TriangularInv", _
           prompt:="Left corner to the right of top corner, " & vbCr & _
                   "corners reversed and calculation continued."
ElseIf cond23 Then
    MsgBox Title:="TriangularInv", _
           prompt:="Top corner to the right of right corner, " & vbCr & _
                   "corners reversed and calculation continued."
End If

' The following loop sorts a, b and c into ascending order. This is done because
' it is assumed that the user intended to enter the same numbers in ascending
' order but made a mistake. The error is flagged via a message box, but the
' calculation continues. It is, however, possible that the user made a different
' mistake, such as entering one or more of the values incorrectly.

Do While cond12 Or cond23
    If cond12 Then
        tmp = left
        left = middle
        middle = tmp
    ElseIf cond23 Then
        tmp = middle
        middle = right
        right = tmp
    End If
    cond12 = left > middle
    cond23 = middle > right
Loop

' The variable isArrayy stores True if y is an array and False if not. Avoids
' the need to evaluate IsArray(y) multiple times.

test1 = left = middle
test2 = middle = right
test3 = left = right

If test1 And (Not test2) Then
' Situation 1: The triangle is right angled with the right angle on the left.
    TriangularInv = right - (right - left) * Sqr(1 - y)

ElseIf test2 And (Not test1) Then
' Situation 2: b and c are equal. The triangle is right angled with the right
' angle on the right.
    TriangularInv = left + (middle - left) * Sqr(y)

ElseIf test1 And test2 And test3 Then
' Situation 3: the x-coordinates of all the triangle's corners coincide. This is
' an error situation. The user has entered them incorrectly. Raise an error
' message, but still generate output. The output will be an array of constants
' equal to a = b = c. No randomness involved.
    TriangularInv = left

ElseIf (Not test1) And (Not test2) And (Not test3) Then
' Situation 4: the happy case.
    If y <= (middle - left) / (right - left) Then
        TriangularInv = left + Sqr(y * (right - left) * (middle - left))
    Else
        TriangularInv = right - Sqr((1 - y) * (right - left) * (right - middle))
    End If
Else
' Can't imagine what would be left if none of the above were true, just throw an
' exception if the programme ends up here.
        MsgBox Title:="TriangularInv", _
               prompt:="Er, something's wrong," & vbCr & _
                       "suggest check code."
End If

End Function

Public Function UniformInv(y, left, right) As Double

' Returns the quantile function of a random variable uniformly distributed on
' the range (a, b).
'
' Has to be decalred as Variant otherwise the argument y must either be always
' scalar or always an array, not sometimes one or sometimes the other. However,
' the function actually returns a double.

Dim tmp As Variant

' The following block tests to see whether b > a. If not, it genrates a warning
' then reverses the order of a and b and continues with the calculation.

If left > right Then
    MsgBox Title:="UniformInv", _
           prompt:="Lower end of input range greater than upper end, " & vbCr & _
                   "parameters reversed and calculation continued"
    tmp = left
    left = right
    right = tmp
End If

' The following block tests whether a = b and if so generates a warning

If left = right Then
    MsgBox Title:="UniformInv", _
           prompt:="Lower and upper ends of input range coincide." & vbCr & _
                   "Calculation continued but will return a constant"
End If

UniformInv = (right - left) * y + left

End Function


