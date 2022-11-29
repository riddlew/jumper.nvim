main: fmt lint

fmt:
	@echo "Formatting (stylua)..."
	@stylua lua/ --config-path=.stylua.toml

lint:
	@echo "Linting (luacheck)..."
	@luacheck lua/ --globals vim
