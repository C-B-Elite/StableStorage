import Principal "mo:base/Principal";
shared(msg) actor class test() = this{

    private stable var owner = Principal.fromText("")

    private stable var canister_id = Principal.fromText("aaaaa-aa");



};