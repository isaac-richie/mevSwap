pragma solidity =0.8.0;


//setting up the required interface for the mev bot.
interface ERC20 {
    function transfer(address _to, uint256 _amount) external;
    function balanceOf(address _to) external returns (uint256);
}

interface WETH{
    function deposit () external payable;//depositing eth to weth for swapping
}

interface pair {
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata) external;//this is the pair contract
}

 contract mevSwap {
    //setting the the variable
    address public owner;
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    constructor (address _weth) payable {
        require(msg.value > 0, "send eth only to be used for weth swaps");
        owner = msg.sender;//only owner of contract can set
        WETH(_weth).deposit{value: msg.value}();  
        //it converts eth to wrapped eth and it holds the funds in the smart contract
    }

    //setup a recovery fuction

    function recoverTokens(address _token) external onlyOwner {
        uint256 balance = ERC20(_token).balanceOf(address(this));
        ERC20(_token).transfer(owner, balance);
    }
    
    //this transfer the eth back to the owner
    function recoverETH () external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    //the swap function..this sends token to the swap pair contract
    // this execute the swap function

    function swap(address _token, uint256 _transferAmount, address _pair, uint256 _reserve0Out, uint256 _reserve1Out) external onlyOwner{
        ERC20(_token).transfer(_pair, _transferAmount);
        pair(_pair).swap(_reserve0Out, _reserve1Out, address(this), "");
    }


 }