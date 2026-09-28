-- HTTP client for .http files (VS Code REST Client / JetBrains spec).
--
-- Plugin source
-- mistweaverco/kulala.nvim is private / not cloneable without GitHub login.
-- vim.pack.add uses the public recovery fork andycowan/kulala.nvim instead.
--
-- kulala-core backend
-- The fork auto-downloads GitHub releases, but v0.37.0-andycowan.1 only ships
-- kulala-core-darwin-arm64. Linux x86_64 download always failed.
-- Fix: build kulala-core from andycowan/kulala-core with Bun
--   bun run build:linux-x64
-- then install the binary at stdpath("data")/kulala.nvim/bin/kulala-core
-- and pin kulala_core.path so Kulala does not fetch GitHub again.
--
-- tree-sitter kulala_http grammar
-- Kulala git-inits stdpath("data")/kulala.nvim/tree-sitter-kulala-http then
-- fetches origin. The first run left an empty .git with no origin, so fetch
-- failed with: 'origin' does not appear to be a git repository.
-- The plugin also wants commit 630e2b85… which is not on the public fork.
-- Fix: clone https://github.com/andycowan/tree-sitter-kulala-http (has origin),
-- build with tree-sitter into stdpath("data")/site/parser/kulala_http.so,
-- and copy queries to stdpath("data")/site/queries/kulala_http/.
-- parser_rev is left unset so Kulala treats the parser as externally managed
-- and skips the broken fetch.
--
-- REST Client env
-- Kulala does not read .vscode/settings.json (JSONC). Envs are in
-- database/rest_client/http-client.env.json, a comment-free clone of
-- rest-client.environmentVariables.
-- REST Client auto-decompresses gzip. kulala-core does not, so gzip JSON is
-- shown as "Binary response body". $kulalaDefaultHeaders omits gzip, and
-- restore_response_body gunzips leftover gzip JSON before the body pane.
--
-- REST Client query params
-- catalog.landing-page.http (and other REST Client files) put `?` / `&` on their
-- own lines so the URL is easy to read. A `#` in front of a query line comments
-- it out (`# ?id=11`) while the next `?id=` stays active.
-- kulala-core only continues a request URL when the next line starts with
-- whitespace. Column-0 `?id=` is not part of the URL. kulala-core then reports
--   Unrecognized request block line: "?id=..."
-- and sends the path with no query (e.g. /landing-page instead of /landing-page?id=19).
-- That showed up on catalog.landing-page, listing-page, brand, pdp, deal, and
-- sale-order-pos.recommend. catalog.blog.http is fine after Shift+Alt+F.
-- Compromise fmt (Shift+Alt+F, same chord as JSON jq): indent `?` / `&` / `# ?id=`
-- with one space, keep comments, two blank lines before each ### and after the
-- last request. Ctrl+Alt+F is often swallowed by the OS, so it is only a fallback.
-- The old send-time indent overlay (Bridge.invoke rewrite) is commented out;
-- format the .http file instead of hiding the kulala-core error.

if vim.g.vscode then
  return
end

vim.pack.add({
  "https://github.com/andycowan/kulala.nvim",
})

local kulala = require("kulala")
-- Local Linux x86_64 build; see kulala-core backend comment above.
-- vim.fn.stdpath("data") is Neovim's XDG data dir, already a full path:
--   ~/.local/share/nvim
-- Lua `..` concatenates strings, so the binary is:
--   ~/.local/share/nvim/kulala.nvim/bin/kulala-core
local kulala_core = vim.fn.stdpath("data") .. "/kulala.nvim/bin/kulala-core"

-- Last .http window before jumping to the response, so we can return to the file editor.
local last_http_win

