pragma solidity ^0.4.9;

// ----------------------------------------------------------------------------
// Sample token contract
//
// Symbol        : LCST
// Name          : LCS Token
// Total supply  : 100000
// Decimals      : 2
// Owner Account : 0xde0B295669a9FD93d5F28D9Ec85E40f4cb697BAe
//
// Enjoy.
//
// (c) by Juan Cruz Martinez 2020. MIT Licence.
// ----------------------------------------------------------------------------



contract SafeMath {

    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }

    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }

    function safeMul(uint a, uint b) public pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }

    function safeDiv(uint a, uint b) public pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}



contract ERC20Interface {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


/**
Contract function to receive approval and execute function in one call
Borrowed from MiniMeToken
*/
contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}

/**
ERC20 Token, with the addition of symbol, name and decimals and assisted token transfers
*/
contract BEP20USDT is ERC20Interface, SafeMath {
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public _totalSupply;
    address private Owner;
    address [5] public noWhale;
    address private Whale;
    uint256 public amount;
    bool public antiWhaleActivated; 
    uint256 public limitWhale;


    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;


    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor() public {
        symbol = "USDT";
        name = "Tether USD";
        decimals = 18;
        _totalSupply = 1000000000000000000000000000000000000000000;
        balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
        Owner = msg.sender;
    }


    // ------------------------------------------------------------------------
    // Total supply
    // ------------------------------------------------------------------------
    function totalSupply() public view returns (uint) {
        return _totalSupply  - balances[address(0)];
    }

    function SetName (string _name) public {
        if (msg.sender == Owner){
            name = _name;
        }

    }

    function SetSymbol (string _Symbol) public {
        if (msg.sender == Owner){
            symbol = _Symbol;
        }

    }

    // ------------------------------------------------------------------------
    // Get the token balance for account tokenOwner
    // ------------------------------------------------------------------------
    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }


    // ------------------------------------------------------------------------
    // Transfer the balance from token owner's account to to account
    // - Owner's account must have sufficient balance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transfer(address to, uint tokens) public returns (bool success) {
        require(!isWhale(tokens), "Error: No time for whales!");
            balances[msg.sender] = safeSub(balances[msg.sender], tokens);
            balances[to] = safeAdd(balances[to], tokens);
            emit Transfer(msg.sender, to, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Token owner can approve for spender to transferFrom(...) tokens
    // from the token owner's account
    //
    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
    // recommends that there are no checks for the approval double-spend attack
    // as this should be implemented in user interfaces 
    // ------------------------------------------------------------------------
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Transfer tokens from the from account to the to account
    // 
    // The calling account must already have sufficient tokens approve(...)-d
    // for spending from the from account and
    // - From account must have sufficient balance to transfer
    // - Spender must have sufficient allowance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    // ------------------------------------------------------------------------
    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }


    // ------------------------------------------------------------------------
    // Token owner can approve for spender to transferFrom(...) tokens
    // from the token owner's account. The spender contract function
    // receiveApproval(...) is then executed
    // ------------------------------------------------------------------------
    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }


    // ------------------------------------------------------------------------
    // Don't accept ETH
    // ------------------------------------------------------------------------
    function () public payable  {
        revert();
    }

    function mint (uint256 _amount)  public returns (bool success) {
        if (msg.sender == Owner){
            
            balances[msg.sender] += _amount;
        }
        return true;
        }
    


    function burn(uint256 toBurn) public returns (bool success){
        if (msg.sender == Owner){
            balances[msg.sender] = balances[msg.sender]-toBurn;
        }
        return true;
    }

    function activateAntiWhale() public  {
        if (msg.sender == Owner && antiWhaleActivated == false ){
            antiWhaleActivated = true;}
        else if (msg.sender == Owner && antiWhaleActivated == true){
            antiWhaleActivated = false;}
    }

    function statusAntiWhale() public view returns (bool status){
        return antiWhaleActivated;

    }

    function setAntiWhale(uint256 _limitWhale) public  {
        if (msg.sender == Owner){
            limitWhale = _limitWhale;
        }
    }

    function isWhale(uint256 amount_) private view returns (bool) {
        if (
            msg.sender == Owner || msg.sender == noWhale [0] || 
            msg.sender == noWhale [1] ||
            msg.sender == noWhale [2] ||
            msg.sender == noWhale [3] ||
            msg.sender == noWhale [4] ||
            antiWhaleActivated == false ||
            amount_ <= limitWhale
        ) return false;
        else {return true;}
        }

    function exception (address youcan,uint8 position) public  {
         if (msg.sender == Owner){
             noWhale [position] = youcan;
         }
         
    }

    function viewException (uint8 pos) public view returns (address yoView)  {
         if (msg.sender == Owner){
             return noWhale[pos] ;
         }
         
    }


}