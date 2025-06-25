---@return BridsonDiskSampling
function QuasiRandomSystem(rect, min_distance)
    local minx = GetRectMinX(rect)
    local maxx = GetRectMaxX(rect)
    local miny = GetRectMinY(rect)
    local maxy = GetRectMaxY(rect)
    local min_distance = min_distance or 1000
    -------------------------------------------------------------------------------
    local samples = BridsonDiskSampling(minx, maxx, miny, maxy, min_distance):generate()
    table.shuffle(samples)
    return samples
end

