Imports System.Runtime.InteropServices

Public Class Form1

    ' --- Link to the C++ Backend (DLL) ---
    ' Declares the five C++ interpolation functions so VB can call them.
    ' DllImport specifies the DLL file and Cdecl ensures correct function calling.

    <DllImport("InterpolationBackend.dll", CallingConvention:=CallingConvention.Cdecl)>
    Public Shared Function interpolateLinear( _
        ByVal targetX As Double, _
        ByVal x() As Double, _
        ByVal y() As Double, _
        ByVal n As Integer _
    ) As Double
    End Function

    <DllImport("InterpolationBackend.dll", CallingConvention:=CallingConvention.Cdecl)>
    Public Shared Function interpolatePiecewise( _
        ByVal targetX As Double, _
        ByVal x() As Double, _
        ByVal y() As Double, _
        ByVal n As Integer _
    ) As Double
    End Function

    <DllImport("InterpolationBackend.dll", CallingConvention:=CallingConvention.Cdecl)>
    Public Shared Function interpolateNearestNeighbor( _
        ByVal targetX As Double, _
        ByVal x() As Double, _
        ByVal y() As Double, _
        ByVal n As Integer _
    ) As Double
    End Function

    <DllImport("InterpolationBackend.dll", CallingConvention:=CallingConvention.Cdecl)>
    Public Shared Function interpolateNewton( _
        ByVal targetX As Double, _
        ByVal x() As Double, _
        ByVal y() As Double, _
        ByVal n As Integer _
    ) As Double
    End Function

    <DllImport("InterpolationBackend.dll", CallingConvention:=CallingConvention.Cdecl)>
    Public Shared Function interpolateLagrange( _
        ByVal targetX As Double, _
        ByVal x() As Double, _
        ByVal y() As Double, _
        ByVal n As Integer _
    ) As Double
    End Function

    ' Set up the grid for a clean appearance when the form loads.
    Private Sub Form1_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load
        ' Auto-size columns to perfectly fill the grid
        dgvData.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill

        ' Center text for better readability
        dgvData.Columns(0).DefaultCellStyle.Alignment = DataGridViewContentAlignment.MiddleCenter
        dgvData.Columns(1).DefaultCellStyle.Alignment = DataGridViewContentAlignment.MiddleCenter
    End Sub

    ' These are empty event handlers, can be safely ignored or removed.
    Private Sub Label1_Click(ByVal sender As System.Object, ByVal e As System.EventArgs)
    End Sub
    Private Sub txtTarget_TextChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles txtTarget.TextChanged
    End Sub
    Private Sub lblTarget_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles lblTarget.Click
    End Sub
    Private Sub lblMethod_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles lblMethod.Click
    End Sub

    ' This is the main function that runs when the "Calculate" button is clicked.
    Private Sub btnCalculate_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnCalculate.Click
        ' Main calculation logic, wrapped in a Try...Catch to handle any errors gracefully.
        Try
            ' Get the number of points from the 'N' text box.
            Dim n As Integer = Integer.Parse(txtN.Text)

            ' Create arrays to hold the X and Y data points.
            Dim x(n - 1) As Double
            Dim y(n - 1) As Double

            ' Loop through the grid and read each X, Y pair into the arrays.
            For i As Integer = 0 To n - 1
                ' Make sure cells are not empty.
                If dgvData.Rows(i).Cells(0).Value Is Nothing OrElse _
                   dgvData.Rows(i).Cells(1).Value Is Nothing Then
                    MessageBox.Show("Please fill all X and Y values.", "Input Error")
                    Exit Sub
                End If

                ' Validate each cell to make sure it's a valid number.
                If Not Double.TryParse(dgvData.Rows(i).Cells(0).Value.ToString(), x(i)) Then
                    MessageBox.Show("Invalid X value at row " & (i + 1).ToString(), "Input Error")
                    Exit Sub
                End If

                If Not Double.TryParse(dgvData.Rows(i).Cells(1).Value.ToString(), y(i)) Then
                    MessageBox.Show("Invalid Y value at row " & (i + 1).ToString(), "Input Error")
                    Exit Sub
                End If
            Next

            ' Get the target X value and validate it.
            Dim target As Double
            If Not Double.TryParse(txtTarget.Text, target) Then
                MessageBox.Show("Invalid Target X value. Please enter a valid number.", "Input Error")
                Exit Sub
            End If
            Dim result As Double

            ' Sort the data points based on X values (required for some methods).
            Array.Sort(x, y)

            ' Check for duplicate X values to prevent division-by-zero errors.
            For i As Integer = 0 To n - 2
                If Math.Abs(x(i) - x(i + 1)) < 0.000000001 Then
                    MessageBox.Show("Duplicate X values detected!", "Invalid Data")
                    Exit Sub
                End If
            Next

            ' Ensure the user has selected a method from the dropdown.
            If cmbMethod.SelectedIndex = -1 Then
                MessageBox.Show("Please select an interpolation method.", "Missing Selection")
                Exit Sub
            End If

            ' Check if the target is outside the known data range (extrapolation).
            If target < x(0) OrElse target > x(n - 1) Then
                Dim selectedMethod As String = cmbMethod.SelectedItem.ToString()
                ' For methods that can't extrapolate, show an error and stop.
                If selectedMethod = "Linear Interpolation" OrElse selectedMethod = "Piecewise Constant" Then
                    MessageBox.Show("Target X is outside the data range. " & selectedMethod & " cannot extrapolate.", "Out of Range Error")
                    Exit Sub
                Else
                    ' For other methods, just warn the user but allow the calculation.
                    MessageBox.Show("Warning: Target X is outside the data range. The result is an extrapolation and may be inaccurate.", "Extrapolation Warning")
                End If
            End If

            ' Call the appropriate C++ function based on the user's selection.
            Select Case cmbMethod.SelectedIndex
                Case 0
                    result = interpolatePiecewise(target, x, y, n)
                Case 1
                    result = interpolateNearestNeighbor(target, x, y, n)
                Case 2
                    result = interpolateLinear(target, x, y, n)
                Case 3
                    result = interpolateNewton(target, x, y, n)
                Case 4
                    result = interpolateLagrange(target, x, y, n)
                Case Else
                    MessageBox.Show("Select an interpolation method.")
                    Exit Sub
            End Select

            ' Display the final result in the result text box, formatted to 4 decimal places.
            txtResult.Text = result.ToString("F4")

        Catch ex As Exception
            MessageBox.Show("Error in input or DLL call.", "Runtime Error")
        End Try
    End Sub

    ' This is an empty event handler, can be safely ignored or removed.
    Private Sub lblResult_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles lblResult.Click
    End Sub

    ' Automatically resize the grid when the user changes the number of points.
    Private Sub txtN_TextChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles txtN.TextChanged
        Dim n As Integer
        If Integer.TryParse(txtN.Text, n) Then
            dgvData.Rows.Clear()
            dgvData.RowCount = n
        End If
    End Sub

    ' Clears all input fields and resets the form to its initial state.
    Private Sub btnClear_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnClear.Click
        txtN.Clear()
        txtTarget.Clear()
        txtResult.Clear()
        cmbMethod.SelectedIndex = -1
        dgvData.Rows.Clear()
    End Sub

    Private Sub dgvData_CellContentClick(ByVal sender As System.Object, ByVal e As System.Windows.Forms.DataGridViewCellEventArgs) Handles dgvData.CellContentClick
    End Sub

    Private Sub lblN_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles lblN.Click
    End Sub
End Class
