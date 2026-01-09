ALN = ALN or {}
ALN.Admin = ALN.Admin or {}

function ALN.Admin.IsAllowed(src)
  if src == 0 then
    return Config.Admin.AllowConsole == true
  end
  local ace = Config.Admin.RequiredAce or 'aln.admin'
  return IsPlayerAceAllowed(src, ace)
end

function ALN.Admin.Deny(src)
  if src == 0 then
    print('[ALN3][admin] denied (console not allowed)')
  else
    TriggerClientEvent('chat:addMessage', src, { args = { '^1ALN^7', 'Access denied.' } })
  end
end

function ALN.Admin.Print(src, msg)
  if src == 0 then
    print(msg)
  else
    TriggerClientEvent('aln:admin:print', src, msg)
  end
end

function ALN.Admin.J(src, obj)
  ALN.Admin.Print(src, (type(obj) == 'table') and json.encode(obj) or tostring(obj))
end
