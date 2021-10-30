echo ">>> local network deploy <<<"
echo "start network"
eval dfx start --background --clean
echo "finished"
echo "deploy the project"
eval dfx canister create bucket
eval dfx build
echo "build the canister using compacting gc by default"
eval dfx canister install --argument '(principal "")'
echo "deploy finished"