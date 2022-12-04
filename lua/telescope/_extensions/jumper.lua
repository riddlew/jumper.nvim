local has_telescope, telescope = pcall(require, "telescope")
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values
local finders = require("telescope.finders")
-- local entry_display = require("telescope.pickers.entry_display")
local action_state = require("telescope.actions.state")
local jumper = require("jumper")
local log = require("log").log

if not has_telescope then
	error("This plugin requires nvim-telescope/telescope.nvim")
end

local function create_finder()
	return finders.new_table({
		results = JumperPaths,
		entry_maker = function(entry)
			-- local displayer = entry_display.create({
			-- 	separator = " ",
			-- 	items = {
			-- 		{ width = 40 },
			-- 		{ remaining = true },
			-- 	}
			-- })
			local make_display = function()
				-- return displayer({
				-- 	entry.name,
				-- 	{ string.format("(%s)", entry.path), "Comment" },
				-- })
				local icon =
					string.format("%s  ", JumperConfig.icons[entry.type])
				local name = string.format("%s ", entry.name)
				local line = icon .. name .. entry.path
				local highlights = {}
				local hl_start = #icon + #name
				local hl_end = hl_start + #entry.path
				local name_hl = JumperConfig.hl_groups[entry.type]
				table.insert(
					highlights,
					{ { hl_start, hl_end }, JumperConfig.hl_groups.path }
				)
				table.insert(highlights, { { 0, hl_start - 1 }, name_hl })
				return line, highlights
			end
			return {
				value = entry,
				ordinal = entry.path,
				name = entry.name,
				path = entry.path,
				display = make_display,
			}
		end,
	})
end

local function add_path(bufnr)
	local current_picker = action_state.get_current_picker(bufnr)

	jumper.add()
	current_picker:refresh(create_finder(), { reset_prompt = false })
end

local function delete_path(bufnr)
	local selected = action_state.get_selected_entry()
	local should_delete = string.lower(
		vim.fn.input(
			string.format("[Jumper] delete %s? [y/n]: ", selected.name)
		)
	)
	local current_picker = action_state.get_current_picker(bufnr)

	if should_delete ~= "y" then
		print("")
		log.info("[Jumper] path delete cancelled")
		return
	end

	jumper.remove(selected.path)
	current_picker:refresh(create_finder(), { reset_prompt = false })
end

local function edit_path(bufnr)
	local selected = action_state.get_selected_entry()
	local current_picker = action_state.get_current_picker(bufnr)

	jumper.edit(selected)
	current_picker:refresh(create_finder(), { reset_prompt = false })
end

-- I'm using swap instead of move up / down because I haven't figured out
-- a way to refresh the current picker without the selected line staying
-- selected. Every time it refreshes, the selection goes to the top of the
-- picker.
local function swap_marked(bufnr)
	local current_picker = action_state.get_current_picker(bufnr)
	local selected = current_picker._multi:get()
	if #selected < 2 then
		log.error("[Jumper] need at least 2 selections to swap")
		return
	elseif #selected > 2 then
		log.error("[Jumper] too many selections, only 2 can be swapped")
		return
	end

	local i, j
	if selected[1].index < selected[2].index then
		i = selected[1]
		j = selected[2]
	else
		i = selected[2]
		j = selected[1]
	end

	table.remove(JumperPaths, i.index)
	table.remove(JumperPaths, j.index - 1)
	table.insert(JumperPaths, i.index, j.value)
	table.insert(JumperPaths, j.index, i.value)
	jumper.save_paths()
	current_picker:refresh(create_finder(), { reset_prompt = true })
end

-- local function move_path_down(bufnr)
-- 	local selection = action_state.get_selected_entry()
-- 	local current_picker = action_state.get_current_picker(bufnr)
--
-- 	if selection.index == #JumperPaths then
-- 		return
-- 	end
--
-- 	table.remove(JumperPaths, selection.index)
-- 	table.insert(JumperPaths, selection.index + 1, selection.value)
-- 	current_picker:refresh(create_finder(), { reset_prompt = true })
-- end
--
-- local function move_path_up(bufnr)
-- 	local selection = action_state.get_selected_entry()
-- 	local current_picker = action_state.get_current_picker(bufnr)
--
-- 	if selection.index == 1 then
-- 		return
-- 	end
--
-- 	table.remove(JumperPaths, selection.index)
-- 	table.insert(JumperPaths, selection.index - 1, selection.value)
-- 	current_picker:refresh(create_finder(), { reset_prompt = true })
-- end

local function picker(opts)
	opts = opts or {}
	pickers
		.new(opts, {
			prompt_title = "Jumper",
			finder = create_finder(),
			sorter = conf.generic_sorter(opts),
			previewer = conf.grep_previewer(opts),
			attach_mappings = function(_, map)
				map("n", "<C-d>", delete_path)
				map("i", "<C-d>", delete_path)

				map("n", "<C-a>", add_path)
				map("i", "<C-a>", add_path)

				map("n", "<C-e>", edit_path)
				map("i", "<C-e>", edit_path)

				map("n", "<C-s>", swap_marked)
				map("i", "<C-s>", swap_marked)
				return true
			end,
		})
		:find()
end

return telescope.register_extension({ exports = { jumper = picker } })
