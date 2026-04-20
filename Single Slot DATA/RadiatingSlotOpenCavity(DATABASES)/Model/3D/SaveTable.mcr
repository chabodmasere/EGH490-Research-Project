' SaveTable

Sub Main () 
SelectTreeItem "Tables\1D Results\curve1_e-field(f=9)(1)"
ExportPlotData "ReEx.txt"
SelectTreeItem "Tables\1D Results\curve1_e-field(f=9)(1)_1"
ExportPlotData "ImEx.txt"
End Sub