-- jump_back_to_request focuses the .http file window from the response split.
local function jump_back_to_request()
  local function focus_buf(buf)
    if not buf or buf <= 0 or not vim.api.nvim_buf_is_valid(buf) then
      return false
    end
    local win = vim.fn.win_findbuf(buf)[1]
    if not win then
      return false
    end
    vim.api.nvim_set_current_win(win)
    return true
  end

  if last_http_win and vim.api.nvim_win_is_valid(last_http_win) then
    vim.api.nvim_set_current_win(last_http_win)
    return
  end

  if focus_buf(require("kulala.db").get_current_buffer()) then
    return
  end

  local response = require("kulala.ui").get_current_response()
  if type(response) == "table" and focus_buf(response.buf) then
    return
  end

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local ft = vim.bo[vim.api.nvim_win_get_buf(win)].filetype
    if ft == "http" or ft == "rest" then
      vim.api.nvim_set_current_win(win)
      return
    end
  end
end

-- jump_to_response_pane toggles focus between the request buffer and the response split.
local function jump_to_response_pane()
  local ui_id = require("kulala.globals").UI_ID
  local buf = vim.fn.bufnr(ui_id)
  local response_win = buf > 0 and vim.fn.win_findbuf(buf)[1]
  local current_win = vim.api.nvim_get_current_win()

  -- From the response split, return to the .http request window.
  if response_win and current_win == response_win then
    jump_back_to_request()
    return
  end

  last_http_win = current_win

  -- From the request buffer, focus the response split (open it if needed).
  if response_win then
    vim.api.nvim_set_current_win(response_win)
    return
  end

  require("kulala.ui").open_default_view()
  buf = vim.fn.bufnr(ui_id)
  response_win = buf > 0 and vim.fn.win_findbuf(buf)[1]
  if response_win then
    vim.api.nvim_set_current_win(response_win)
  end
end

-- Last Ctrl+Alt+E env, kept across Neovim restarts (kulala only stores it in
-- vim.g for the current session, or in :mksession if session.restore is used).
-- vim.fn.stdpath("state") is Neovim's XDG state dir, already a full path:
--   ~/.local/state/nvim
-- "state" is the kind of dir to look up, not a suffix glued onto $HOME.
-- Lua `..` concatenates strings, so this file is:
--   ~/.local/state/nvim/kulala-selected-env
local selected_env_file = vim.fn.stdpath("state") .. "/kulala-selected-env"

-- save_selected_env writes the picker choice so the next Neovim start reuses it.
local function save_selected_env(env)
  if type(env) ~= "string" or env == "" then
    return
  end
  vim.fn.writefile({ env }, selected_env_file)
end

-- restore_selected_env applies the last saved env before the first request.
local function restore_selected_env()
  if vim.fn.filereadable(selected_env_file) ~= 1 then
    return
  end
  local env = vim.trim((vim.fn.readfile(selected_env_file)[1] or ""))
  if env == "" then
    return
  end
  vim.g.kulala_selected_env = env
  require("kulala.db").update().selected_env = env
end

kulala.setup({
  kulala_core = {
    path = kulala_core,
  },
  -- Env names come from database/rest_client/http-client.env.json.
  -- Last picker choice overrides this after restore_selected_env().
  default_env = "dev",
  vscode_rest_client_environmentvars = false,
  global_keymaps = false,
  lsp = {
    enable = true,
    filetypes = { "http", "rest" },
    keymaps = false,
  },
  -- Keep JSON response body fully expanded (kulala defaults to indent folds).
  -- Default 32KB hides large catalog/blog JSON; 10MB is enough to show the body.
  ui = {
    win_opts = {
      wo = {
        wrap = false,
        foldenable = false,
        foldlevel = 99,
      },
    },
    max_response_size = 10 * 1024 * 1024,
    default_view = "body",
  },
  -- Keep default response-pane maps; add Ctrl+Alt+Q so the split can close from that window too.
  kulala_keymaps = {
    ["Close response split"] = {
      "<C-M-q>",
      function()
        require("kulala.ui").close_kulala_buffer()
      end,
      prefix = false,
    },
    ["Jump to request"] = {
      "<C-M-p>",
      jump_back_to_request,
      prefix = false,
      mode = { "n", "i", "x" },
    },
    -- gb: from the response split, go back to the .http file editor.
    ["Go back to request file"] = {
      "gb",
      jump_back_to_request,
      prefix = false,
    },
    -- Alt+Shift+H/L are jumplist (Ctrl+O / Ctrl+I). Block them here so they
    -- do not leave the response pane.
    ["Disable jumplist back"] = {
      "<M-S-h>",
      "<Nop>",
      prefix = false,
      mode = { "n", "i", "x" },
    },
    ["Disable jumplist forward"] = {
      "<M-S-l>",
      "<Nop>",
      prefix = false,
      mode = { "n", "i", "x" },
    },
  },
})

