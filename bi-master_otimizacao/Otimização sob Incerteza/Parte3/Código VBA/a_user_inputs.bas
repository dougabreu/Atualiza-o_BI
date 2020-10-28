Attribute VB_Name = "a_user_inputs"
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

Public Sub Go()

Dim start As Double, elatim As Double, elatim1 As Double, elatim2 As Double
start = Timer

' GENERAL DECLARATIONS

Dim InputVariables As Collection, OutputVariables As Collection
Set InputVariables = New Collection
Set OutputVariables = New Collection

Dim i As Long, j As Long, k As Long, m As Long, n As Long, U() As Double
n = 1000
ReDim U(1 To n)

' INPUT VARIABLES, SUBSET A

Dim InVarA As ClsRandomVariableSubset
Set InVarA = New ClsRandomVariableSubset
InputVariables.Add InVarA

InVarA.SubsetName = "Subset A (independent)"
InVarA.NumVars = 5
InVarA.NumIters = n
InVarA.Size

'1st input variable in A
k = 1
InVarA.VariableName(k) = "Input 1 - EMAIL"
InVarA.VariableSheet(k) = "Modelo" 'Alterar com o nome da aba
InVarA.VariableRange(k) = "C11"     'Alterar com a celula de entrada
U = unifun(n)
For i = 1 To n
    InVarA.OrderedSample(i, k) = WorksheetFunction.GammaInv(U(i), 2.032, 4.117)
Next i

'2nd input variable in A
k = 2
InVarA.VariableName(k) = "Input 2 - INTERNET"
InVarA.VariableSheet(k) = "Modelo" 'Alterar com o nome da aba
InVarA.VariableRange(k) = "D11"    'Alterar com a celula de entrada
U = unifun(n)
For i = 1 To n
    InVarA.OrderedSample(i, k) = WorksheetFunction.NormInv(U(i), 71.16, 12.09)
Next i

'3rd input variable in A
k = 3
InVarA.VariableName(k) = "Input 3 - REVISTA"
InVarA.VariableSheet(k) = "Modelo"  'Alterar com o nome da aba
InVarA.VariableRange(k) = "E11"     'Alterar com a celula de entrada
U = unifun(n)
For i = 1 To n
    InVarA.OrderedSample(i, k) = TriangularInv(U(i), -1.317419, 0.2527516, 1.337439)
Next i

'4th input variable in A
k = 4
InVarA.VariableName(k) = "Input 4 - RADIO"
InVarA.VariableSheet(k) = "Modelo"   'Alterar com o nome da aba
InVarA.VariableRange(k) = "F11"       'Alterar com a celula de entrada
U = unifun(n)
For i = 1 To n
    InVarA.OrderedSample(i, k) = UniformInv(U(i), 1.2, 5.721)
Next i

'5th input variable in A
k = 5
InVarA.VariableName(k) = "Input 5 - TV"
InVarA.VariableSheet(k) = "Modelo"   'Alterar com o nome da aba
InVarA.VariableRange(k) = "G11"      'Alterar com a celula de entrada
U = unifun(n)
For i = 1 To n
    InVarA.OrderedSample(i, k) = WorksheetFunction.LogInv(U(i), 0.1, 0.2)
Next i

InVarA.GenerateIndependentSample


' AREA PARA AS VARIAVEIS DE SAIDA

' OUTPUT VARIABLES

Dim OutVar As ClsRandomVariableSubset
Set OutVar = New ClsRandomVariableSubset
OutputVariables.Add OutVar

OutVar.NumVars = 1  'Alterar com o número de variaveis de saida
OutVar.NumIters = n
OutVar.Size

' First output variable

OutVar.VariableName(1) = "Output 1 - Custo"
OutVar.VariableSheet(1) = "Modelo"
OutVar.VariableRange(1) = "C45"

' Second output variable - NÃO UTILIZADO

'OutVar.VariableName(2) = "Output 2"
'OutVar.VariableSheet(2) = "Model"
'OutVar.VariableRange(2) = "B22"

' END OF USER INPUTS

elatim1 = Timer - start

Call RunModel(InputVariables, OutputVariables)
Call Graphs(InputVariables, NumBins:=20, NumPoints:=100, SheetTitle:="Input variables")
Call Graphs(OutputVariables, NumBins:=20, NumPoints:=100, SheetTitle:="Output variables")

elatim2 = Timer - start - elatim1

elatim = elatim1 + elatim2

MsgBox "Number of iterations = " & n & vbNewLine & _
       "Time to generate input sample = " & elatim1 & " seconds" & vbNewLine & _
       "Time to run spreadsheet model = " & elatim2 & " seconds" & vbNewLine & _
       "Total time = " & elatim & " seconds."
       
End Sub
