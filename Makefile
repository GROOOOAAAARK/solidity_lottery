PHONY: build deploy safe-deploy source-dev source-test source-prod test

# TODO: Create deployment script using a ledger

source-test:
	source .test.env

test:
	make source-test && forge test

test-gas:
	make test --gas-report

test-deep:
	make test --vvv

test-full:
	make test --gas-report --vvv

test-watch:
	make source-dev && forge test --watch