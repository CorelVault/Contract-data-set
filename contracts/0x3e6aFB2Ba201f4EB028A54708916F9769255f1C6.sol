// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

library SafeMath {
    function tryAdd(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

pragma solidity ^0.8.22;

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

pragma solidity ^0.8.22;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

pragma solidity ^0.8.22;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

pragma solidity ^0.8.22;

contract OwnerWithdrawable is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    receive() external payable {}

    fallback() external payable {}

    function withdraw(address token, uint256 amt) public onlyOwner {
        IERC20(token).safeTransfer(msg.sender, amt);
    }

    function withdrawAll(address token) public onlyOwner {
        uint256 amt = IERC20(token).balanceOf(address(this));
        withdraw(token, amt);
    }

    function withdrawCurrency(uint256 amt) public onlyOwner {
        payable(msg.sender).transfer(amt);
    }

    // function deposit(address token, uint256 amt) public onlyOwner {
    //     uint256 allowance = IERC20(token).allowance(msg.sender, address(this));
    //     require(allowance >= amt, "Check the token allowance");
    //     IERC20(token).transferFrom(owner(), address(this), amt);
    // }
}

pragma solidity ^0.8.22;

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(
        address target,
        bytes memory data
    ) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(
        address target,
        bytes memory data
    ) internal view returns (bytes memory) {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(
        address target,
        bytes memory data
    ) internal returns (bytes memory) {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

pragma solidity ^0.8.22;

library SafeERC20 {
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(
                oldAllowance >= value,
                "SafeERC20: decreased allowance below zero"
            );
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(
                token,
                abi.encodeWithSelector(
                    token.approve.selector,
                    spender,
                    newAllowance
                )
            );
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

pragma solidity ^0.8.22;

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

pragma solidity ^0.8.22;

contract PresaleContract is OwnerWithdrawable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using SafeERC20 for IERC20Metadata;

    address public LPAddress;

    uint256 public rate;

    address public saleToken;

    uint public saleTokenDec;

    uint256 public totalTokensforSale;

    mapping(address => bool) public payableTokens;

    mapping(address => uint256) public tokenPrices;

    bool public saleStatus;

    address[] public buyers;

    mapping(address => BuyerTokenDetails) public buyersAmount;

    uint256 public totalTokensSold;

    uint256[1] public stagesEndTime;

    bool public unlockingStatus;

    uint256 public unlockingFee;

    uint256[4] public unlockingTimes;

    mapping(address => bool[4]) public isUnlocked;

    mapping(address => uint256) public unlockedAmount;

    struct BuyerTokenDetails {
        uint amount;
        bool exists;
        bool isClaimed;
    }

    constructor(uint256 _firstStageEndTime, address _LPAddress) {
        saleStatus = false;
        LPAddress = _LPAddress;

        stagesEndTime[0] = _firstStageEndTime;
    }

    modifier saleEnabled() {
        require(saleStatus == true, "Presale: is not enabled");
        _;
    }

    modifier saleStoped() {
        require(saleStatus == false, "Presale: is not stopped");
        _;
    }

    modifier unlockEnabled() {
        require(
            unlockingStatus == true,
            "Presale: unlocking token is not enabled"
        );
        _;
    }

    modifier unlockStoped() {
        require(
            unlockingStatus == false,
            "Presale: unlocking token is not stopped"
        );
        _;
    }

    function setLPAddress(address _LPAddress) external onlyOwner {
        LPAddress = _LPAddress;
    }

    function setSaleToken(
        address _saleToken,
        uint256 _totalTokensforSale,
        uint256 _rate,
        bool _saleStatus
    ) external onlyOwner {
        require(_rate != 0);
        rate = _rate;
        saleToken = _saleToken;
        saleStatus = _saleStatus;
        saleTokenDec = IERC20Metadata(saleToken).decimals();
        totalTokensforSale = _totalTokensforSale;
        IERC20(saleToken).safeTransferFrom(
            msg.sender,
            address(this),
            totalTokensforSale
        );
    }

    function stopSale() external onlyOwner saleEnabled {
        saleStatus = false;
    }

    function resumeSale() external onlyOwner saleStoped {
        saleStatus = true;
        unlockingStatus = false;
    }

    function startUnlocking(
        uint256 _unlockingFee,
        uint[4] memory _unlockingTimes
    ) external onlyOwner {
        saleStatus = false;
        unlockingStatus = true;
        unlockingFee = _unlockingFee;
        unlockingTimes = _unlockingTimes;
    }

    function stopUnlocking() external onlyOwner unlockEnabled {
        unlockingStatus = false;
    }

    function addPayableTokens(
        address[] memory _tokens,
        uint256[] memory _prices
    ) external onlyOwner {
        require(
            _tokens.length == _prices.length,
            "Presale: tokens & prices arrays length mismatch"
        );

        for (uint256 i = 0; i < _tokens.length; i++) {
            require(_prices[i] != 0);
            payableTokens[_tokens[i]] = true;
            tokenPrices[_tokens[i]] = _prices[i];
        }
    }

    function payableTokenStatus(
        address _token,
        bool _status
    ) external onlyOwner {
        require(payableTokens[_token] != _status);

        payableTokens[_token] = _status;
    }

    function updateTokenRate(
        address[] memory _tokens,
        uint256[] memory _prices,
        uint256 _rate
    ) external onlyOwner {
        require(
            _tokens.length == _prices.length,
            "Presale: tokens & prices arrays length mismatch"
        );

        if (_rate != 0) {
            rate = _rate;
        }

        for (uint256 i = 0; i < _tokens.length; i += 1) {
            require(payableTokens[_tokens[i]] == true);
            require(_prices[i] != 0);
            tokenPrices[_tokens[i]] = _prices[i];
        }
    }

    function getTokenAmount(
        address token,
        uint256 amount
    ) public view returns (uint256) {
        uint256 amtOut;
        if (token != address(0)) {
            require(payableTokens[token] == true);
            uint256 price = tokenPrices[token];
            amtOut = amount.mul(10 ** saleTokenDec).div(price);
        } else {
            amtOut = amount.mul(10 ** saleTokenDec).div(rate);
        }
        return amtOut;
    }

    function transferETH() private {
        uint256 ownerAmount = msg.value;

        if (block.timestamp > stagesEndTime[0]) {
            uint256 lpAmount = msg.value.mul(10).div(100);
            ownerAmount = msg.value.sub(lpAmount);
            payable(LPAddress).transfer(lpAmount);
        }

        payable(owner()).transfer(ownerAmount);
    }

    function transferToken(address _token, uint256 _amount) private {
        uint256 ownerAmount = _amount;

        if (block.timestamp > stagesEndTime[0]) {
            uint256 lpAmount = _amount.mul(10).div(100);
            ownerAmount = _amount.sub(lpAmount);
            IERC20(_token).safeTransferFrom(msg.sender, LPAddress, lpAmount);
        }

        IERC20(_token).safeTransferFrom(msg.sender, owner(), ownerAmount);
    }

    function pinkyFinance(
        address _token,
        uint256 _amount
    ) external payable saleEnabled {
        uint256 saleTokenAmt;
        if (_token != address(0)) {
            require(_amount > 0);
            require(
                payableTokens[_token] == true,
                "Presale: Token not allowed"
            );

            saleTokenAmt = getTokenAmount(_token, _amount);
            require(
                (totalTokensSold + saleTokenAmt) < totalTokensforSale,
                "Presale: Not enough tokens to be sale"
            );
            transferToken(_token, _amount);
        } else {
            saleTokenAmt = getTokenAmount(address(0), msg.value);
            require((totalTokensSold + saleTokenAmt) < totalTokensforSale);
            transferETH();
        }
        totalTokensSold += saleTokenAmt;
        if (!buyersAmount[msg.sender].exists) {
            buyers.push(msg.sender);
            buyersAmount[msg.sender].exists = true;
        }
        buyersAmount[msg.sender].amount += saleTokenAmt;
    }

    function getUnlockingTimes() external view returns (uint[4] memory) {
        return unlockingTimes;
    }

    function transferFee() private {
        uint256 lpAmount = msg.value.mul(50).div(100);
        payable(LPAddress).transfer(lpAmount);
        uint256 ownerAmount = msg.value.sub(lpAmount);
        payable(owner()).transfer(ownerAmount);
    }

    function getUnlockingFeeAmount(
        address _address
    ) external view returns (uint256) {
        uint256 _fee = 0;

        for (uint i; i < 4; i++) {
            if (
                block.timestamp >= unlockingTimes[i] && !isUnlocked[_address][i]
            ) {
                _fee += unlockingFee;
            }
        }

        return _fee;
    }

    function getAmountToUnlock(
        address _address
    ) external view returns (uint256) {
        uint256 _amount = 0;

        for (uint i; i < 4; i++) {
            if (
                block.timestamp >= unlockingTimes[i] && !isUnlocked[_address][i]
            ) {
                _amount += buyersAmount[_address].amount / 4;
            }
        }

        return _amount;
    }

    function withdrawCoin() external payable unlockEnabled {
        require(
            buyersAmount[msg.sender].amount > 0,
            "Presale: You don't have tokens to claim"
        );

        uint256 _amount = 0;
        uint256 _fee = 0;
        bool[4] memory _isUnlocked;

        for (uint i; i < 4; i++) {
            if (block.timestamp >= unlockingTimes[i]) {
                _isUnlocked[i] = true;

                if (!isUnlocked[msg.sender][i]) {
                    _amount += buyersAmount[msg.sender].amount / 4;
                    _fee += unlockingFee;
                }
            }
        }

        require(_amount > 0, "Presale: You don't have tokens to unlock");
        require(msg.value >= _fee, "Presale: Not enough fee");

        IERC20(saleToken).safeTransfer(msg.sender, _amount);
        transferFee();

        unlockedAmount[msg.sender] += _amount;
        isUnlocked[msg.sender] = _isUnlocked;
    }
}
