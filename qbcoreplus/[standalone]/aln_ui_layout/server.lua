RegisterNetEvent('aln_ui_layout:save', function(tbl)
  SetResourceKvp(GetCurrentResourceName(), json.encode(tbl))
end)
