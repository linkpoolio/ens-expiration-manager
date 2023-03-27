-include .env

install:
	forge install --no-git Openzeppelin/openzeppelin-contracts smartcontractkit/chainlink ensdomains/ens-contracts

deploy:
	forge script script/ENSExpirationManager.s.sol:ENSExpirationManagerScript --rpc-url ${RPC_URL} --etherscan-api-key ${EXPLORER_KEY} --broadcast --verify -vvvv

# test
test:
	forge test -vvvvvvv
# docs
gen-docs:
	forge doc

run-doc-server:
	forge doc --serve --port 4000

clean:
	rm -rf lib
