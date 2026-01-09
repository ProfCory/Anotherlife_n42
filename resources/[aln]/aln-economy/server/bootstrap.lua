ALN = ALN or {}
ALN.Economy = ALN.Economy or {}

-- Identity keying:
-- Until aln-persistent-data exists, we key by playerKey (license:xxxx).
-- Later we will key by characterId (db id) but keep the same API.
function ALN.Economy.GetIdentityKey(src)
  if GetResourceState('aln-persistent-data') == 'started' then
    local k = exports['aln-persistent-data']:GetActiveIdentityKey(src)
    if k then return k end
  end
  return exports['aln-core']:GetPlayerKey(src) or ('src:%d'):format(src)
end

