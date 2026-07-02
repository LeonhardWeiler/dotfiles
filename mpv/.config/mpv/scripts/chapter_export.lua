local utils = require 'mp.utils'

local chapters = {}

function save_chapter()
    local time_pos = mp.get_property_number("time-pos")
    if not time_pos then return end

    local timestamp = string.format("%02d:%02d:%02d", time_pos / 3600, (time_pos % 3600) / 60, time_pos % 60)
    local rofi_command = {
        "bash", "-c",
        "rofi -dmenu -p 'Kapitelname für " .. timestamp .. ":'"
    }

    local result = utils.subprocess({args = rofi_command})
    if result.status == 0 and result.stdout and result.stdout ~= "" then
        local title = result.stdout:gsub("\n", "")
        table.insert(chapters, {start = time_pos, title = title})
        mp.osd_message("Kapitel gespeichert: " .. timestamp .. " - " .. title)
    else
        mp.osd_message("Kapitel-Eingabe abgebrochen.")
    end
end

function export_all()
    if #chapters == 0 then
        mp.osd_message("Keine Kapitel zum Exportieren.")
        return
    end

    local video_path = mp.get_property("path")
    if not video_path then return end
    local dir = utils.split_path(video_path)
    local filename = video_path:match("([^/]+)%.%w+$") or "output"

    local txt_path = dir .. filename .. "_timestamps.txt"
    local ffmeta_path = dir .. filename .. "_chapters.ffmeta"
    local edl_path = dir .. filename .. "_chapters.edl"

    local txt = io.open(txt_path, "w")
    local ffmeta = io.open(ffmeta_path, "w")
    local edl = io.open(edl_path, "w")

    ffmeta:write(";FFMETADATA1\n")
    edl:write("TITLE " .. filename .. "\nFCM NON-DROP FRAME\n")

    local duration = mp.get_property_number("duration")
    for i, ch in ipairs(chapters) do
        local start = ch.start
        local stop = (i < #chapters) and chapters[i + 1].start or duration
        local title = ch.title

        -- TXT
        local h = math.floor(start / 3600)
        local m = math.floor((start % 3600) / 60)
        local s = math.floor(start % 60)
        txt:write(string.format("%02d:%02d:%02d - %s\n", h, m, s, title))

        -- FFMETADATA
        ffmeta:write("[CHAPTER]\n")
        ffmeta:write("TIMEBASE=1/1\n")
        ffmeta:write("START=" .. math.floor(start) .. "\n")
        ffmeta:write("END=" .. math.floor(stop) .. "\n")
        ffmeta:write("title=" .. title .. "\n")

        -- EDL (DaVinci Resolve)
        edl:write(string.format("001  AX       V     C        %s %s %s %s\n",
            frame_time(start), frame_time(stop), frame_time(start), frame_time(stop)))
        edl:write("* FROM CLIP NAME: " .. title .. "\n")
    end

    txt:close()
    ffmeta:close()
    edl:close()

    mp.osd_message("Export abgeschlossen.")
end

-- Frame-Zeit für EDL (assume 25 fps for simplicity)
function frame_time(seconds)
    local fps = 25
    local total_frames = math.floor(seconds * fps)
    local hours = math.floor(total_frames / (3600 * fps))
    local minutes = math.floor((total_frames % (3600 * fps)) / (60 * fps))
    local seconds = math.floor((total_frames % (60 * fps)) / fps)
    local frames = total_frames % fps
    return string.format("%02d:%02d:%02d:%02d", hours, minutes, seconds, frames)
end

mp.add_key_binding("t", "save-chapter", save_chapter)
mp.add_key_binding("T", "export-chapters", export_all)