-- Persist Ctrl+Alt+E so a restart keeps qc instead of falling back to default_env.
if not vim.g.hsk_kulala_env_persist then
  vim.g.hsk_kulala_env_persist = true
  local DB = require("kulala.db")
  local orig_update = DB.update
  DB.update = function(...)
    local data = orig_update(...)
    return setmetatable(data, {
      __newindex = function(t, k, v)
        rawset(t, k, v)
        if k == "selected_env" then
          save_selected_env(v)
        end
      end,
    })
  end
  restore_selected_env()
  vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function()
      save_selected_env(vim.g.kulala_selected_env)
    end,
  })
end

-- HTTP methods whose next unindented `?` / `&` lines are REST Client query params.
local http_methods = {
  GET = true,
  POST = true,
  PUT = true,
  PATCH = true,
  DELETE = true,
  HEAD = true,
  OPTIONS = true,
  TRACE = true,
  CONNECT = true,
  GRAPHQL = true,
  GRPC = true,
  WEBSOCKET = true,
}

-- indent_rest_client_query_lines prefixes REST Client `?` / `&` / `# ?id=` lines
-- with one space so kulala-core joins query params and still skips comments.
local function indent_rest_client_query_lines(content)
  local lines = vim.split(content, "\n", { plain = true })
  local in_query = false

  for i, line in ipairs(lines) do
    local trimmed = vim.trim(line)
    local method = trimmed:match("^(%u+)%s+")
    local is_query = trimmed:match("^[?&]")
    local is_comment = trimmed:match("^#") or trimmed:match("^//")

    -- ### starts a new request, so stop joining query params onto the previous URL.
    if trimmed:match("^###") then
      in_query = false
    elseif method and http_methods[method] then
      in_query = true
    elseif in_query and (is_query or is_comment) then
      -- One leading space: kulala URL continuation, comment stays a comment.
      lines[i] = " " .. trimmed
    else
      in_query = false
    end
  end

  return lines
end

