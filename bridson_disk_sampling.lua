do -- require "table", "ndarray", "grid"

    -- Основной объект BridsonDiskSampling для генерации точек
    ---@class BridsonDiskSampling
    BridsonDiskSampling = {}
    local BDS = BridsonDiskSampling  -- Сокращенное название
    local object_meta = {
        __index = BDS
    }
    ---create
    ---@param xmin number
    ---@param xmax number
    ---@param ymin number
    ---@param ymax number
    ---@param R number
    ---@param K number
    function BDS:create(xmin, xmax, ymin, ymax, R, K)
        local obj = setmetatable({}, object_meta)
        obj.K = K or 30  -- Количество попыток для каждой точки
        obj.R = R        -- Минимальное расстояние между точками
        obj.R2 = R * R   -- Квадрат минимального расстояния (для оптимизации)
        obj.xmin = xmin
        obj.xmax = xmax
        obj.ymin = ymin
        obj.ymax = ymax
        obj.width = xmax - xmin
        obj.height = ymax - ymin
        obj.cell_size = R  -- Размер ячейки сетки
        local shape = {
            math.floor(obj.height / obj.cell_size + 1),
            math.floor(obj.width  / obj.cell_size  + 1)
        }
        obj.grid = table.tools.Grid2D:create(shape, obj.xmin, obj.xmax, obj.ymin, obj.ymax)
        obj.samples = {}       -- Список сгенерированных точек { {x, y}, ... }
        obj.active_list = {}   -- Активный список точек для обработки
        return obj
    end

    function BDS:generate()
        -- Шаг 0: Выбираем первую точку случайно в области
        local x0 = math.random() * self.width + self.xmin
        local y0 = math.random() * self.height + self.ymin
        self:add_sample(x0, y0)
        -- Пока активный список не пуст
        while #self.active_list > 0 do
            -- Выбираем случайную точку из активного списка
            local loc = table.remove(self.active_list)
            local x, y = loc.x, loc.y

            -- Пробуем сгенерировать до K новых точек вокруг выбранной
            local al = #self.active_list
            for i = 1, self.K do
                local angle = math.random() * 2 * math.pi
                local radius = math.sqrt(math.random()) * self.R + self.R
                local nx = x + radius * math.cos(angle)
                local ny = y + radius * math.sin(angle)
                if self:is_valid(nx, ny) then
                    self:add_sample(nx, ny)
                end
            end
        end
        return self.samples
    end

    function BDS:add_sample(_x, _y)
        local cell = self.grid:get_cell(_x, _y)
        local loc = {x=_x, y=_y}
        table.insert(self.samples, loc)
        table.insert(self.active_list, loc)
        local index = #self.samples
        cell.index = index
    end

    function BDS:is_in_bounds(x, y)
        return x >= self.xmin and x <= self.xmax and y >= self.ymin and y <= self.ymax
    end

    function BDS:is_valid(x, y)
        if not self:is_in_bounds(x, y) then return false end
        local cell = self.grid:get_cell(x, y)
        if cell.index then return false end
        local neighbors = self.grid:get_neighbors(x, y)
        --print(#neighbors)
        for _, cell in ipairs(neighbors) do
            local index = cell.index
            if index then
                local sx, sy = self.samples[index].x, self.samples[index].y
                local dx = x - sx
                local dy = y - sy
                if dx * dx + dy * dy < self.R2 then
                    return false
                end
            end
        end
        return true
    end

    local meta = {
        __call = BDS.create
    }

    setmetatable(BDS, meta)
end


