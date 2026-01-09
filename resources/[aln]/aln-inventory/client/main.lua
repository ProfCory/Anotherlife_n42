RegisterNetEvent('aln:inv:result', function(payload)
  print('[ALN3][inv] result=' .. json.encode(payload))
end)

RegisterNetEvent('aln:inv:snapshot', function(payload)
  print('[ALN3][inv] snapshot=' .. json.encode(payload))
end)
