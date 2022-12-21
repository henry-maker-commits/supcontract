// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IERC20 {
    function balanceOf(address owner) external view returns (uint);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function totalSupply() external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

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



contract FireLock {
    uint256 index;

    IUniswapV2Router02 public uniswapV2Router;


    struct LockDetail{
        string LockTitle;
        bool isNotTerminate;
        uint256 ddl;
        uint256 startTime;
        uint256 amount;
        uint256 unlockCycle;
        uint256 unlockRound;
        address token;
        uint256 cliffPeriod;
    }

    struct groupLockDetail{
        string LockTitle;
        uint256 ddl;
        uint256 startTime;
        address admin;
        uint256 amount;
        uint256 unlockCycle;
        uint256 unlockRound;
        uint256[] rate;
        address token;
        address[] mumber;
        bool isNotchange;
        bool isNotTerminate;

    }
    address public feeTo;
    uint256 public fee;
    mapping(address => address[]) tokenAddress;
    mapping(address => LockDetail[]) public ownerLockDetail;
    mapping(uint256 => address[]) public groupMumber;
    mapping(uint256 => address[]) groupTokenAddress;
    mapping(address => groupLockDetail[]) public adminGropLockDetail;
    mapping(address => address) adminAndOwner;
    bool alreadyChange;
    mapping(address => bool) isChangedOwner;
    mapping(address => uint256[]) public UsergroupLockNum;

    constructor() {
    IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
    uniswapV2Router = _uniswapV2Router;
    }


    // function setFeeTo(address payable _feeTo) public onlyOwner {
    //     feeTo = _feeTo;
    // }
    // function setFee(uint256 _fee) public onlyOwner{
    //     fee = _fee;
    // }

    function lock(address _token,uint256 _unlockCycle,uint256 _unlockRound ,uint256 _amount,uint256 _cliffPeriod ,string memory _titile , bool _Terminate) public payable  {
        require(block.timestamp + _unlockCycle * _unlockRound * 86400 > block.timestamp,"ddl should be bigger than ddl current time");
        require(_amount > 0 ,"token amount should be bigger than zero");
        
        address owner = msg.sender;
        LockDetail memory lockinfo = LockDetail({
            LockTitle:_titile,
            ddl:block.timestamp+ _unlockCycle * _unlockRound * 86400 + _cliffPeriod *86400,
            startTime : block.timestamp,
            amount:_amount,
            unlockCycle: _unlockCycle,
            unlockRound:_unlockRound,
            token:_token,
            cliffPeriod:block.timestamp +_cliffPeriod *86400,
            isNotTerminate:_Terminate
        });
        tokenAddress[msg.sender].push(_token);
        ownerLockDetail[msg.sender].push(lockinfo);
        IERC20(_token).transferFrom(owner,address(this),_amount);
    }
    function lockOthers(address _token,address _to,uint256 _unlockCycle,uint256 _unlockRound ,uint256 _amount,uint256 _cliffPeriod ,string memory _titile , bool _Terminate) public {
        require(block.timestamp + _unlockCycle * _unlockRound * 86400 > block.timestamp,"ddl should be bigger than ddl current time");
        require(_amount > 0 ,"token amount should be bigger than zero");
        
        address owner = msg.sender;
        LockDetail memory lockinfo = LockDetail({
            LockTitle:_titile,
            ddl:block.timestamp+ _unlockCycle * _unlockRound * 86400 + _cliffPeriod *86400,
            startTime : block.timestamp,
            amount:_amount,
            unlockCycle: _unlockCycle,
            unlockRound:_unlockRound,
            token:_token,
            cliffPeriod:block.timestamp +_cliffPeriod *86400,
            isNotTerminate:_Terminate
        });

        tokenAddress[_to].push(_token);
        ownerLockDetail[_to].push(lockinfo);
        IERC20(_token).transferFrom(owner,address(this),_amount);
    }
      function groupLock(address _token, uint256 _unlockCycle,uint256 _unlockRound ,uint256 _amount , address[] memory _to, uint256[] memory _rate,string memory _titile,uint256 _cliffPeriod,bool _isNotTerminate) public {
      require(block.timestamp + _unlockCycle * _unlockRound * 86400 > block.timestamp,"ddl should be bigger than ddl current time");
        require(_amount > 0 ,"token amount should be bigger than zero");
        uint LockId; 
        groupLockDetail memory _groupLockDetail = groupLockDetail({
        LockTitle:_titile,
        ddl:block.timestamp+ _unlockCycle * _unlockRound * 86400 + _cliffPeriod *86400,
        startTime:block.timestamp,
        admin:msg.sender,
        amount:_amount,
        unlockCycle:_unlockCycle,
        unlockRound:_unlockRound,
        rate : _rate,
        token:_token,
        mumber:_to,
        isNotchange:false,
        isNotTerminate:_isNotTerminate
        });
        groupTokenAddress[LockId].push(_token);
        UsergroupLockNum[msg.sender].push(LockId);
        adminGropLockDetail[msg.sender].push(_groupLockDetail);
        groupMumber[LockId] = _to;
        IERC20(_token).transferFrom(msg.sender,address(this),_amount);
        LockId++;
    }
     function groupLock_true(address _token, uint256 _unlockCycle,uint256 _unlockRound ,uint256 _amount , address[] memory _to,uint256[] memory _rate, string memory _titile,uint256 _cliffPeriod,bool _isNotTerminate) public {
        require(block.timestamp + _unlockCycle * _unlockRound * 86400 > block.timestamp,"ddl should be bigger than ddl current time");
        require(_amount > 0 ,"token amount should be bigger than zero");
        uint LockId; 
        groupLockDetail memory _groupLockDetail = groupLockDetail({
        LockTitle:_titile,
        ddl:block.timestamp+ _unlockCycle * _unlockRound * 86400 + _cliffPeriod *86400,
        startTime:block.timestamp,
        admin:msg.sender,
        amount:_amount,
        unlockCycle:_unlockCycle,
        unlockRound:_unlockRound,
        rate : _rate,
        token:_token,
        mumber:_to,
        isNotchange:false,
        isNotTerminate:_isNotTerminate
        });
        groupTokenAddress[LockId].push(_token);
        UsergroupLockNum[msg.sender].push(LockId);
        adminGropLockDetail[msg.sender].push(_groupLockDetail);
        groupMumber[LockId] = _to;
        IERC20(_token).transferFrom(msg.sender,address(this),_amount);
        LockId++;
    }
    function TerminateLock(uint256 _lockId,address token) public {
        require(ownerLockDetail[msg.sender][_lockId].isNotTerminate,"!isNotTerminate");
        IERC20(token).transfer(msg.sender , ownerLockDetail[msg.sender][_lockId].amount);
    }
  function TerminateLockForGroupLock(uint256 _lockId,address token) public {
        require(adminGropLockDetail[msg.sender][_lockId].isNotTerminate,"!isNotTerminate");
        IERC20(token).transfer(msg.sender , adminGropLockDetail[msg.sender][_lockId].amount);
    }

    function unlock(address _token) public{
        uint len = ownerLockDetail[msg.sender].length;
        for(uint i = 0; i < len - 1; i++ ){
            if(ownerLockDetail[msg.sender][i].token == _token){
                index = i;
            }
        }
        require(block.timestamp >= ownerLockDetail[msg.sender][index].cliffPeriod,"current time should be bigger than cliffPeriod");
        uint amountOfUser = ownerLockDetail[msg.sender][index].amount;
        uint amount = IERC20(_token).balanceOf(address(this));
        if(amount > amountOfUser){
        IERC20(_token).transfer(msg.sender, (amountOfUser/(ownerLockDetail[msg.sender][index].unlockCycle*ownerLockDetail[msg.sender][index].unlockRound))*(block.timestamp-ownerLockDetail[msg.sender][index].startTime)/86400);
        }else{revert();}
    }

    function groupUnLock(address _token) public {
       uint len = adminGropLockDetail[msg.sender].length;
        for(uint i = 0; i < len - 1; i++ ){
            if(adminGropLockDetail[msg.sender][i].token == _token){
                index = i;
            }
        }
        require(block.timestamp >= adminGropLockDetail[msg.sender][index].ddl,"current time should be bigger than deadlineTime");
        uint amountOfUser = adminGropLockDetail[msg.sender][index].amount;
        uint amount = IERC20(_token).balanceOf(address(this));
        if(amount > amountOfUser){
            for(uint i = 0 ; i < adminGropLockDetail[msg.sender][index].mumber.length;i++){
            IERC20(_token).transfer(adminGropLockDetail[msg.sender][index].mumber[i], (amountOfUser*adminGropLockDetail[msg.sender][index].rate[i]/100)/(adminGropLockDetail[msg.sender][index].unlockRound*adminGropLockDetail[msg.sender][index].unlockRound)*(block.timestamp - adminGropLockDetail[msg.sender][index].startTime)/86400);
            }
        }else{revert();}
    }
    function changeLockAdmin(address  _to, uint _index) public {
        require(msg.sender == adminGropLockDetail[msg.sender][index].admin,"you are not admin");
        require(!isChangedOwner[_to], "you already change");
        require(adminGropLockDetail[msg.sender][index].isNotchange ,"you can't turn on isNotchange when you create ");
        adminGropLockDetail[msg.sender][_index].admin = _to;
        adminAndOwner[_to] = msg.sender;
        alreadyChange =true;
        isChangedOwner[_to] = alreadyChange;
        
    }
    function changeLockNumber(address[] memory _to) public {
        if(!isChangedOwner[msg.sender]){
        require(msg.sender == adminGropLockDetail[msg.sender][index].admin);
        adminGropLockDetail[msg.sender][index].mumber = _to;
        adminGropLockDetail[adminAndOwner[msg.sender]][index].mumber = _to;
        }else{
        require(msg.sender == adminGropLockDetail[adminAndOwner[msg.sender]][index].admin, "you are not admin");
        adminGropLockDetail[adminAndOwner[msg.sender]][index].mumber = _to;
    }
}
    function getLockTitle() public view returns(string memory){
        return ownerLockDetail[msg.sender][index].LockTitle;
    }
    function getGroupLockTitle() public view returns(string memory) {
        return adminGropLockDetail[msg.sender][index].LockTitle;
    }
    function getAmount() public view returns(uint) {
        return ownerLockDetail[msg.sender][index].amount;
    }
    function getDdl() public view returns(uint) {
        return ownerLockDetail[msg.sender][index].ddl;
    }

    function getTokenName() public view returns(string memory) {
        return IERC20(ownerLockDetail[msg.sender][index].token).name();
    }

    function getTokenSymbol() public view returns(string memory) {
        return IERC20(ownerLockDetail[msg.sender][index].token).symbol();
    }

    function getTokenDecimals() public view returns(uint) {
        return IERC20(ownerLockDetail[msg.sender][index].token).decimals();
    }

    function getToken() public view returns(address[] memory) {
        return tokenAddress[msg.sender];
    }

}
