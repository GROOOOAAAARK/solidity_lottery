.PHONY: build deploy safe-deploy source-dev source-test source-prod test

# TODO: Create deployment script using a ledger

source-test: # Source dev file and env
	export $(xargs < $(cat .env.dev | grep -v '^#'))

deploy: # Deploy contract
	forge create ./src/Lottery.sol:Lottery --rpc-url $RPC_URL --account deployer --constructor-args $WEI_TICKET_PRICE --constructor-args $MAX_TICKET_NB

test: # Run all test
	make source-test && forge test

test-gas: # Run all tests with gas report at the end
	make test --gas-report

test-deep: # Run all tests with high verbose level
	make test --vvv

test-full: # Run all test with gas report and high verbose level
	make test --gas-report --vvv

test-watch: # Run tests in watch mode
	make source-test && forge test --watch