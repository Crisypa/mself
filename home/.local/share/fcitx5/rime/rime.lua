-- 暴力 GC
-- 来自 https://github.com/iDvel/rime-ice/blob/main/rime.lua#L79
function force_gc()
    -- collectgarbage()
    collectgarbage("step")
end
