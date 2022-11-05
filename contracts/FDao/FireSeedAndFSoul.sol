// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./ERC2981PerTokenRoyalties.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
    external
    returns (
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
    external
    payable
    returns (
        uint256 amountToken,
        uint256 amountETH,
        uint256 liquidity
    );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}



contract FireSeed is ERC1155 ,ReentrancyGuard ,ERC2981PerTokenRoyalties, Ownable{

    IUniswapV2Router02 public uniswapV2Router;
    address public USDTAddress;
    address public BUSDAddress;
    mapping(address => bool) public isRecommender;
    mapping(address => address) public recommender;
    mapping(address => address[]) public recommenderInfo;
    

    struct accountInfo {
        bool isAccount;
        uint256 settleTime;
        uint256 incomeTime;
        uint256 incomeAmount;
        uint256 cacheAmount;
    }
    mapping(address => accountInfo) public _accountAirdrop;
    mapping(uint256 => string) private _uris;
    address[] public _accountList;



    // uint8 tokenId = 1;
    uint256 public currentSendAmount;


   constructor() ERC1155("https://bafybeiagpbpvyyk32t7n6n4pvguj75uh5hwq263b2jgamoh7bdqvf2quta.ipfs.nftstorage.link/0.json") {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Router = _uniswapV2Router;
   }


   function uri(uint256 tokenId) override public view returns(string memory) {
       return(_uris[tokenId]);
   }
    function setTokenUri(uint256 tokenId, string memory uri) public onlyOwner{
        _uris[tokenId] = uri;
    }

    function recommenderNumber(address account) external view returns (uint256) {
        return recommenderInfo[account].length;
    }

    function upclass(address usr) external view returns(address) {
        return recommender[usr];
    }

     function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC1155, ERC2981Base)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
    function setUSDTAddress(address USDT) public onlyOwner{
        USDTAddress = USDT;
    }
    function setBusdAddress(address Busd) public onlyOwner{
        BUSDAddress = Busd;
    }
       /// @notice Mint amount token of type `id` to `to`
    /// @param to the recipient of the token
    /// @param id id of the token type to mint
    /// @param amount amount of the token type to mint
    /// @param royaltyRecipient the recipient for royalties (if royaltyValue > 0)
    /// @param royaltyValue the royalties asked for (EIP2981)
    function mintWithUSDT(
        address to,
        uint256 id,
        uint256 amount,
        address royaltyRecipient,
        uint256 royaltyValue
    ) external {
        // IERC20(uniswapV2Router.WETH()).transfer(owner(), 1);
        IERC20(USDTAddress).transfer(owner(),100*10**18 );
        _mint(to, id, amount, '');

        if (royaltyValue > 0) {
            _setTokenRoyalty(id, royaltyRecipient, royaltyValue);
        }
    }

    function mintWithBUSD(
        address to,
        uint256 id,
        uint256 amount,
        address royaltyRecipient,
        uint256 royaltyValue
    ) external {
        // IERC20(uniswapV2Router.WETH()).transfer(owner(), 1);
        IERC20(BUSDAddress).transfer(owner(),100*10**18 );
        _mint(to, id, amount, '');

        if (royaltyValue > 0) {
            _setTokenRoyalty(id, royaltyRecipient, royaltyValue);
        }
    }

 function mintWithBNB(
        address to,
        uint256 id,
        uint256 amount,
        address royaltyRecipient,
        uint256 royaltyValue
    ) external {
        // IERC20(uniswapV2Router.WETH()).transfer(owner(), 1);

        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = USDTAddress;//mainnet
    //    path[1] = address(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684);//testnet
        
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            //此处需要算出多少BNB兑换100U
            1,
            0,
            path,
            owner(),
            block.timestamp
        );
        _mint(to, id, amount, '');

        if (royaltyValue > 0) {
            _setTokenRoyalty(id, royaltyRecipient, royaltyValue);
        }
    }
    


    /// @notice Mint several tokens at once
    /// @param to the recipient of the token
    /// @param ids array of ids of the token types to mint
    /// @param amounts array of amount to mint for each token type
    /// @param royaltyRecipients an array of recipients for royalties (if royaltyValues[i] > 0)
    /// @param royaltyValues an array of royalties asked for (EIP2981)
    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        address[] memory royaltyRecipients,
        uint256[] memory royaltyValues
    ) external {
        require(
            ids.length == royaltyRecipients.length &&
                ids.length == royaltyValues.length,
            'ERC1155: Arrays length mismatch'
        );

        _mintBatch(to, ids, amounts, '');

        for (uint256 i; i < ids.length; i++) {
            if (royaltyValues[i] > 0) {
                _setTokenRoyalty(
                    ids[i],
                    royaltyRecipients[i],
                    royaltyValues[i]
                );
            }
        }
    }


   function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner nor approved"
        );
            require(from != address(0));
            require(to != address(0));

         if (recommender[to] == address(0) &&  recommender[from] != to && !isRecommender[to]) {
             recommender[to] = from;
             recommenderInfo[from].push(to);
             isRecommender[to] = true;
         }
         accountInfo storage info = _accountAirdrop[to];
         if (!info.isAccount) {
             _accountList.push(to);
             info.isAccount = true;
         }

        _safeTransferFrom(from, to, id, amount, data);
    }

    /**
     * @dev See {IERC1155-safeBatchTransferFrom}.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner nor approved"
        );
            require(from != address(0));
            require(to != address(0));

         if (recommender[to] == address(0) &&  recommender[from] != to && !isRecommender[to]) {
             recommender[to] = from;
             recommenderInfo[from].push(to);
             isRecommender[to] = true;
         }
         accountInfo storage info = _accountAirdrop[to];
         if (!info.isAccount) {
             _accountList.push(to);
             info.isAccount = true;
         }

        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }



    function burnFireSeed(address _account, uint256 _id, uint256 _value) public  {
        _burn(_account,_id,_value);
    }


}

interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}


    interface IFireSeed {
        function upclass(address usr) external view returns(address);
    }

   contract FireSoul is ERC721,ReentrancyGuard,Ownable{

        // bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
        address public FireSeedAddress;
        address public FLAME;
        uint256 public FID;
        address[] public sbtAddress;
        FireSeed fireseed;
       address public _owner;
       bool public status;
       address public pauseControlAddress;

       mapping(address => uint256) public awardFlame;
       constructor(FireSeed _fireseed) ERC721("FireSoul", "FireSoul"){

        _owner = msg.sender;
        fireseed = _fireseed;

       }
       function setPauseControlAddress(address _pauseControlAddress) public onlyOwner {
           pauseControlAddress = _pauseControlAddress;
       }
       function setStatus() external {
           require(msg.sender == pauseControlAddress,"address is error");
           status = !status;
       }


    function burnToMint() external {
        require(!status, "status is error");
        require(fireseed.balanceOf(msg.sender,1) != 0 );
        fireseed.burnFireSeed(msg.sender, 1,1);
        _mint(msg.sender, FID);
        if(IFireSeed(FireSeedAddress).upclass(msg.sender) != address(0) && IFireSeed(FireSeedAddress).upclass(IFireSeed(FireSeedAddress).upclass(msg.sender)) != address(0)){
        IERC20(FLAME).transfer(msg.sender, 10000*10**18);
        IERC20(FLAME).transfer(IFireSeed(FireSeedAddress).upclass(msg.sender), 5000*10**18);
        IERC20(FLAME).transfer(IFireSeed(FireSeedAddress).upclass(IFireSeed(FireSeedAddress).upclass(msg.sender)),2000*10**18);
        awardFlame[msg.sender] = 10000*10**18;
        awardFlame[IFireSeed(FireSeedAddress).upclass(msg.sender)] = 5000*10**18;
        awardFlame[IFireSeed(FireSeedAddress).upclass(IFireSeed(FireSeedAddress).upclass(msg.sender))] = 2000*10**18;
        }
        FID++;
    }
    function setFlameAddress(address _FLAME) public onlyOwner{
        FLAME = _FLAME;
    }
    function setSBTAddress(address sbt) public  onlyOwner{
        for(uint256 i = 0; i < sbtAddress.length; i++){
            sbtAddress[i] = sbt;
        }
    }
    //设置查上一级的地址，用于邀请关系
    function setFireSeedAddress(address _FireSeedAddress) public onlyOwner{
            FireSeedAddress = _FireSeedAddress;
    }

      /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(from == msg.sender && to == msg.sender ,"the FID not to transfer others" );
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        require(from == msg.sender && to == msg.sender ,"the FID not to transfer others" );
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual override {
        require(from == msg.sender && to == msg.sender ,"the FID not to transfer others" );
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner nor approved");
        _safeTransfer(from, to, tokenId, data);
    }

    // function safeTransferFrom(address from, address to, uint256 tokenId) public override {

    //     require(from == msg.sender && to == msg.sender ,"the FID not to transfer others" );
    //     _transfer(from, to, tokenId);

    // }
}