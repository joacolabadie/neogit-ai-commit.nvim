local M = {}

M.config = {
	model = "gpt-5-mini",
	api_key = nil,
	env_var = "OPENAI_API_KEY",
}

local SYSTEM_PROMPT = [[
Generate a SINGLE-LINE commit message in Conventional Commits format.

Rules:
- Format: "<type>: <summary>"
- type must be lowercase and one of: feat, fix, refactor, chore, docs, test, build, ci, perf, style
- summary is a clear, imperative description of what the commit does
- single line only; no body or extra lines
- do not end with a period
- if multiple small changes, separate them with semicolons in the same line
- keep under ~72 characters when possible
- do not include scope, emojis, issue refs, or code blocks

Input is the staged diff. Output ONLY the commit line.
]]

local function resolve_api_key(cfg)
	if cfg.api_key and cfg.api_key ~= "" then
		return cfg.api_key
	end

	local env_var = cfg.env_var or "OPENAI_API_KEY"
	local value = os.getenv(env_var) or (vim and vim.env and vim.env[env_var])
	if value == "" then
		return nil
	end

	return value
end

function M.generate(bufnr, opts)
	local cfg = vim.tbl_deep_extend("force", M.config, opts or {})

	local curl = require("plenary.curl")
	local git = require("neogit.lib.git")

	local api_key = resolve_api_key(cfg)
	if not api_key then
		vim.notify("[neogit-ai-commit] Missing API key.", vim.log.levels.ERROR)
		return
	end

	local diff = git.cli.diff.cached.call().stdout
	if type(diff) ~= "table" then
		vim.notify("[neogit-ai-commit] Unexpected diff type.", vim.log.levels.ERROR)
		return
	end
	if #diff == 0 then
		vim.notify("[neogit-ai-commit] No staged changes found.", vim.log.levels.WARN)
		return
	end

	diff = table.concat(diff, "\n")

	vim.notify("[neogit-ai-commit] Generating commit message...", vim.log.levels.INFO)

	local body = vim.fn.json_encode({
		model = cfg.model,
		messages = {
			{ role = "system", content = SYSTEM_PROMPT },
			{ role = "user", content = diff },
		},
	})

	local res = curl.post("https://api.openai.com/v1/chat/completions", {
		headers = {
			["Content-Type"] = "application/json",
			["Authorization"] = "Bearer " .. api_key,
		},
		body = body,
		timeout = 60000,
	})
	if res.status ~= 200 then
		vim.notify("[neogit-ai-commit] Failed to generate commit message: " .. res.body, vim.log.levels.ERROR)
		return
	end

	local data = vim.fn.json_decode(res.body)
	local message = data.choices[1].message.content or ""
	if message == "" then
		vim.notify("[neogit-ai-commit] Empty response from model.", vim.log.levels.WARN)
		return
	end

	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(message, "\n"))
	vim.notify("[neogit-ai-commit] Commit message generated!", vim.log.levels.INFO)
end

function M.setup(opts)
	M.config = vim.tbl_deep_extend("force", M.config, opts or {})

	vim.api.nvim_create_autocmd("FileType", {
		pattern = "gitcommit",
		callback = function(event)
			local bufnr = event.buf

			vim.keymap.set({ "n", "i" }, "<leader>cm", function()
				M.generate(bufnr)
			end, { buffer = bufnr })
		end,
	})
end

return M
