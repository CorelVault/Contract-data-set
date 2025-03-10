{{
  "language": "Solidity",
  "settings": {
    "evmVersion": "london",
    "libraries": {},
    "metadata": {
      "bytecodeHash": "ipfs",
      "useLiteralContent": true
    },
    "optimizer": {
      "enabled": true,
      "runs": 999999
    },
    "remappings": [],
    "outputSelection": {
      "*": {
        "*": [
          "evm.bytecode",
          "evm.deployedBytecode",
          "devdoc",
          "userdoc",
          "metadata",
          "abi"
        ]
      }
    }
  },
  "sources": {
    "contracts/dependencies/openzeppelin/upgradeability/ContextUpgradeable.sol": {
      "content": "// SPDX-License-Identifier: agpl-3.0\npragma solidity 0.8.12;\n\nimport \"./Initializable.sol\";\n\ncontract ContextUpgradeable is Initializable {\n\tfunction __Context_init() internal onlyInitializing {}\n\n\tfunction __Context_init_unchained() internal onlyInitializing {}\n\n\tfunction _msgSender() internal view virtual returns (address payable) {\n\t\treturn payable(msg.sender);\n\t}\n\n\tfunction _msgData() internal view virtual returns (bytes memory) {\n\t\tthis;\n\t\treturn msg.data;\n\t}\n\n\tuint256[50] private __gap;\n}\n"
    },
    "contracts/dependencies/openzeppelin/upgradeability/Initializable.sol": {
      "content": "// SPDX-License-Identifier: agpl-3.0\npragma solidity 0.8.12;\n\n/**\n * @title Initializable\n *\n * @dev Helper contract to support initializer functions. To use it, replace\n * the constructor with a function that has the `initializer` modifier.\n * WARNING: Unlike constructors, initializer functions must be manually\n * invoked. This applies both to deploying an Initializable contract, as well\n * as extending an Initializable contract via inheritance.\n * WARNING: When used with inheritance, manual care must be taken to not invoke\n * a parent initializer twice, or ensure that all initializers are idempotent,\n * because this is not dealt with automatically as with constructors.\n */\ncontract Initializable {\n\t/**\n\t * @dev Indicates that the contract has been initialized.\n\t */\n\tbool private initialized;\n\n\t/**\n\t * @dev Indicates that the contract is in the process of being initialized.\n\t */\n\tbool private initializing;\n\n\t/**\n\t * @dev Modifier to use in the initializer function of a contract.\n\t */\n\tmodifier initializer() {\n\t\trequire(initializing || isConstructor() || !initialized, \"Contract instance has already been initialized\");\n\n\t\tbool isTopLevelCall = !initializing;\n\t\tif (isTopLevelCall) {\n\t\t\tinitializing = true;\n\t\t\tinitialized = true;\n\t\t}\n\n\t\t_;\n\n\t\tif (isTopLevelCall) {\n\t\t\tinitializing = false;\n\t\t}\n\t}\n\n\t/// @dev Returns true if and only if the function is running in the constructor\n\tfunction isConstructor() private view returns (bool) {\n\t\t// extcodesize checks the size of the code stored in an address, and\n\t\t// address returns the current address. Since the code is still not\n\t\t// deployed when running a constructor, any checks on its code size will\n\t\t// yield zero, making it an effective way to detect if a contract is\n\t\t// under construction or not.\n\t\tuint256 cs;\n\t\t//solium-disable-next-line\n\t\tassembly {\n\t\t\tcs := extcodesize(address())\n\t\t}\n\t\treturn cs == 0;\n\t}\n\n\tmodifier onlyInitializing() {\n\t\trequire(initializing, \"Initializable: contract is not initializing\");\n\t\t_;\n\t}\n\n\t// Reserved storage space to allow for layout changes in the future.\n\tuint256[50] private ______gap;\n}\n"
    },
    "contracts/dependencies/openzeppelin/upgradeability/OwnableUpgradeable.sol": {
      "content": "// SPDX-License-Identifier: agpl-3.0\npragma solidity 0.8.12;\n\nimport \"./Initializable.sol\";\nimport \"./ContextUpgradeable.sol\";\n\ncontract OwnableUpgradeable is Initializable, ContextUpgradeable {\n\taddress private _owner;\n\n\tevent OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n\tfunction __Ownable_init() internal onlyInitializing {\n\t\t__Ownable_init_unchained();\n\t}\n\n\tfunction __Ownable_init_unchained() internal onlyInitializing {\n\t\t_transferOwnership(_msgSender());\n\t}\n\n\tfunction owner() public view virtual returns (address) {\n\t\treturn _owner;\n\t}\n\n\tmodifier onlyOwner() {\n\t\trequire(owner() == _msgSender(), \"Ownable: caller is not the owner\");\n\t\t_;\n\t}\n\n\tfunction renounceOwnership() public virtual onlyOwner {\n\t\t_transferOwnership(address(0));\n\t}\n\n\tfunction transferOwnership(address newOwner) public virtual onlyOwner {\n\t\trequire(newOwner != address(0), \"Ownable: new owner is the zero address\");\n\t\t_transferOwnership(newOwner);\n\t}\n\n\tfunction _transferOwnership(address newOwner) internal virtual {\n\t\taddress oldOwner = _owner;\n\t\t_owner = newOwner;\n\t\temit OwnershipTransferred(oldOwner, newOwner);\n\t}\n\n\tuint256[49] private __gap;\n}\n"
    },
    "contracts/interfaces/IBaseOracle.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity 0.8.12;\n\ninterface IBaseOracle {\n\tfunction latestAnswer() external view returns (uint256 price);\n\n\tfunction latestAnswerInEth() external view returns (uint256 price);\n\n\tfunction update() external;\n\n\tfunction canUpdate() external view returns (bool);\n\n\tfunction consult() external view returns (uint256 price);\n}\n"
    },
    "contracts/interfaces/IChainlinkAdapter.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.12;\n\ninterface IChainlinkAdapter {\n\tfunction latestAnswer() external view returns (uint256 price);\n\n\tfunction decimals() external view returns (uint8);\n}\n"
    },
    "contracts/radiant/oracles/RadiantChainlinkOracle.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.12;\n\nimport {OwnableUpgradeable} from \"../../dependencies/openzeppelin/upgradeability/OwnableUpgradeable.sol\";\nimport {IChainlinkAdapter} from \"../../interfaces/IChainlinkAdapter.sol\";\nimport {IBaseOracle} from \"../../interfaces/IBaseOracle.sol\";\n\n/// @title RadiantChainlinkOracle Contract\n/// @author Radiant\ncontract RadiantChainlinkOracle is IBaseOracle, OwnableUpgradeable {\n\t/// @notice Eth price feed\n\tIChainlinkAdapter public ethChainlinkAdapter;\n\t/// @notice Token price feed\n\tIChainlinkAdapter public rdntChainlinkAdapter;\n\n\terror AddressZero();\n\n\t/**\n\t * @notice Initializer\n\t * @param _ethChainlinkAdapter Chainlink adapter for ETH.\n\t * @param _rdntChainlinkAdapter Chainlink price feed for RDNT.\n\t */\n\tfunction initialize(address _ethChainlinkAdapter, address _rdntChainlinkAdapter) external initializer {\n\t\tif (_ethChainlinkAdapter == address(0)) revert AddressZero();\n\t\tif (_rdntChainlinkAdapter == address(0)) revert AddressZero();\n\t\tethChainlinkAdapter = IChainlinkAdapter(_ethChainlinkAdapter);\n\t\trdntChainlinkAdapter = IChainlinkAdapter(_rdntChainlinkAdapter);\n\t\t__Ownable_init();\n\t}\n\n\t/**\n\t * @notice Returns USD price in quote token.\n\t * @dev supports 18 decimal token\n\t * @return price of token in decimal 8\n\t */\n\tfunction latestAnswer() public view returns (uint256 price) {\n\t\t// Chainlink param validations happens inside here\n\t\tprice = rdntChainlinkAdapter.latestAnswer();\n\t}\n\n\t/**\n\t * @notice Returns price in ETH\n\t * @dev supports 18 decimal token\n\t * @return price of token in decimal 8.\n\t */\n\tfunction latestAnswerInEth() public view returns (uint256 price) {\n\t\tuint256 rdntPrice = rdntChainlinkAdapter.latestAnswer();\n\t\tuint256 ethPrice = ethChainlinkAdapter.latestAnswer();\n\t\tprice = (rdntPrice * (10 ** 8)) / ethPrice;\n\t}\n\n\t/**\n\t * @dev Check if update() can be called instead of wasting gas calling it.\n\t */\n\tfunction canUpdate() public pure returns (bool) {\n\t\treturn false;\n\t}\n\n\t/**\n\t * @dev this function only exists so that the contract is compatible with the IBaseOracle Interface\n\t */\n\tfunction update() public {}\n\n\t/**\n\t * @notice Returns current price.\n\t */\n\tfunction consult() public view returns (uint256 price) {\n\t\tprice = latestAnswer();\n\t}\n}\n"
    }
  }
}}
