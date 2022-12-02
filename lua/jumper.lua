local Path = require("plenary.path")
local log = require("log").log

local M = {}

JumperConfig = {}
JumperPaths = {}

local defaults = {
	save_file = "jumper.json",
}

local function tbl_has_entry(table, entry)
	for _, v in pairs(table) do
		if string.lower(v.path) == string.lower(entry) then
			return true
		end
	end

	return false
end

local function get_input_path(default)
	local input_path = vim.fn.input("[Jumper] Path: ", default, "file")

	if input_path == "" then
		return nil
	end

	-- strip trailing slashes and spaces
	input_path = string.gsub(input_path, "%s*$", "")
	input_path = string.gsub(input_path, "/*$", "")

	return Path:new(input_path)
end

local function get_input_name(default)
	local input_name = vim.fn.input({
		prompt = "[Jumper] Name (blank to use path as name): ",
		default = default,
		cancelreturn = "::CANCEL::",
	})

	if input_name == "::CANCEL::" then
		return nil
	end

	return input_name
end

function M.add()
	local buf = vim.fn.expand("%:p")
	local path = {}
	local input_path = get_input_path(buf ~= "" and buf or vim.fn.getcwd())

	if input_path == nil then
		return
	end

	if tbl_has_entry(JumperPaths, input_path.filename) then
		log.error("[Jumper] This path already exists")
		return
	end

	if not input_path:exists() then
		log.error("[Jumper] This path does not exist")
		return
	end

	local input_name = get_input_name()

	if input_name == nil then
		return
	end

	if input_name == "" then
		input_name = input_path.filename
	end

	path.path = input_path.filename
	path.name = input_name

	table.insert(JumperPaths, path)
	M:save_paths()
end

function M.remove(path)
	for i, v in pairs(JumperPaths) do
		if v.path == path then
			table.remove(JumperPaths, i)
			M:save_paths()
			log.info(string.format("[Jumper] %s has been deleted", v.name))
			return
		end
	end

	log.error(
		string.format("[Jumper] unable to remove path %s, doesn't exist!", path)
	)
end

function M.rename(path)
	for _, v in pairs(JumperPaths) do
		if v.path == path then
			return
		end
	end

	log.error(
		string.format("[Jumper] unable to rename path %s, doesn't exist!", path)
	)
end

function M.edit(path)
	for _, v in pairs(JumperPaths) do
		if v.path == path.path then
			local input_path = get_input_path(v.path)

			if input_path == nil then
				return
			end

			if not input_path:exists() then
				log.error("[Jumper] This path does not exist")
				return
			end

			local input_name = get_input_name(v.name)

			if input_name == nil then
				return
			end

			if input_name == "" then
				input_name = v.path
			end

			v.path = input_path.filename
			v.name = input_name
			M:save_paths()
			return
		end
	end

	log.error(
		string.format("[Jumper] unable to edit path %s, doesn't exist!", path)
	)
end

function M.save_paths()
	JumperConfig.path:write(vim.json.encode(JumperPaths), "w", 420)
end

function M.load_paths()
	return vim.json.decode(JumperConfig.path:read())
end

local function get_save_path()
	return Path:new(vim.fn.stdpath("config") .. "/" .. JumperConfig.save_file)
end

function M.setup(opts)
	opts = opts or {}
	JumperConfig = vim.tbl_deep_extend("force", defaults, opts)
	JumperConfig.path = get_save_path()

	if not JumperConfig.path:exists() then
		M.save_paths()
	end

	JumperPaths = M.load_paths()
end

return M
