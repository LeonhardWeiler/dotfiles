local M = {}

local root = vim.fn.expand("~/files/projects/leonhardweiler.github.io/")

local template = root .. "/templates/text.html"
local texts = root .. "/texts.html"
local pages = root .. "/pages"

local function slugify(title)
  local slug = title:lower()

  slug = slug:gsub("[^%w%s-]", "")
  slug = slug:gsub("%s+", "-")
  slug = slug:gsub("%-+", "-")

  return slug
end

function M.new_text()
  vim.ui.input({
    prompt = "Title: ",
  }, function(title)
    if not title or title == "" then
      return
    end

    local slug = slugify(title)
    local filename = slug .. ".html"
    local filepath = pages .. "/" .. filename
    local date = os.date("%Y-%m-%d")

    if vim.fn.filereadable(filepath) == 1 then
      print("File already exists.")
      return
    end

    local lines = vim.fn.readfile(template)

    for i, line in ipairs(lines) do
      line = line:gsub("{{TITLE}}", title)
      lines[i] = line
    end

    vim.fn.writefile(lines, filepath)

    local html = vim.fn.readfile(texts)

    local row = {
      "          <tr>",
      "            <td>",
      "              <a",
      '                class="not-started"',
      '                href="./pages/' .. filename .. '"',
      "                ><span>" .. title .. "</span></a",
      "              >",
      "            </td>",
      '            <td class="shrink">',
      '              <time datetime="' .. date .. '">' .. date .. "</time>",
      "            </td>",
      '            <td class="shrink">',
      '              <time datetime="' .. date .. '">' .. date .. "</time>",
      "            </td>",
      "          </tr>",
    }

    for i, line in ipairs(html) do
      if line:find("<tbody>") then
        for j = #row, 1, -1 do
          table.insert(html, i + 1, row[j])
        end
        break
      end
    end

    vim.fn.writefile(html, texts)

    vim.cmd("edit " .. filepath)

    print("Created " .. filename)
  end)
end

function M.update_edited()
  local filepath = vim.fn.expand("%:p")
  if not filepath:find("/pages/") then
    return
  end
  local filename = vim.fn.expand("%:t")
  local date = os.date("%Y-%m-%d")
  local html = vim.fn.readfile(texts)
  local found = false
  for i, line in ipairs(html) do
    if line:find("./pages/" .. filename, 1, true) then
      found = true
      for j = i, math.min(i + 20, #html) do
        if html[j]:find('<td class="shrink">', 1, true) then
          for k = j + 1, math.min(j + 3, #html) do
            if html[k]:find("<time", 1, true) then
              html[k] = '              <time datetime="' .. date .. '">' .. date .. "</time>"
              break
            end
          end
          break
        end
      end
      break
    end
  end
  if found then
    vim.fn.writefile(html, texts)
    print("Updated edited date")
  end
end

vim.api.nvim_create_user_command("NewText", M.new_text, {})
vim.api.nvim_create_user_command("UpdateEdited", M.update_edited, {})

return M