-- trim_blank_edges drops leading and trailing empty lines from a line list.
local function trim_blank_edges(lines)
  local first = 1
  local last = #lines
  while first <= last and vim.trim(lines[first]) == "" do
    first = first + 1
  end
  while last >= first and vim.trim(lines[last]) == "" do
    last = last - 1
  end
  local out = {}
  for i = first, last do
    out[#out + 1] = lines[i]
  end
  return out
end

-- space_http_requests puts two blank lines before every ### block and after the last request.
local function space_http_requests(lines)
  local preamble = {}
  local blocks = {}
  local current

  for _, line in ipairs(lines) do
    if vim.trim(line):match("^###") then
      if current then
        blocks[#blocks + 1] = current
      end
      current = { line }
    elseif current then
      current[#current + 1] = line
    else
      preamble[#preamble + 1] = line
    end
  end
  if current then
    blocks[#blocks + 1] = current
  end

  local out = trim_blank_edges(preamble)
  for _, block in ipairs(blocks) do
    out[#out + 1] = ""
    out[#out + 1] = ""
    for _, line in ipairs(trim_blank_edges(block)) do
      out[#out + 1] = line
    end
  end
  out[#out + 1] = ""
  out[#out + 1] = ""
  return out
end

-- format_http_buffer writes query indent and two blank lines between requests (Shift+Alt+F).
local function format_http_buffer()
  local buf = vim.api.nvim_get_current_buf()
  local ft = vim.bo[buf].filetype
  if ft ~= "http" and ft ~= "rest" then
    local req = require("kulala.db").get_current_buffer()
    if req and req > 0 and vim.api.nvim_buf_is_valid(req) then
      buf = req
    end
  end

  local win = vim.api.nvim_get_current_win()
  local restore_cursor = vim.api.nvim_win_get_buf(win) == buf
  local cursor = restore_cursor and vim.api.nvim_win_get_cursor(win) or nil
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local formatted = space_http_requests(indent_rest_client_query_lines(table.concat(lines, "\n")))
  if vim.deep_equal(lines, formatted) then
    vim.notify("HTTP already formatted", vim.log.levels.INFO)
    return
  end
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, formatted)
  if cursor then
    local row = math.min(cursor[1], math.max(1, #formatted))
    local col = math.min(cursor[2], #(formatted[row] or ""))
    pcall(vim.api.nvim_win_set_cursor, win, { row, col })
  end
  vim.notify("HTTP formatted", vim.log.levels.INFO)
end

-- Send-time indent overlay is off. kulala-core must see the file as formatted
-- (leading space on `?` / `&` / `# ?id=`). Without that it errors:
--   Unrecognized request block line: "?id=..."
-- and drops the query from the URL. Use Shift+Alt+F (or :HttpFormat) first.
local Bridge = require("kulala.cmd.kulala_core_bridge")
-- if not Bridge._hsk_rest_client_query then
--   Bridge._hsk_rest_client_query = true
--   local orig_invoke = Bridge.invoke
--   local orig_invoke_async = Bridge.invoke_async
--
--   local function with_indented_query_params(payload)
--     if type(payload) ~= "table" or type(payload.content) ~= "string" then
--       return payload
--     end
--     payload = vim.deepcopy(payload)
--     payload.content = table.concat(indent_rest_client_query_lines(payload.content), "\n")
--     return payload
--   end
--
--   Bridge.invoke = function(payload, cwd)
--     return orig_invoke(with_indented_query_params(payload), cwd)
--   end
--   Bridge.invoke_async = function(payload, cwd, on_done)
--     return orig_invoke_async(with_indented_query_params(payload), cwd, on_done)
--   end
-- end

-- file_header_vars reads @name=value from the .http buffer so {{base_url}} can be expanded.
local function file_header_vars(bufnr)
  local vars = {}
  if not bufnr or bufnr == 0 or not vim.api.nvim_buf_is_valid(bufnr) then
    return vars
  end
  for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
    local name, value = line:match("^@([%w_.-]+)%s*=%s*(.*)$")
    if name then
      vars[name] = vim.trim(value)
    end
  end
  return vars
end

-- expand_templates concatenates nested {{host}}{{catalog_path}} using env + file vars.
local function expand_templates(text, vars)
  if type(text) ~= "string" or not text:find("{{", 1, true) then
    return text
  end
  for _ = 1, 8 do
    local replaced = text:gsub("{{%s*([^}]+)%s*}}", function(name)
      local value = vars[vim.trim(name)]
      if value == nil then
        return ""
      end
      if type(value) == "table" then
        return vim.json.encode(value)
      end
      return tostring(value)
    end)
    if replaced == text then
      return replaced
    end
    text = replaced
  end
  return text
end

-- expand_hover fills leftover {{var}} in LSP hover so K shows the concatenated env URL.
local function expand_hover(res, bufnr)
  if type(res) ~= "table" or type(res.contents) ~= "table" then
    return res
  end
  local value = res.contents.value
  if type(value) ~= "string" then
    return res
  end
  local env = require("kulala.parser.env").get_env()
  local vars = vim.tbl_extend("force", env, file_header_vars(bufnr))
  res.contents.value = expand_templates(value, vars)
  return res
end

if not Bridge._hsk_expand_hover then
  Bridge._hsk_expand_hover = true
  local orig_hover = Bridge.lsp_hover
  local orig_hover_async = Bridge.lsp_hover_async
  Bridge.lsp_hover = function(bufnr)
    local res, err = orig_hover(bufnr)
    if res then
      res = expand_hover(res, bufnr)
    end
    return res, err
  end
  Bridge.lsp_hover_async = function(bufnr, on_done)
    orig_hover_async(bufnr, function(res, err)
      if res then
        res = expand_hover(res, bufnr)
      end
      on_done(res, err)
    end)
  end
end

-- format_raw_headers prints status + headers as HTTP text, not a markdown table.
local http_reasons = {
  [200] = "OK",
  [201] = "Created",
  [204] = "No Content",
  [301] = "Moved Permanently",
  [302] = "Found",
  [304] = "Not Modified",
  [400] = "Bad Request",
  [401] = "Unauthorized",
  [403] = "Forbidden",
  [404] = "Not Found",
  [409] = "Conflict",
  [422] = "Unprocessable Entity",
  [429] = "Too Many Requests",
  [500] = "Internal Server Error",
  [502] = "Bad Gateway",
  [503] = "Service Unavailable",
}

local function header_field_value(v)
  if type(v) == "table" then
    if vim.islist(v) then
      return table.concat(vim.tbl_map(tostring, v), ", ")
    end
    return vim.inspect(v)
  end
  return tostring(v or "")
end

local function status_line(r)
  local code = tonumber(r.response_code) or 0
  local reason = http_reasons[code]
  if reason then
    return ("HTTP/1.1 %s %s"):format(code, reason)
  end
  return ("HTTP/1.1 %s"):format(code)
end

local function format_raw_headers(r)
  local raw = r.headers
  if type(raw) == "string" and vim.trim(raw) ~= "" then
    raw = vim.trim(raw)
    if raw:match("^HTTP/") then
      return raw
    end
    return status_line(r) .. "\n" .. raw
  end

  local tbl = r.headers_tbl
  if type(tbl) ~= "table" or not next(tbl) then
    return status_line(r)
  end
  local keys = vim.tbl_keys(tbl)
  table.sort(keys, function(a, b)
    return a:lower() < b:lower()
  end)
  local lines = { status_line(r) }
  for _, k in ipairs(keys) do
    lines[#lines + 1] = k .. ": " .. header_field_value(tbl[k])
  end
  return table.concat(lines, "\n")
end

-- read_response_bytes loads gzip/JSON bytes from kulala-core's base64 payload or temp file.
local function read_response_bytes(r)
  local bin = r._kulala_binary
  if type(bin) == "table" and bin.encoding == "base64" and type(bin.content) == "string" then
    local ok, decoded = pcall(vim.base64.decode, bin.content)
    if ok and type(decoded) == "string" and decoded ~= "" then
      return decoded
    end
  end

  local path = r._kulala_image_path
  if type(path) ~= "string" or path == "" then
    path = (r.body or ""):match("Path: (%S+)")
  end
  if type(path) ~= "string" or path == "" then
    return nil
  end

  local f = io.open(path, "rb")
  if not f then
    return nil
  end
  local bytes = f:read("*a")
  f:close()
  if type(bytes) ~= "string" or bytes == "" then
    return nil
  end
  return bytes
end

-- gunzip_bytes inflates gzip payload so application/json is readable text.
local function gunzip_bytes(bytes)
  if type(bytes) ~= "string" or #bytes < 2 or bytes:byte(1) ~= 0x1f or bytes:byte(2) ~= 0x8b then
    return nil
  end
  local result = vim.system({ "gzip", "-dc" }, { stdin = bytes, text = true }):wait()
  if result.code ~= 0 or type(result.stdout) ~= "string" or result.stdout == "" then
    return nil
  end
  return result.stdout
end

-- pretty_json expands JSON so the response pane shows nested fields instead of one line.
local function pretty_json(text)
  local ok, decoded = pcall(vim.json.decode, text)
  if not ok then
    return text, false
  end
  local ok2, encoded = pcall(vim.json.encode, decoded, { indent = "  " })
  if ok2 and type(encoded) == "string" then
    return encoded, true
  end
  return text, true
end

-- Replace kulala's markdown header tables with raw HTTP header text.
-- restore_response_body uses kulala-core's snapshot when BODY_FILE was empty,
-- which otherwise shows "No response body (check Verbose output)".
-- Gzip JSON is classified as binary by kulala-core; inflate it before display.
local function restore_response_body(r)
  if type(r) ~= "table" then
    return
  end

  -- Inflate gzip JSON so the body pane shows text instead of a .bin path note.
  if r._kulala_body_type == "binary" and not r._hsk_gunzipped then
    local bytes = read_response_bytes(r)
    local inflated = gunzip_bytes(bytes)
    local text = inflated or bytes
    if type(text) == "string" then
      local formatted, is_json = pretty_json(text)
      if is_json then
        r.body = formatted
        r.body_raw = text
        r._kulala_body_type = "json"
        r._hsk_gunzipped = true
        local ok, decoded = pcall(vim.json.decode, text)
        if ok then
          r.json = decoded
        end
        return
      end
      if inflated then
        r.body = inflated
        r.body_raw = inflated
        r._kulala_body_type = "text"
        r._hsk_gunzipped = true
        return
      end
    end
  end

  local body = r.body or ""
  local raw = r.body_raw or ""
  local missing = body == ""
    or body == "No response body (check Verbose output)"
    or body:match("^The size of response is >")
  if missing and raw ~= "" then
    r.body = raw
  end
end

local Markdown = require("kulala.ui.markdown")
Markdown.format_headers_view = function(r)
  restore_response_body(r)
  return format_raw_headers(r)
end
Markdown.format_headers_body_view = function(r, body)
  restore_response_body(r)
  body = vim.trim(body or r.body or "")
  local headers = format_raw_headers(r)
  if body == "" or body == "No response body (check Verbose output)" then
    return headers
  end
  return body .. "\n\n" .. headers
end

-- unlock_response_buffer lets you edit the response pane. kulala sets
-- modifiable=false / readonly after it writes the body.
local UI = require("kulala.ui")
local function unlock_response_buffer()
  local buf = UI.get_kulala_buffer and UI.get_kulala_buffer()
  if not buf or buf <= 0 or not vim.api.nvim_buf_is_valid(buf) then
    return
  end
  vim.bo[buf].modifiable = true
  vim.bo[buf].readonly = false
end

-- Header name (left of :) is red; value (right of :) is white; lines with no : are red.
local header_ns = vim.api.nvim_create_namespace("hsk_kulala_headers")

local function define_header_hls()
  vim.api.nvim_set_hl(0, "HskHttpHeaderName", { fg = "#ff5555", ctermfg = "Red", nocombine = true })
  vim.api.nvim_set_hl(0, "HskHttpHeaderValue", { fg = "#ffffff", ctermfg = "White", nocombine = true })
end
define_header_hls()
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = define_header_hls,
})

-- highlight_header_lines colors one headers block starting at start_row (0-based).
local function highlight_header_lines(buf, start_row, stop_treesitter)
  vim.api.nvim_buf_clear_namespace(buf, header_ns, 0, -1)
  -- Headers tab is markdown; stop TS so the red/white extmarks are not overwritten.
  -- All (headers_body) keeps TS so the JSON body stays highlighted.
  if stop_treesitter then
    pcall(vim.treesitter.stop, buf)
    pcall(function()
      vim.bo[buf].syntax = ""
    end)
  end
  local lines = vim.api.nvim_buf_get_lines(buf, start_row, -1, false)
  for i, line in ipairs(lines) do
    if vim.trim(line) ~= "" then
      local row = start_row + i - 1
      local colon = line:find(":", 1, true)
      local opts = { hl_mode = "combine", priority = 200 }
      if not colon then
        opts.end_col = #line
        opts.hl_group = "HskHttpHeaderName"
        vim.api.nvim_buf_set_extmark(buf, header_ns, row, 0, opts)
      else
        opts.end_col = colon
        opts.hl_group = "HskHttpHeaderName"
        vim.api.nvim_buf_set_extmark(buf, header_ns, row, 0, opts)
        if colon < #line then
          vim.api.nvim_buf_set_extmark(buf, header_ns, row, colon, {
            end_col = #line,
            hl_group = "HskHttpHeaderValue",
            hl_mode = "combine",
            priority = 200,
          })
        end
      end
    end
  end
end

-- header_block_start is the status line (`HTTP/1.1 …`), skipping the 4-line request summary.
local function header_block_start(buf)
  local start_row = 0
  local cfg = require("kulala.config").get()
  if (cfg.ui and cfg.ui.show_request_summary) or cfg.show_request_summary then
    start_row = 4
  end
  local lines = vim.api.nvim_buf_get_lines(buf, start_row, -1, false)
  local http_row
  for i, line in ipairs(lines) do
    if line:match("^HTTP/") then
      http_row = start_row + i - 1
    end
  end
  return http_row or start_row
end

-- highlight_response_headers paints the Headers tab (and the header block of All).
local function highlight_response_headers(mode)
  local buf = UI.get_kulala_buffer and UI.get_kulala_buffer()
  if not buf or buf <= 0 or not vim.api.nvim_buf_is_valid(buf) then
    return
  end
  if mode ~= "headers" and mode ~= "headers_body" then
    vim.api.nvim_buf_clear_namespace(buf, header_ns, 0, -1)
    return
  end
  highlight_header_lines(buf, header_block_start(buf), mode == "headers")
end

if not UI._hsk_ui_wrap then
  UI._hsk_ui_wrap = true
  local restore_body_views = {
    show_body = true,
    show_headers_body = true,
    open_default_view = true,
  }
  local view_mode = {
    show_body = "body",
    show_headers = "headers",
    show_headers_body = "headers_body",
    show_verbose = "verbose",
    show_stats = "stats",
    show_script_output = "script_output",
    show_report = "report",
  }
  for _, name in ipairs({
    "show_body",
    "show_headers_body",
    "show_headers",
    "show_verbose",
    "show_stats",
    "show_script_output",
    "show_report",
    "open_default_view",
    "refresh_ws_body_if_visible",
  }) do
    local orig = UI[name]
    if type(orig) == "function" then
      UI[name] = function(...)
        if restore_body_views[name] then
          restore_response_body(UI.get_current_response())
        end
        local result = orig(...)
        unlock_response_buffer()
        local mode = view_mode[name]
        if not mode then
          mode = require("kulala.config").get().default_view
        end
        -- Image view re-locks in a scheduled callback; unlock after that too.
        vim.schedule(function()
          unlock_response_buffer()
          highlight_response_headers(mode)
        end)
        return result
      end
    end
  end
end

-- Do not show inlay hints after {{base_url}}; K hover shows the concatenated value instead.
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client.name == "kulala-core-lsp" then
      pcall(vim.lsp.inlay_hint.enable, false, { bufnr = ev.buf })
    end
  end,
})

-- HTTP buffer maps (only in .http / .rest files).
-- Also attach to buffers that are already open when this file is sourced.
local function map_http_keys(buf)
  local opts = { buffer = buf, noremap = true, silent = true }
  local format_keys = { "<M-S-f>", "<Esc>[102;4u", "<C-M-f>", "<Esc>[102;7u" }

  -- Ctrl+Enter: send the request under the cursor (not all requests).
  vim.keymap.set({ "n", "i", "x" }, "<C-CR>", function()
    kulala.run()
  end, vim.tbl_extend("force", opts, { desc = "Send HTTP request" }))

  -- Ctrl+Alt+E: pick the HTTP environment (dev / qc / local).
  vim.keymap.set({ "n", "i", "x" }, "<C-M-e>", function()
    kulala.set_selected_env()
  end, vim.tbl_extend("force", opts, { desc = "Select HTTP environment" }))

  -- Shift+Alt+F: same chord as JSON jq pretty-print. Indent `?` / `&` / `# ?id=`
  -- and put two blank lines between ### requests. Ctrl+Alt+F is often swallowed
  -- by the OS (TTY) so it is only a fallback.
  for _, lhs in ipairs(format_keys) do
    vim.keymap.set({ "n", "i", "x" }, lhs, format_http_buffer, vim.tbl_extend("force", opts, { desc = "Format HTTP query lines" }))
  end

  -- Ctrl+Alt+Q: close the response split.
  vim.keymap.set({ "n", "i", "x" }, "<C-M-q>", function()
    require("kulala.ui").close_kulala_buffer()
  end, vim.tbl_extend("force", opts, { desc = "Close HTTP response split" }))

  -- Ctrl+Alt+D: show the LSP diagnostic under the cursor.
  vim.keymap.set({ "n", "i", "x" }, "<C-M-d>", function()
    vim.diagnostic.open_float(nil, { focus = true, scope = "cursor" })
  end, vim.tbl_extend("force", opts, { desc = "Show LSP diagnostic" }))

  -- ]e: jump to the next HTTP LSP error.
  vim.keymap.set("n", "]e", function()
    vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR, float = true })
  end, vim.tbl_extend("force", opts, { desc = "Next HTTP LSP error" }))

  -- [e: jump to the previous HTTP LSP error.
  vim.keymap.set("n", "[e", function()
    vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR, float = true })
  end, vim.tbl_extend("force", opts, { desc = "Previous HTTP LSP error" }))

  -- Ctrl+Alt+P: toggle focus between the request buffer and the response split.
  vim.keymap.set({ "n", "i", "x" }, "<C-M-p>", jump_to_response_pane, vim.tbl_extend("force", opts, { desc = "Toggle HTTP request/response" }))

  -- K: hover {{base_url}} to see host + catalog_path concatenated from the env file.
  vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Inspect resolved {{variable}} / request" }))

  -- Space Ri: inspect the full request after every {{var}} is filled in.
  vim.keymap.set("n", "<leader>Ri", function()
    kulala.inspect()
  end, vim.tbl_extend("force", opts, { desc = "Inspect resolved HTTP request" }))

  -- Space Rr: replay the last HTTP request.
  vim.keymap.set("n", "<leader>Rr", function()
    kulala.replay()
  end, vim.tbl_extend("force", opts, { desc = "Replay last HTTP request" }))

  -- Space Rt: toggle the response pane between body and headers.
  vim.keymap.set("n", "<leader>Rt", function()
    kulala.toggle_view()
  end, vim.tbl_extend("force", opts, { desc = "Toggle HTTP body/headers" }))

  -- Space Rf: format HTTP file (same as Shift+Alt+F).
  vim.keymap.set("n", "<leader>Rf", format_http_buffer, vim.tbl_extend("force", opts, { desc = "Format HTTP query lines" }))
end

local http_maps = vim.api.nvim_create_augroup("hsk_http_maps", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = http_maps,
  pattern = { "http", "rest" },
  callback = function(ev)
    map_http_keys(ev.buf)
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  group = http_maps,
  pattern = "kulala_ui",
  callback = function(ev)
    local opts = { buffer = ev.buf, noremap = true, silent = true, desc = "Format HTTP query lines" }
    vim.keymap.set({ "n", "i", "x" }, "<M-S-f>", format_http_buffer, opts)
    vim.keymap.set({ "n", "i", "x" }, "<Esc>[102;4u", format_http_buffer, opts)
    vim.keymap.set({ "n", "i", "x" }, "<C-M-f>", format_http_buffer, opts)
    vim.keymap.set({ "n", "i", "x" }, "<Esc>[102;7u", format_http_buffer, opts)
  end,
})
for _, buf in ipairs(vim.api.nvim_list_bufs()) do
  if vim.api.nvim_buf_is_loaded(buf) then
    local ft = vim.bo[buf].filetype
    if ft == "http" or ft == "rest" then
      map_http_keys(buf)
    end
  end
end
vim.api.nvim_create_user_command("HttpFormat", format_http_buffer, { desc = "Format HTTP query lines" })
