-- https://github.com/okuuva/auto-save.nvim

-- Autocommand for printing the autosaved message
local group = vim.api.nvim_create_augroup("autosave", {})
vim.api.nvim_create_autocmd("User", {
  pattern = "AutoSaveWritePost",
  group = group,
  callback = function(opts)
    if opts.data.saved_buffer ~= nil then
      -- print("AutoSaved at " .. vim.fn.strftime("%H:%M:%S"))
      print("AutoSaved")
    end
  end,
})

local visual_event_group = vim.api.nvim_create_augroup("visual_event", { clear = true })

vim.api.nvim_create_autocmd("ModeChanged", {
  group = visual_event_group,
  pattern = { "*:[vV\x16]*" },
  callback = function()
    vim.api.nvim_exec_autocmds("User", { pattern = "VisualEnter" })
    -- print("VisualEnter")
  end,
})

vim.api.nvim_create_autocmd("ModeChanged", {
  group = visual_event_group,
  pattern = { "[vV\x16]*:*" },
  callback = function()
    vim.api.nvim_exec_autocmds("User", { pattern = "VisualLeave" })
    -- print("VisualLeave")
  end,
})

-- Override the `flash.jump` function to detect start and end
-- Defer loading until flash is available
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyLoad",
  callback = function(event)
    if event.data == "flash.nvim" then
      local flash = require("flash")
      local original_jump = flash.jump

      flash.jump = function(opts)
        vim.api.nvim_exec_autocmds("User", { pattern = "FlashJumpStart" })
        -- print("flash.nvim enter")

        original_jump(opts)

        vim.api.nvim_exec_autocmds("User", { pattern = "FlashJumpEnd" })
        -- print("flash.nvim leave")
      end
    end
  end,
})

-- Disable auto-save when entering a snacks_input buffer
vim.api.nvim_create_autocmd("FileType", {
  pattern = "snacks_input",
  group = group,
  callback = function()
    vim.api.nvim_exec_autocmds("User", { pattern = "SnacksInputEnter" })
    -- print("snacks input enter")
  end,
})

-- Re-enable auto-save when leaving that buffer
vim.api.nvim_create_autocmd("BufLeave", {
  group = group,
  pattern = "*", -- check all buffers
  callback = function(opts)
    local ft = vim.bo[opts.buf].filetype
    if ft == "snacks_input" then
      vim.api.nvim_exec_autocmds("User", { pattern = "SnacksInputLeave" })
      -- print("snacks input leave")
    end
  end,
})

-- Disable auto-save when entering a snacks_input buffer
vim.api.nvim_create_autocmd("FileType", {
  pattern = "snacks_picker_input",
  group = group,
  callback = function()
    vim.api.nvim_exec_autocmds("User", { pattern = "SnacksPickerInputEnter" })
    -- print("snacks picker input enter")
  end,
})

-- Re-enable auto-save when leaving that buffer
vim.api.nvim_create_autocmd("BufLeave", {
  group = group,
  pattern = "*", -- check all buffers
  callback = function(opts)
    local ft = vim.bo[opts.buf].filetype
    if ft == "snacks_picker_input" then
      vim.api.nvim_exec_autocmds("User", { pattern = "SnacksPickerInputLeave" })
      -- print("snacks picker input leave")
    end
  end,
})

return {
  {
    "okuuva/auto-save.nvim",
    enabled = true,
    cmd = "ASToggle", -- optional for lazy loading on command
    event = { "InsertLeave", "TextChanged" }, -- optional for lazy loading on trigger events
    opts = {
      enabled = true, -- start auto-save when the plugin is loaded (i.e. when your package manager loads it)
      trigger_events = { -- See :h events
        -- -- vim events that trigger an immediate save
        immediate_save = { "BufLeave", "FocusLost", "QuitPre", "VimSuspend" }, -- vim events that trigger an immediate save
        -- vim events that trigger a deferred save (saves after `debounce_delay`)
        defer_save = {
          "InsertLeave",
          "TextChanged",
          { "User", pattern = "VisualLeave" },
          { "User", pattern = "FlashJumpEnd" },
          { "User", pattern = "SnacksInputLeave" },
          { "User", pattern = "SnacksPickerInputLeave" },
        },
        cancel_deferred_save = {
          "InsertEnter",
          { "User", pattern = "VisualEnter" },
          { "User", pattern = "FlashJumpStart" },
          { "User", pattern = "SnacksInputEnter" },
          { "User", pattern = "SnacksPickerInputEnter" },
        },
      },
      -- function that takes the buffer handle and determines whether to save the current buffer or not
      -- return true: if buffer is ok to be saved
      -- return false: if it's not ok to be saved
      -- if set to `nil` then no specific condition is applied
      condition = function(buf)
        -- Do not save when I'm in insert mode
        local mode = vim.fn.mode()
        if mode == "i" then
          return false
        end

        -- Skip autosave if you're in an active snippet
        if require("luasnip").in_snippet() then
          return false
        end

        return true
      end,
      write_all_buffers = false, -- write all buffers when the current one meets `condition`
      noautocmd = false,
      lockmarks = false, -- lock marks when saving, see `:h lockmarks` for more details
      debounce_delay = 2000,
      debug = false,
    },
  },
}
