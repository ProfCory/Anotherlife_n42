-- aln_hostilezones/client/util.lua
Util = {}

function Util.Distance(a, b)
    return #(a - b)
end

function Util.InZone(pos, zone)
    return Util.Distance(pos, zone.center) <= zone.radius
end

function Util.ZoneOverlap(a, b)
    local d = Util.Distance(a.center, b.center)
    return d < (a.radius + b.radius)
end

function Util.OverlapPoint(a, b)
    -- simple midpoint works fine for MVP
    return (a.center + b.center) * 0.5
end

function Util.RandomPointInRing(origin, minR, maxR)
    local ang = math.random() * math.pi * 2.0
    local r = minR + (math.random() * (maxR - minR))
    return vec3(origin.x + math.cos(ang) * r, origin.y + math.sin(ang) * r, origin.z)
end

function Util.GroundZ(pos)
    local success, z = GetGroundZFor_3dCoord(pos.x, pos.y, pos.z + 50.0, false)
    if success then
        return vec3(pos.x, pos.y, z + 1.0)
    end
    return pos
end

function Util.DrawCircle(pos, radius)
    DrawMarker(1, pos.x, pos.y, pos.z - 1.0, 0,0,0, 0,0,0, radius*2, radius*2, 1.0, 255,0,0,80, false,false,2)
end

function Util.DrawSmallMarker(pos, r, g, b)
    DrawMarker(1, pos.x, pos.y, pos.z - 1.0, 0,0,0, 0,0,0, 1.0, 1.0, 1.0, r or 0, g or 255, b or 0, 120, false,false,2)
end
