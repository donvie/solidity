// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0; 

interface IERC20 {
    function transfer(address to, uint amount) external returns(bool);
    function transferFrom(address from, address to, uint amount) external returns(bool);
}

contract TokenSwap {
    enum SwapType { AforB, BforA }

    struct Swap {
        SwapType swapType;
        address creator;
        address swappedBy;
        uint amountFrom;
        uint amountTo;
        bool isSwapped;
    }

    Swap[] public swaps;
    mapping(address => uint[]) public ownerToSwaps;


    IERC20 public tokenA;
    IERC20 public tokenB;


    constructor(address _tokenA, address _tokenB) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
    }


    function getSwapsLength() external view returns(uint) {
        return swaps.length;
    }

    function getOwnerSwapsLength(address owner) external view returns(uint) {
        return ownerToSwaps[owner].length;
    }

    function createSwap(SwapType _swapType, uint _amountFrom, uint _amountTo) external {
        uint swapId = swaps.length;

        ownerToSwaps[msg.sender].push(swapId);

        swaps.push(
            Swap(
                _swapType,
                msg.sender,
                address(0),
                _amountFrom,
                _amountTo,
                false
            )
        );

        if (_swapType == SwapType.AforB) {
            tokenA.transferFrom(msg.sender, address(this), _amountFrom);
        } else if (_swapType == SwapType.BforA) {
            tokenB.transferFrom(msg.sender, address(this), _amountFrom);
        }
    }

    function swap(uint _swapId) external {
        Swap storage swapInfo = swaps[_swapId];
        require(swapInfo.isSwapped == false);
        swapInfo.isSwapped = true;
        swapInfo.swappedBy = msg.sender;

        IERC20 tokenFrom;
        IERC20 tokenTo;

        if (swapInfo.swapType == SwapType.AforB) {
            tokenFrom = tokenA;
            tokenTo = tokenB;
        } else if (swapInfo.swapType == SwapType.BforA) {
            tokenFrom = tokenB;
            tokenTo = tokenA;
        }

        tokenFrom.transfer(msg.sender, swapInfo.amountFrom);
        tokenTo.transferFrom(msg.sender, swapInfo.creator, swapInfo.amountTo);
    }

}


